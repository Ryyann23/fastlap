import 'package:flutter/material.dart';

import 'theme/theme_controller.dart';
import 'theme/theme_scope.dart';
import '../features/auth/presentation/pages/login_page.dart';

class FastLapApp extends StatefulWidget {
  const FastLapApp({super.key});

  @override
  State<FastLapApp> createState() => _FastLapAppState();
}

class _FastLapAppState extends State<FastLapApp> {
  final ThemeController _themeController = ThemeController(darkMode: false);

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'FastLap',
            debugShowCheckedModeBanner: false,
            themeMode: _themeController.themeMode,
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            home: const LoginPage(),
            onGenerateRoute: (settings) {
              final builder = _routeBuilders[settings.name];
              if (builder == null) return null;
              return PageRouteBuilder(
                settings: settings,
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
                pageBuilder: (_, __, ___) =>
                    builder(context, settings.arguments),
              );
            },
          );
        },
      ),
    );
  }

  static final Map<String, Widget Function(BuildContext, Object?)>
      _routeBuilders = {
    '/login': (context, args) => const LoginPage(),
  };

  ThemeData _buildLightTheme() {
    const seed = Color(0xFFE86710);
    final scheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF2F2F2),
      cardColor: Colors.white,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _NoTransitionsBuilder(),
          TargetPlatform.iOS: _NoTransitionsBuilder(),
          TargetPlatform.macOS: _NoTransitionsBuilder(),
          TargetPlatform.windows: _NoTransitionsBuilder(),
          TargetPlatform.linux: _NoTransitionsBuilder(),
        },
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    const seed = Color(0xFF6A5CFF);
    final scheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF111216),
      cardColor: const Color(0xFF1A1D2A),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _NoTransitionsBuilder(),
          TargetPlatform.iOS: _NoTransitionsBuilder(),
          TargetPlatform.macOS: _NoTransitionsBuilder(),
          TargetPlatform.windows: _NoTransitionsBuilder(),
          TargetPlatform.linux: _NoTransitionsBuilder(),
        },
      ),
    );
  }
}

class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
