import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastlap/app/theme/theme_controller.dart';
import 'package:fastlap/app/theme/theme_scope.dart';
import 'package:fastlap/features/auth/presentation/pages/login_page.dart';

void main() {
  testWidgets('renderiza a tela de login', (tester) async {
    await _pumpLoginPage(tester);

    expect(find.textContaining('login'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
  });

  testWidgets('mostra validacao quando tenta entrar sem preencher',
      (tester) async {
    await _pumpLoginPage(tester);

    await tester.tap(find.text('ENTRAR'));
    await tester.pump();

    expect(find.textContaining('Preencha'), findsOneWidget);
  });

  testWidgets('navega para cadastro a partir do login', (tester) async {
    await _pumpLoginPage(tester);

    await tester.ensureVisible(find.text('Cadastre-se'));
    await tester.tap(find.text('Cadastre-se'));
    await tester.pumpAndSettle();

    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Nome'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('CADASTRAR'), findsOneWidget);
  });
}

Future<void> _pumpLoginPage(WidgetTester tester) async {
  final themeController = ThemeController();

  await tester.pumpWidget(
    ThemeScope(
      controller: themeController,
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeController.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF2F2F2),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF111216),
            ),
            home: const LoginPage(),
          );
        },
      ),
    ),
  );
  await tester.pump();
}
