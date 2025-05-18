import 'package:flutter/material.dart';
import 'package:fit_agent/models/menu_option.dart';
import 'package:fit_agent/screens/screens.dart';
import 'package:fit_agent/models/ingrediente_seleccionado.dart';
import 'package:fit_agent/widgets/seleccion_ingredientes.dart';

class RecipeRoutes {
  // Ya no necesitamos estas rutas, ya que están en MainRoutes
  static final menuOptions = <MenuOption>[];
  
  // Definición de rutas adicionales que requieren argumentos
  static Map<String, Widget Function(BuildContext)> getAdditionalRoutes() {
    return {
      'recipe': (context) {
        final List<IngredienteSeleccionado> ingredientes = 
            (ModalRoute.of(context)!.settings.arguments as List<dynamic>)
            .map((ing) => IngredienteSeleccionado(
                nombre: ing is Ingrediente ? ing.nombre : ing.toString(),
                cantidad: '',
              ))
            .toList();
        return RecipeScreen(ingredientes: ingredientes);
      },
    };
  }
}
