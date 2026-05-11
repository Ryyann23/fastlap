import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:fastlap/features/auth/data/auth_service.dart';
import 'package:fastlap/shared/data/api_client.dart';

void main() {
  setUp(() {
    AuthService.resetForTesting();
  });

  tearDown(() {
    ApiClient.instance.resetClientForTesting();
    AuthService.resetForTesting();
  });

  group('AuthService', () {
    test('faz login e guarda o usuario ativo', () async {
      ApiClient.instance.setClientForTesting(
        MockClient((request) async {
          if (request.method == 'POST' &&
              request.url.path == '/api/auth/login') {
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body['email'], 'teste@fastlap.com');

            return _jsonResponse({
              'accessToken': 'access-token',
              'refreshToken': 'refresh-token',
              'user': _userJson,
            });
          }

          if (request.method == 'GET' &&
              request.url.path == '/api/auth/me') {
            return _jsonResponse(_userJson);
          }

          return _jsonResponse({'ok': true});
        }),
      );

      final result = await AuthService().login(
        email: ' TESTE@FASTLAP.COM ',
        password: '123456',
      );
      final user = await AuthService().getActiveUser();

      expect(result.ok, isTrue);
      expect(result.userName, 'Ryan Teste');
      expect(user?.email, 'teste@fastlap.com');
    });

    test('retorna falha quando o backend recusa o login', () async {
      ApiClient.instance.setClientForTesting(
        MockClient((request) async {
          return _jsonResponse({'message': 'Credenciais invalidas.'}, 401);
        }),
      );

      final result = await AuthService().login(
        email: 'teste@fastlap.com',
        password: 'errada',
      );

      expect(result.ok, isFalse);
      expect(result.message, 'Credenciais invalidas.');
    });
  });
}

http.Response _jsonResponse(Object body, [int statusCode = 200]) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}

const _userJson = {
  'id': 'user-test',
  'name': 'Ryan Teste',
  'username': 'ryan',
  'email': 'teste@fastlap.com',
  'createdAt': '2026-01-01T00:00:00.000Z',
};
