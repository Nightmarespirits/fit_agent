import 'package:flutter/widgets.dart';

class MenuOption {
  final String ruta;
  final Icon icono;
  final String nombre;
  final Widget screen;

  MenuOption({
    required this.nombre,
    required this.ruta,
    required this.icono,
    required this.screen,
  });

  @override
  String toString() => nombre;
}
