import 'package:flutter/material.dart';

class AppTheme{
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  static ThemeData DarkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor:primaryColor,
      brightness: Brightness.dark 
      ),
       fontFamily: 'PressStart2P',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold
        )
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: Colors.blueAccent
      )
  );

  static ThemeData LightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'PressStart2P',
    colorScheme: ColorScheme.fromSeed(
      seedColor:const Color.fromARGB(255, 174, 148, 247),
      brightness: Brightness.light,
      )
  );
}