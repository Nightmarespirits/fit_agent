import 'package:flutter/material.dart';
import 'package:fit_agent/models/menu_option.dart';
import 'package:fit_agent/screens/api_key_screen.dart';

class SettingsRoutes {
  static const apiKeyRoute = 'api-key';

  // Opciones para el menú de configuración
  static final List<MenuOption> menuOptions = [
    MenuOption(
      ruta: apiKeyRoute,
      nombre: 'Configuración de API Key',
      screen: const ApiKeyScreen(),
      icono: const Icon(Icons.key),
    ),
  ];

  // Rutas adicionales que requieren parámetros
  static Map<String, Widget Function(BuildContext)> getAdditionalRoutes() {
    return {
      // Ruta con parámetro isRequired para cuando se requiere la API key
      '$apiKeyRoute/required': (context) => const ApiKeyScreen(isRequired: true),
    };
  }
}
