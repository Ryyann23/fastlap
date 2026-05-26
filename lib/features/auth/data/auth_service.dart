import 'package:uuid/uuid.dart';

import '../../../shared/data/audit_log_service.dart';
import '../../../shared/data/local_app_store.dart';
import '../../../shared/data/route_service.dart';
import '../../../shared/data/vehicle_service.dart';

class AuthService {
  static LocalAuthUser? _activeUser;

  static const Uuid _uuid = Uuid();
  final LocalAppStore _store = LocalAppStore.instance;

  static void resetForTesting() {
    _activeUser = null;
    LocalAppStore.instance.resetForTesting();
    RouteService.instance.clear();
    VehicleService.instance.clear();
    AuditLogService.instance.clear();
  }

  Future<LocalAuthUser?> getActiveUser() async {
    if (_activeUser != null) return _activeUser;

    final activeUserId = await _store.getActiveUserId();
    if (activeUserId == null) return null;

    final user = await _store.getUserById(activeUserId);
    if (user == null) {
      await _store.setActiveUserId(null);
      return null;
    }

    _activeUser = LocalAuthUser.fromLocal(user);
    return _activeUser;
  }

  Future<void> logout() async {
    final activeUser = await getActiveUser();

    if (activeUser != null) {
      await AuditLogService.instance.addEntry(
        action: AuditActionType.logout,
        description: 'Logout realizado',
        entityType: 'auth',
        entityId: activeUser.id,
        userName: activeUser.name,
      );
    }

    _activeUser = null;
    await _store.setActiveUserId(null);
    RouteService.instance.clear();
    VehicleService.instance.clear();
    AuditLogService.instance.clear();
  }

  Future<AuthResult> updateProfile({
    required String name,
    required String username,
    required String email,
  }) async {
    final activeUser = await getActiveUser();
    if (activeUser == null) {
      return const AuthResult.failure('Nenhum usuario logado.');
    }

    final trimmedName = name.trim();
    final trimmedUsername = username.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (trimmedName.isEmpty ||
        trimmedUsername.isEmpty ||
        normalizedEmail.isEmpty) {
      return const AuthResult.failure('Preencha nome, usuario e e-mail.');
    }

    final existingEmailUser = await _store.getUserByEmail(normalizedEmail);
    if (existingEmailUser != null &&
        existingEmailUser['id']?.toString() != activeUser.id) {
      return const AuthResult.failure('Ja existe uma conta com esse e-mail.');
    }

    final existingUsernameUser =
        await _store.getUserByUsername(trimmedUsername);
    if (existingUsernameUser != null &&
        existingUsernameUser['id']?.toString() != activeUser.id) {
      return const AuthResult.failure('Ja existe uma conta com esse usuario.');
    }

    final user = await _store.getUserById(activeUser.id);
    if (user == null) {
      return const AuthResult.failure('Conta local nao encontrada.');
    }

    final updatedUser = {
      ...user,
      'name': trimmedName,
      'username': trimmedUsername,
      'email': normalizedEmail,
    };

    await _store.upsertUser(updatedUser);
    _activeUser = LocalAuthUser.fromLocal(updatedUser);

    return AuthResult.success(token: 'local-session', userName: trimmedName);
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final activeUser = await getActiveUser();
    if (activeUser == null) {
      return const AuthResult.failure('Nenhum usuario logado.');
    }

    if (newPassword.length < 6) {
      return const AuthResult.failure(
        'A nova senha precisa ter pelo menos 6 caracteres.',
      );
    }

    final user = await _store.getUserById(activeUser.id);
    if (user == null) {
      return const AuthResult.failure('Conta local nao encontrada.');
    }

    final currentDigest = user['passwordDigest']?.toString();
    if (currentDigest != _passwordDigest(currentPassword)) {
      return const AuthResult.failure('Senha atual incorreta.');
    }

    await _store.upsertUser({
      ...user,
      'passwordDigest': _passwordDigest(newPassword),
    });

    return const AuthResult.success(token: 'local-session', userName: '');
  }

  Future<void> updateAvatar(String? avatarBase64) async {
    final activeUser = await getActiveUser();
    if (activeUser == null) return;

    final user = await _store.getUserById(activeUser.id);
    if (user == null) return;

    final updatedUser = {
      ...user,
      'avatarBase64': avatarBase64,
    };

    await _store.upsertUser(updatedUser);
    _activeUser = LocalAuthUser.fromLocal(updatedUser);
  }

  Future<void> deleteProfile() async {
    final activeUser = await getActiveUser();
    if (activeUser == null) return;

    await _store.removeUser(activeUser.id);
    _activeUser = null;
    RouteService.instance.clear();
    VehicleService.instance.clear();
    AuditLogService.instance.clear();
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final user = await _store.getUserByEmail(normalizedEmail);

    if (user == null ||
        user['passwordDigest']?.toString() != _passwordDigest(password)) {
      return const AuthResult.failure('E-mail ou senha invalidos.');
    }

    await _store.setActiveUserId(user['id']?.toString());
    _activeUser = LocalAuthUser.fromLocal(user);
    RouteService.instance.clear();
    VehicleService.instance.clear();
    AuditLogService.instance.clear();

    await AuditLogService.instance.addEntry(
      action: AuditActionType.login,
      description: 'Login realizado',
      entityType: 'auth',
      entityId: _activeUser?.id ?? 'unknown',
      userName: _activeUser?.name,
    );

    return AuthResult.success(
      token: _activeUser?.id ?? 'local-session',
      userName: _activeUser?.name ?? '',
    );
  }

  Future<AuthResult> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final trimmedUsername = username.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (trimmedName.isEmpty ||
        trimmedUsername.isEmpty ||
        normalizedEmail.isEmpty ||
        password.isEmpty) {
      return const AuthResult.failure('Preencha todos os campos.');
    }

    if (password.length < 6) {
      return const AuthResult.failure(
        'A senha precisa ter pelo menos 6 caracteres.',
      );
    }

    if (await _store.getUserByEmail(normalizedEmail) != null) {
      return const AuthResult.failure('Ja existe uma conta com esse e-mail.');
    }

    if (await _store.getUserByUsername(trimmedUsername) != null) {
      return const AuthResult.failure('Ja existe uma conta com esse usuario.');
    }

    final now = DateTime.now();
    final user = {
      'id': _uuid.v4(),
      'name': trimmedName,
      'username': trimmedUsername,
      'email': normalizedEmail,
      'passwordDigest': _passwordDigest(password),
      'createdAt': now.toIso8601String(),
      'avatarBase64': null,
      'avatarUrl': null,
    };

    await _store.upsertUser(user);

    return AuthResult.success(
      token: 'local-session',
      userName: trimmedName,
    );
  }

  static String _passwordDigest(String value) {
    var hash = 0x811c9dc5;
    for (final code in value.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

class AuthResult {
  const AuthResult._({
    required this.ok,
    this.message,
    this.token,
    this.userName,
  });

  const AuthResult.success({required String token, required String userName})
      : this._(ok: true, token: token, userName: userName);

  const AuthResult.failure(String message)
      : this._(ok: false, message: message);

  final bool ok;
  final String? message;
  final String? token;
  final String? userName;
}

class LocalAuthUser {
  const LocalAuthUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.createdAt,
    this.avatarBase64,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String username;
  final String email;
  final DateTime createdAt;
  final String? avatarBase64;
  final String? avatarUrl;

  factory LocalAuthUser.fromLocal(Map<String, dynamic> map) {
    return LocalAuthUser(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      createdAt: DateTime.tryParse(
            (map['createdAt'] ?? map['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
      avatarBase64: map['avatarBase64']?.toString(),
      avatarUrl: (map['avatarUrl'] ?? map['avatar_url'])?.toString(),
    );
  }

  LocalAuthUser copyWith({
    String? id,
    String? name,
    String? username,
    String? email,
    DateTime? createdAt,
    String? avatarBase64,
    String? avatarUrl,
  }) {
    return LocalAuthUser(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
