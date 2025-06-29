import 'package:flutter/material.dart';
import 'package:fit_agent/routes/app_routes.dart';
import 'package:fit_agent/routes/main_routes.dart';
import 'package:fit_agent/routes/recipe_routes.dart';
import 'package:fit_agent/routes/settings_routes.dart';
import 'package:fit_agent/themes/app_theme.dart';
import 'package:fit_agent/services/secure_api_service.dart';
import 'package:fit_agent/screens/api_key_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SecureApiService _apiService = SecureApiService();
  late Future<bool> _checkApiKeyFuture;
  
  @override
  void initState() {
    super.initState();
    _checkApiKeyFuture = _checkApiKey();
  }
  
  // Verificar si existe una API key configurada
  Future<bool> _checkApiKey() async {
    return await _apiService.hasApiKey();
  }
  
  @override
  Widget build(BuildContext context) {
    // AGREGAMOS LAS RUTAS DE LA APLICACIÓN
    AppRoutes.addRange(MainRoutes.menuOptions);
    AppRoutes.addRange(RecipeRoutes.menuOptions);
    AppRoutes.addRange(SettingsRoutes.menuOptions);
    
    // Agregar rutas adicionales que requieren parámetros
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FIT Agent',
      theme: AppTheme.themeData,
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.getRoutes(),
      // Agregar router para verificar si hay API key cuando sea necesario
      home: FutureBuilder<bool>(
        future: _checkApiKeyFuture,
        builder: (context, snapshot) {
          // Mientras se verifica, mostrar pantalla de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Si no hay API key, redirigir a la pantalla de configuración
          if (snapshot.hasData && snapshot.data == false) {
            return const ApiKeyScreen(isRequired: true);
          }
          
          // Si hay API key, usar la ruta inicial normal
          final String initialRoute = AppRoutes.initialRoute;
          final Widget initialScreen = AppRoutes.getRoutes()[initialRoute]!(context);
          return initialScreen;
        },
      ),
    );
  }
}
