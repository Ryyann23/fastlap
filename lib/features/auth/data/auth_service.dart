import '../../../shared/data/api_client.dart';
import '../../../shared/data/audit_log_service.dart';
import '../../../shared/data/route_service.dart';
import '../../../shared/data/vehicle_service.dart';

class AuthService {
  static LocalAuthUser? _activeUser;

  final ApiClient _api = ApiClient.instance;

  Future<LocalAuthUser?> getActiveUser() async {
    if (_activeUser != null) return _activeUser;
    if (!_api.hasSession) return null;

    try {
      final data = await _api.get('/api/auth/me');
      if (data is! Map<String, dynamic>) return null;

      _activeUser = LocalAuthUser.fromApi(data);
      return _activeUser;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final activeUser = await getActiveUser();

    try {
      await _api.post('/api/auth/logout', auth: false);
    } catch (_) {
      // Logout local da sessao do app mesmo se o backend nao responder.
    }

    _activeUser = null;
    _api.clearTokens();
    RouteService.instance.clear();
    VehicleService.instance.clear();

    await AuditLogService.instance.addEntry(
      action: AuditActionType.logout,
      description: 'Logout realizado',
      entityType: 'auth',
      entityId: activeUser?.id ?? 'unknown',
      userName: activeUser?.name,
    );
  }

  Future<AuthResult> updateProfile({
    required String name,
    required String username,
    required String email,
  }) async {
    try {
      final activeUser = await getActiveUser();
      if (activeUser == null) {
        return const AuthResult.failure('Nenhum usuario logado.');
      }

      final normalizedEmail = email.trim().toLowerCase();
      if (normalizedEmail != activeUser.email.toLowerCase()) {
        return const AuthResult.failure(
          'O backend atual nao permite alterar o e-mail.',
        );
      }

      final data = await _api.put(
        '/api/users/${activeUser.id}',
        body: {
          'name': name.trim(),
          'username': username.trim(),
        },
      );

      final userData = data is Map<String, dynamic> ? data['user'] : null;
      if (userData is Map<String, dynamic>) {
        _activeUser = activeUser.mergeApi(userData);
      } else {
        _activeUser = activeUser.copyWith(
          name: name.trim(),
          username: username.trim(),
        );
      }

      return AuthResult.success(token: 'session', userName: name.trim());
    } catch (error) {
      return AuthResult.failure(
        _messageFor(error, 'Erro ao atualizar perfil no backend.'),
      );
    }
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final activeUser = await getActiveUser();
      if (activeUser == null) {
        return const AuthResult.failure('Nenhum usuario logado.');
      }

      if (newPassword.length < 6) {
        return const AuthResult.failure(
          'A nova senha precisa ter pelo menos 6 caracteres.',
        );
      }

      await _api.put(
        '/api/users/${activeUser.id}/password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      return const AuthResult.success(token: 'session', userName: '');
    } catch (error) {
      return AuthResult.failure(
        _messageFor(error, 'Erro ao atualizar senha no backend.'),
      );
    }
  }

  Future<void> updateAvatar(String? avatarBase64) async {
    final activeUser = await getActiveUser();
    if (activeUser == null) return;

    // O backend atual possui apenas avatar_url. A imagem escolhida fica na
    // sessao do app ate existir upload/URL no servidor.
    _activeUser = activeUser.copyWith(avatarBase64: avatarBase64);
  }

  Future<void> deleteProfile() async {
    final activeUser = await getActiveUser();
    if (activeUser == null) return;

    await _api.delete('/api/users/${activeUser.id}');
    _activeUser = null;
    _api.clearTokens();
    RouteService.instance.clear();
    VehicleService.instance.clear();
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _api.post(
        '/api/auth/login',
        auth: false,
        body: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (data is! Map<String, dynamic>) {
        return const AuthResult.failure('Resposta invalida do backend.');
      }

      final accessToken = data['accessToken']?.toString();
      final refreshToken = data['refreshToken']?.toString();
      final userData = data['user'];

      if (accessToken == null ||
          accessToken.isEmpty ||
          refreshToken == null ||
          refreshToken.isEmpty ||
          userData is! Map<String, dynamic>) {
        return const AuthResult.failure('Resposta invalida do backend.');
      }

      _api.setTokens(accessToken: accessToken, refreshToken: refreshToken);
      _activeUser = LocalAuthUser.fromApi(userData);

      try {
        final me = await _api.get('/api/auth/me');
        if (me is Map<String, dynamic>) {
          _activeUser = LocalAuthUser.fromApi(me);
        }
      } catch (_) {
        // O login ja retornou usuario suficiente para seguir.
      }

      await AuditLogService.instance.addEntry(
        action: AuditActionType.login,
        description: 'Login realizado',
        entityType: 'auth',
        entityId: _activeUser?.id ?? 'unknown',
        userName: _activeUser?.name,
      );

      return AuthResult.success(
        token: accessToken,
        userName: _activeUser?.name ?? '',
      );
    } catch (error) {
      return AuthResult.failure(
        _messageFor(error, 'Erro ao fazer login no backend.'),
      );
    }
  }

  Future<AuthResult> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final data = await _api.post(
        '/api/auth/register',
        auth: false,
        body: {
          'name': name.trim(),
          'username': username.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      if (data is! Map<String, dynamic>) {
        return const AuthResult.failure('Resposta invalida do backend.');
      }

      return AuthResult.success(
        token: data['accessToken']?.toString() ?? 'session',
        userName: name.trim(),
      );
    } catch (error) {
      return AuthResult.failure(
        _messageFor(error, 'Erro ao criar cadastro no backend.'),
      );
    }
  }

  String _messageFor(Object error, String fallback) {
    if (error is ApiException) return error.message;
    return fallback;
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

  factory LocalAuthUser.fromApi(Map<String, dynamic> map) {
    return LocalAuthUser(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      createdAt: DateTime.tryParse(
            (map['createdAt'] ?? map['created_at'] ?? '').toString(),
          ) ??
          DateTime.now(),
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

  LocalAuthUser mergeApi(Map<String, dynamic> map) {
    return copyWith(
      id: (map['id'] ?? id).toString(),
      name: (map['name'] ?? name).toString(),
      username: (map['username'] ?? username).toString(),
      email: (map['email'] ?? email).toString(),
      avatarUrl:
          (map['avatarUrl'] ?? map['avatar_url'] ?? avatarUrl)?.toString(),
      createdAt: DateTime.tryParse(
            (map['createdAt'] ?? map['created_at'] ?? '').toString(),
          ) ??
          createdAt,
    );
  }
}
