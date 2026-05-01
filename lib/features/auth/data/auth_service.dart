import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/data/api_service.dart';

class AuthService {
  static const String _usersKey = 'fastlap_users';
  static const String _activeUserKey = 'fastlap_active_user';

  //==============================//
  //      register - BACKEND      //
  //==============================//
  Future<AuthResult> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    // Tentar registrar no backend
    final response = await ApiService.post(
      '/auth/register',
      body: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      },
    );

    if (response.ok) {
      // Salvar token e usuário localmente
      final data = response.dataAsMap;
      if (data != null) {
        final accessToken = data['accessToken'] as String?;
        final user = data['user'] as Map<String, dynamic>?;

        if (accessToken != null) {
          await ApiService.setAuthToken(accessToken);
        }

        if (user != null) {
          await _saveActiveUser(Map<String, dynamic>.from(user));
        }

        return AuthResult.success(
          token: accessToken ?? 'token-recebido',
          userName: user?['name']?.toString() ?? name,
        );
      }
      return AuthResult.success(token: 'token-recebido', userName: name);
    }

    // Se falhar, tentar salvar localmente (fallback)
    return _registerLocal(name: name, username: username, email: email, password: password);
  }

  //==============================//
  //       login - BACKEND       //
  //==============================//
  Future<AuthResult> login({required String email, required String password}) async {
    // Tentar login no backend
    final response = await ApiService.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.ok) {
      final data = response.dataAsMap;
      if (data != null) {
        final accessToken = data['accessToken'] as String?;
        final user = data['user'] as Map<String, dynamic>?;

        if (accessToken != null) {
          await ApiService.setAuthToken(accessToken);
        }

        if (user != null) {
          await _saveActiveUser(Map<String, dynamic>.from(user));
        }

        return AuthResult.success(
          token: accessToken ?? 'token-recebido',
          userName: user?['name']?.toString() ?? '',
        );
      }
      return AuthResult.success(token: 'token-recebido', userName: email);
    }

    // Se falhar, tentar login localmente (fallback)
    return _loginLocal(email: email, password: password);
  }

  //==============================//
  //      logout - BACKEND       //
  //==============================//
  Future<void> logout() async {
    try {
      // Notificar backend (opcional)
      await ApiService.post('/auth/logout');
    } catch (_) {
      // Ignora erro de rede
    }

    // Limpar token local
    await ApiService.clearAuthToken();

    // Limpar usuário ativo
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeUserKey);
  }

  //==============================//
  //     getActiveUser         //
  //==============================//
  Future<LocalAuthUser?> getActiveUser() async {
    // Primeiro tenta buscar do backend
    final token = await ApiService.getAuthToken();
    if (token != null) {
      final response = await ApiService.get('/auth/me', token: token);
      if (response.ok && response.dataAsMap != null) {
        return LocalAuthUser.fromMap(response.dataAsMap!);
      }
    }

    // Fallback: buscar localmente
    return _getActiveUserLocal();
  }

  //==============================//
  //    updateProfile        //
  //==============================//
  Future<AuthResult> updateProfile({
    required String name,
    required String username,
    required String email,
  }) async {
    final token = await ApiService.getAuthToken();
    if (token == null) {
      return const AuthResult.failure('Nenhum usuário logado.');
    }

    // Atualizar no backend
    final userId = await _getActiveUserId();
    if (userId != null) {
      final response = await ApiService.put(
        '/users/$userId',
        body: {
          'name': name,
          'username': username,
          'email': email,
        },
        token: token,
      );

      if (response.ok) {
        await _updateActiveUserLocal(name: name, username: username, email: email);
        return AuthResult.success(token: token, userName: name);
      }
    }

    return const AuthResult.failure('Erro ao atualizar perfil.');
  }

  //==============================//
  //    changePassword      //
  //==============================//
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await ApiService.getAuthToken();
    if (token == null) {
      return const AuthResult.failure('Nenhum usuário logado.');
    }

    // Atualizar no backend
    final userId = await _getActiveUserId();
    if (userId != null) {
      final response = await ApiService.put(
        '/users/$userId/password',
        body: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        token: token,
      );

      if (response.ok) {
        return AuthResult.success(token: token, userName: '');
      }

      return AuthResult.failure(response.error ?? 'Erro ao alterar senha.');
    }

    return const AuthResult.failure('Erro ao alterar senha.');
  }

  //==============================//
  //   updateAvatar          //
  //==============================//
  Future<void> updateAvatar(String? avatarBase64) async {
    final token = await ApiService.getAuthToken();
    if (token == null) return;

    final userId = await _getActiveUserId();
    if (userId != null) {
      await ApiService.put(
        '/users/$userId',
        body: {'avatar_url': avatarBase64},
        token: token,
      );
    }
  }

  //==============================//
  //   deleteProfile         //
  //==============================//
  Future<void> deleteProfile() async {
    final token = await ApiService.getAuthToken();
    if (token != null) {
      final userId = await _getActiveUserId();
      if (userId != null) {
        await ApiService.delete('/users/$userId', token: token);
      }
    }

    await logout();
  }

  //==============================//
  //   MÉTODOS LOCAIS (fallback) //
  //==============================//

  Future<AuthResult> _registerLocal({
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
        return const AuthResult.failure('Esse e-mail já está cadastrado.');
      }

      final usernameExists = users.any(
        (u) => (u['username'] ?? '').toString().toLowerCase() == normalizedUsername,
      );
      if (usernameExists) {
        return const AuthResult.failure('Esse nome de usuário já está em uso.');
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

      return AuthResult.success(token: 'local-session', userName: name.trim());
    } catch (_) {
      return const AuthResult.failure('Erro ao salvar os dados locais.');
    }
  }

  Future<AuthResult> _loginLocal({
    required String email,
    required String password,
  }) async {
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
        return const AuthResult.failure('Usuário ou senha inválidos.');
      }

      await _saveActiveUser(user);

      return AuthResult.success(
        token: 'local-session',
        userName: user['name']?.toString() ?? '',
      );
    } catch (_) {
      return const AuthResult.failure('Erro ao fazer login local.');
    }
  }

  Future<LocalAuthUser?> _getActiveUserLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_activeUserKey);
      if (raw == null || raw.isEmpty) return null;

      final map = Map<String, dynamic>.from(
        _decodeJson(raw) as Map,
      );
      return LocalAuthUser.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveActiveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserKey, _encodeJson(user));
  }

  Future<void> _updateActiveUserLocal({
    required String name,
    required String username,
    required String email,
  }) async {
    final user = await _getActiveUserLocal();
    if (user != null) {
      final updated = user.toMap()
        ..['name'] = name
        ..['username'] = username
        ..['email'] = email;
      await _saveActiveUser(updated);
    }
  }

  Future<String?> _getActiveUserId() async {
    final user = await getActiveUser();
    return user?.id;
  }

  Future<List<Map<String, dynamic>>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    final decoded = _decodeJson(raw) as List<dynamic>;
    return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<void> _writeUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, _encodeJson(users));
  }

  String _encodeJson(dynamic data) {
    return data.toString();
  }

  dynamic _decodeJson(String data) {
    return data;
  }
}

//==============================//
//      AuthResult            //
//==============================//
class AuthResult {
  final bool ok;
  final String? message;
  final String? token;
  final String? userName;

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
}

//==============================//
//      LocalAuthUser          //
//==============================//
class LocalAuthUser {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final DateTime createdAt;
  final String? avatarBase64;

  const LocalAuthUser({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
    this.avatarBase64,
  });

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
