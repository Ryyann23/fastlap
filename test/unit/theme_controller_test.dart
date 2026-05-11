import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fastlap/app/theme/theme_controller.dart';

void main() {
  group('ThemeController', () {
    test('comeca no tema claro por padrao', () {
      final controller = ThemeController();

      expect(controller.isDarkMode, isFalse);
      expect(controller.themeMode, ThemeMode.light);
    });

    test('alterna entre claro e escuro', () {
      final controller = ThemeController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.toggleTheme();

      expect(controller.isDarkMode, isTrue);
      expect(controller.themeMode, ThemeMode.dark);
      expect(notifications, 1);
    });
  });
}
