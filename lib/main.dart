import 'package:flutter/material.dart';
import 'package:fit_agent/routes/app_routes.dart';
import 'package:fit_agent/routes/main_routes.dart';
import 'package:fit_agent/routes/recipe_routes.dart';
import 'package:fit_agent/themes/app_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AGREGAMOS LAS RUTAS DE LA APLICACIÓN
    AppRoutes.addRange(MainRoutes.menuOptions);
    AppRoutes.addRange(RecipeRoutes.menuOptions);
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FIT Agent',
      theme: AppTheme.themeData,
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.getRoutes(),
    );
  }
}
