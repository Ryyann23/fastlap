import 'package:flutter/material.dart';

import '../features/auth/presentation/pages/login_page.dart';

class FastLapApp extends StatelessWidget {
  const FastLapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastLap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE86710)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
