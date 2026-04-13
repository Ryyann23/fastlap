import 'package:flutter/material.dart';

import '../../app/theme/theme_scope.dart';

class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key, required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeScope.of(context);
    final isDarkMode = themeController.isDarkMode;

    return InkWell(
      onTap: themeController.toggleTheme,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40 * scale,
        height: 40 * scale,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          color: Colors.white,
          size: 22 * scale,
        ),
      ),
    );
  }
}
