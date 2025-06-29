import 'package:flutter/material.dart';
import 'package:fit_agent/models/menu_option.dart';
import 'package:fit_agent/routes/recipe_routes.dart';
import 'package:fit_agent/routes/settings_routes.dart';

class AppRoutes {
  static final initialRoute = "home";
  static final menuOptions = <MenuOption>[];

  static addRange(List<MenuOption> options) {
    menuOptions.addAll(options);
  }

  static add(MenuOption option) {
    menuOptions.add(option);
  }

  static Map<String, Widget Function(BuildContext)> getRoutes() {
    Map<String, Widget Function(BuildContext)> routes = {};
    
    // Agregar rutas básicas desde MenuOptions
    for (var menu in menuOptions) {
      routes.addAll({menu.ruta: (BuildContext context) => menu.screen});
    }
    
    // Agregar rutas adicionales que requieren argumentos
    routes.addAll(RecipeRoutes.getAdditionalRoutes());
    routes.addAll(SettingsRoutes.getAdditionalRoutes());
    
    return routes;
  }
}
