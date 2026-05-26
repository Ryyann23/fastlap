import 'package:flutter_test/flutter_test.dart';

import 'package:fastlap/features/auth/data/auth_service.dart';

void main() {
  setUp(() {
    AuthService.resetForTesting();
  });

  tearDown(() {
    AuthService.resetForTesting();
  });

  group('AuthService', () {
    test('cadastra, faz login e guarda o usuario ativo', () async {
      final registerResult = await AuthService().register(
        name: 'Ryan Teste',
        username: 'ryan',
        email: ' TESTE@FASTLAP.COM ',
        password: '123456',
      );

      final loginResult = await AuthService().login(
        email: 'teste@fastlap.com',
        password: '123456',
      );
      final user = await AuthService().getActiveUser();

      expect(registerResult.ok, isTrue);
      expect(loginResult.ok, isTrue);
      expect(loginResult.userName, 'Ryan Teste');
      expect(user?.email, 'teste@fastlap.com');
    });

    test('retorna falha quando as credenciais locais nao batem', () async {
      await AuthService().register(
        name: 'Ryan Teste',
        username: 'ryan',
        email: 'teste@fastlap.com',
        password: '123456',
      );

      final result = await AuthService().login(
        email: 'teste@fastlap.com',
        password: 'errada',
      );

      expect(result.ok, isFalse);
      expect(result.message, 'E-mail ou senha invalidos.');
    });
  });
}
