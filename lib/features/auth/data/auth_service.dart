import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'fastlap_users';
  static const String _activeUserKey = 'fastlap_active_user';

  Future<LocalAuthUser?> getActiveUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_activeUserKey);
      if (raw == null || raw.isEmpty) return null;

      final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      return LocalAuthUser.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeUserKey);
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

      final users = await _readUsers();
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedUsername = username.trim().toLowerCase();

      final emailTaken = users.any((u) {
        final sameUser = _isSameUser(u, activeUser);
        return !sameUser && (u['email'] ?? '').toString().toLowerCase() == normalizedEmail;
      });
      if (emailTaken) {
        return const AuthResult.failure('Esse e-mail ja esta cadastrado.');
      }

      final usernameTaken = users.any((u) {
        final sameUser = _isSameUser(u, activeUser);
        return !sameUser && (u['username'] ?? '').toString().toLowerCase() == normalizedUsername;
      });
      if (usernameTaken) {
        return const AuthResult.failure('Esse nome de usuario ja esta em uso.');
      }

      final updatedUser = activeUser.toMap()
        ..['name'] = name.trim()
        ..['username'] = username.trim()
        ..['email'] = normalizedEmail;

      await _replaceAndPersistUser(
        activeUser: activeUser,
        users: users,
        updatedUser: updatedUser,
      );

      return AuthResult.success(token: 'local-session', userName: name.trim());
    } catch (_) {
      return const AuthResult.failure('Erro ao atualizar perfil local.');
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

      if (currentPassword != activeUser.password) {
        return const AuthResult.failure('Senha atual incorreta.');
      }

      if (newPassword.length < 6) {
        return const AuthResult.failure('A nova senha precisa ter pelo menos 6 caracteres.');
      }

      final users = await _readUsers();
      final updatedUser = activeUser.toMap()..['password'] = newPassword;

      await _replaceAndPersistUser(
        activeUser: activeUser,
        users: users,
        updatedUser: updatedUser,
      );

      return const AuthResult.success(token: 'local-session', userName: '');
    } catch (_) {
      return const AuthResult.failure('Erro ao atualizar senha local.');
    }
  }

  Future<void> updateAvatar(String? avatarBase64) async {
    final activeUser = await getActiveUser();
    if (activeUser == null) return;

    final users = await _readUsers();
    final updatedUser = activeUser.toMap()..['avatarBase64'] = avatarBase64;

    await _replaceAndPersistUser(
      activeUser: activeUser,
      users: users,
      updatedUser: updatedUser,
    );
  }

  Future<void> deleteProfile() async {
    final activeUser = await getActiveUser();
    if (activeUser == null) return;

    final users = await _readUsers();
    users.removeWhere((u) => _isSameUser(u, activeUser));
    await _writeUsers(users);
    await logout();
  }

  Future<AuthResult> login({required String email, required String password}) async {
    try {
      final users = await _readUsers();
      final identifier = email.trim().toLowerCase();

      final user = users.where((u) {
        final savedEmail = (u['email'] ?? '').toString().toLowerCase();
        final savedUsername = (u['username'] ?? '').toString().toLowerCase();
        final savedPassword = (u['password'] ?? '').toString();

        return (savedEmail == identifier || savedUsername == identifier) &&
            savedPassword == password;
      }).firstOrNull;

      if (user == null) {
        return const AuthResult.failure('Usuario ou senha invalidos.');
      }

      await _saveActiveUser(user);

      return AuthResult.success(
        token: 'local-session',
        userName: user['name']?.toString() ?? '',
      );
    } catch (_) {
      return const AuthResult.failure('Erro ao ler os dados locais de login.');
    }
  }

  Future<AuthResult> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final users = await _readUsers();
      final normalizedEmail = email.trim().toLowerCase();
      final normalizedUsername = username.trim().toLowerCase();

      final emailExists = users.any(
        (u) => (u['email'] ?? '').toString().toLowerCase() == normalizedEmail,
      );
      if (emailExists) {
        return const AuthResult.failure('Esse e-mail ja esta cadastrado.');
      }

      final usernameExists = users.any(
        (u) => (u['username'] ?? '').toString().toLowerCase() == normalizedUsername,
      );
      if (usernameExists) {
        return const AuthResult.failure('Esse nome de usuario ja esta em uso.');
      }

      final user = <String, dynamic>{
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'name': name.trim(),
        'username': username.trim(),
        'email': normalizedEmail,
        'password': password,
        'createdAt': DateTime.now().toIso8601String(),
        'avatarBase64': null,
      };

      users.add(user);
      await _writeUsers(users);
      await _saveActiveUser(user);

      return AuthResult.success(
        token: 'local-session',
        userName: user['name']?.toString() ?? '',
      );
    } catch (_) {
      return const AuthResult.failure('Erro ao salvar os dados locais de cadastro.');
    }
  }

  Future<List<Map<String, dynamic>>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<void> _writeUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<void> _saveActiveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserKey, jsonEncode(user));
  }

  Future<void> _replaceAndPersistUser({
    required LocalAuthUser activeUser,
    required List<Map<String, dynamic>> users,
    required Map<String, dynamic> updatedUser,
  }) async {
    final index = users.indexWhere((u) => _isSameUser(u, activeUser));
    if (index >= 0) {
      users[index] = updatedUser;
    } else {
      users.add(updatedUser);
    }

    await _writeUsers(users);
    await _saveActiveUser(updatedUser);
  }

  bool _isSameUser(Map<String, dynamic> map, LocalAuthUser user) {
    final mapId = (map['id'] ?? '').toString();
    if (user.id.isNotEmpty && mapId.isNotEmpty) {
      return mapId == user.id;
    }

    final mapEmail = (map['email'] ?? '').toString().toLowerCase();
    final mapCreatedAt = (map['createdAt'] ?? '').toString();
    return mapEmail == user.email.toLowerCase() && mapCreatedAt == user.createdAt.toIso8601String();
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
    required this.password,
    required this.createdAt,
    required this.avatarBase64,
  });

  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final DateTime createdAt;
  final String? avatarBase64;

  factory LocalAuthUser.fromMap(Map<String, dynamic> map) {
    return LocalAuthUser(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      username: (map['username'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      password: (map['password'] ?? '').toString(),
      createdAt: DateTime.tryParse((map['createdAt'] ?? '').toString()) ?? DateTime.now(),
      avatarBase64: map['avatarBase64']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'avatarBase64': avatarBase64,
    };
  }
}
