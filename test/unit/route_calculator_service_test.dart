import 'package:flutter_test/flutter_test.dart';

import 'package:fastlap/shared/data/route_calculator_service.dart';

void main() {
  group('RouteCalculatorService', () {
    test('formata minutos sem horas', () {
      expect(RouteCalculatorService.instance.formatTravelTime(45), '45m');
    });

    test('formata horas fechadas', () {
      expect(RouteCalculatorService.instance.formatTravelTime(120), '2h');
    });

    test('formata horas com minutos', () {
      expect(RouteCalculatorService.instance.formatTravelTime(135), '2h15m');
    });
  });
}
