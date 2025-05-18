import 'package:flutter/material.dart';
import 'package:fit_agent/models/menu_option.dart';
import 'package:fit_agent/screens/screens.dart';
import 'package:fit_agent/screens/favorites_screen.dart';
import 'package:fit_agent/screens/preferences_screen.dart';

class MainRoutes {
  static final menuOptions = <MenuOption>[
    MenuOption(
      nombre: "Home",
      ruta: "home",
      icono: Icon(Icons.home),
      screen: HomeScreen(),
    ),
    MenuOption(
      nombre: "Favoritos",
      ruta: "favorites",
      icono: Icon(Icons.favorite),
      screen: FavoritesScreen(),
    ),
    MenuOption(
      nombre: "Perfil",
      ruta: "profile",
      icono: Icon(Icons.person),
      screen: ProfileScreen(),
    ),
    MenuOption(
      nombre: "Preferencias",
      ruta: "preferences",
      icono: Icon(Icons.settings),
      screen: PreferencesScreen(),
    ),
  ];
}
