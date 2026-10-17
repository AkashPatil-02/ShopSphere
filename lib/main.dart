import 'package:flutter/material.dart';
import 'package:shopsphere/core/themes/apptheme.dart';
import 'package:shopsphere/splash_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.LightTheme,
      darkTheme: AppTheme.DarkTheme,
      home: const SplashScreen(),
    );
  }
}
