import 'package:flutter/material.dart';

class AppTheme {
  // Nueva paleta de colores suaves y armónicos
  static const Color verdePrincipal = Color(0xFF7CB342);    // Verde menta suave como color principal
  static const Color verdeSecundario = Color(0xFF9CCC65);    // Verde hierba claro para áreas secundarias
  static const Color verdeClaro = Color(0xFFDCEDC8);        // Verde muy claro para fondos sutiles
  static const Color verdeOscuro = Color(0xFF558B2F);       // Verde profundo para acentos y contraste

  // Colores complementarios
  static const Color melocoton = Color(0xFFFFCCBC);         // melocoton suave para contraste cálido
  static const Color salmonAccion = Color(0xFFFF8A65);       // Sálmon para botones de acción
  static const Color turquesaClaro = Color(0xFFB2DFDB);     // Turquesa para elementos interactivos
  
  // Colores neutros
  static const Color blanco = Color(0xFFFFFFFF);
  static const Color crema = Color(0xFFF5F5F5);
  static const Color grisClaro = Color(0xFFEEEEEE);
  static const Color grisMedio = Color(0xFF9E9E9E);
  static const Color grisTexto = Color(0xFF757575);
  static const Color negro = Color(0xFF424242);            // Negro suavizado

  // Colores funcionales
  static const Color rojoAlerta = Color(0xFFEF5350);       // Rojo menos intenso para alertas
  static const Color enfasisAmarillo = Color(0xFFFFD54F);   // Énfasis discreto para interacciones
  
  // Colores antiguos (mantener para compatibilidad con código existente)
  static const Color verdeMedio = verdePrincipal;       // Referencia al antiguo verdeMedio
  static const Color naranjaAccion = salmonAccion;     // Referencia al antiguo naranjaAccion
  static const Color azulSuave = turquesaClaro;        // Referencia al antiguo azulSuave
  static const Color azulBoton = verdePrincipal;       // Referencia al antiguo azulBoton

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    primaryColor: verdePrincipal,
    scaffoldBackgroundColor: crema,
    fontFamily: 'Roboto',
    
    // Colores de interacción con mejor contraste
    splashColor: turquesaClaro,
    highlightColor: melocoton.withOpacity(0.6),
    splashFactory: InkRipple.splashFactory,
    
    // Esquema de color armonioso
    colorScheme: ColorScheme.light(
      primary: verdePrincipal,
      primaryContainer: verdeClaro,
      secondary: salmonAccion,
      secondaryContainer: melocoton,
      surface: blanco,
      background: crema,
      error: rojoAlerta,
      onPrimary: blanco,
      onSecondary: negro,
      onSurface: grisTexto,
      onBackground: negro,
      onError: blanco,
    ),
    
    cardColor: blanco,
    dialogBackgroundColor: blanco,
    dividerColor: grisClaro,

    appBarTheme: const AppBarTheme(
      backgroundColor: verdePrincipal,
      foregroundColor: blanco,
      centerTitle: true,
      elevation: 0,
      shadowColor: Color(0x29000000),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: verdeOscuro),
      displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: verdeOscuro),
      displaySmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: verdeOscuro),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: verdeOscuro),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: verdeOscuro),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: verdeOscuro),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: negro),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: negro),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: negro),
      bodyLarge: TextStyle(fontSize: 16, color: grisTexto, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, color: grisTexto, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, color: grisMedio, height: 1.5),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: blanco),
      labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: grisTexto),
      labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: grisMedio),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: salmonAccion,
        foregroundColor: blanco,
        elevation: 1,
        shadowColor: salmonAccion.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: verdePrincipal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: verdePrincipal,
        side: const BorderSide(color: verdePrincipal),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      fillColor: blanco,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: grisClaro),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: verdePrincipal, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: grisClaro),
        borderRadius: BorderRadius.circular(16),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: rojoAlerta),
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(color: grisTexto),
      hintStyle: const TextStyle(color: grisMedio, fontSize: 14),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: verdePrincipal,
      selectedItemColor: blanco,
      unselectedItemColor: verdeClaro,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedIconTheme: IconThemeData(size: 26),
      unselectedIconTheme: IconThemeData(size: 22),
      selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 12),
    ),
    
    // Configuración de tema de material para botones de acción flotante y controles
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(melocoton.withOpacity(0.5)),
        foregroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.focused) || 
              states.contains(MaterialState.pressed)) {
            return salmonAccion;
          }
          return verdePrincipal;
        }),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.focused) || 
              states.contains(MaterialState.pressed)) {
            return verdeClaro.withOpacity(0.3);
          }
          return Colors.transparent;
        }),
      ),
    ),
    
    // Configuración del FAB
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: salmonAccion,
      foregroundColor: blanco,
      elevation: 4,
      shape: CircleBorder(),
    ),
    
    // Tema de tarjetas
    cardTheme: CardThemeData(
      color: blanco,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
    
    // Tema de diálogos
    dialogTheme: DialogThemeData(
      backgroundColor: blanco,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
