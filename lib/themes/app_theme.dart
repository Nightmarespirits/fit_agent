import 'package:flutter/material.dart';

class AppTheme {
  // Colores base (
  static const Color verdeOscuro = Color(0xFF1B5E20);
  static const Color verdeMedio = Color(0xFF43A047);
  static const Color verdeClaro = Color(0xFFC8E6C9);

  static const Color azulSuave = Color(0xFFE3F2FD);
  static const Color azulBoton = Color(0xFF0D47A1);

  static const Color blanco = Color(0xFFFFFFFF);
  static const Color grisClaro = Color(0xFFF5F5F5);
  static const Color grisTexto = Color(0xFF616161);

  static const Color naranjaAccion = Color(
    0xFFFFA726,
  ); // Para CTA (Call To Action)
  static const Color rojoAlerta = Color(0xFFE53935);

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    primaryColor: verdeMedio,
    scaffoldBackgroundColor: blanco,
    fontFamily: 'Roboto',

    colorScheme: ColorScheme.fromSeed(
      seedColor: verdeMedio,
      primary: verdeMedio,
      secondary: azulBoton,
      surface: grisClaro,
      error: rojoAlerta,
      onPrimary: blanco,
      onSecondary: blanco,
      onSurface: grisTexto,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: verdeOscuro,
      foregroundColor: blanco,
      centerTitle: true,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: verdeOscuro,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: grisTexto),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: blanco,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: naranjaAccion,
        foregroundColor: blanco,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: verdeMedio, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      labelStyle: const TextStyle(color: grisTexto),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: verdeOscuro,
      selectedItemColor: blanco,
      unselectedItemColor: Color(0xFFBDBDBD),
      showUnselectedLabels: false,
    ),
  );
}
