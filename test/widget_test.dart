import 'package:flutter_test/flutter_test.dart';

import 'package:fastlap/app/fastlap_app.dart';

void main() {
  testWidgets('renderiza tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(const FastLapApp());

    expect(find.text('Pagina de Login'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
  });
}
