//El home Screen por ahora sera la pantalla de generar recetas para agilizar MVP
import 'package:flutter/material.dart';
import 'package:fit_agent/widgets/seleccion_ingredientes.dart';
import 'package:fit_agent/widgets/ingredientes_seleccionados.dart';
import 'package:fit_agent/themes/app_theme.dart';
import 'package:fit_agent/screens/recipe_screen.dart';
import 'package:fit_agent/widgets/custom_bottom_navigation.dart';
import 'package:fit_agent/models/ingrediente_seleccionado.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Lista de ingredientes seleccionados
  final List<Ingrediente> _ingredientesSeleccionados = [];

  // Método para agregar un ingrediente a la lista
  void _agregarIngrediente(Ingrediente ingrediente) {
    // Verificar si el ingrediente ya está en la lista
    if (!_ingredientesSeleccionados.contains(ingrediente)) {
      setState(() {
        _ingredientesSeleccionados.add(ingrediente);
      });
    }
  }

  // Método para eliminar un ingrediente de la lista
  void _eliminarIngrediente(Ingrediente ingrediente) {
    setState(() {
      _ingredientesSeleccionados.remove(ingrediente);
    });
  }

  // Método para generar la receta
  void _generarReceta() {
    if (_ingredientesSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona al menos un ingrediente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Convertir los ingredientes al nuevo formato
    final ingredientesParaReceta = _ingredientesSeleccionados
        .map((ing) => IngredienteSeleccionado(
              nombre: ing.nombre,
              cantidad: '',
            ))
        .toList();
    
    // Navegar directamente a la pantalla de receta
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeScreen(ingredientes: ingredientesParaReceta),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FIT Agent - Recetas Saludables'),
        backgroundColor: AppTheme.verdeMedio,
      ),
      body: Column(
        children: [
          // Sección superior para selección de ingredientes (2/3 de la pantalla)
          Expanded(
            flex: 2,
            child: SeleccionIngredientes(
              onIngredienteSeleccionado: _agregarIngrediente,
            ),
          ),
          // Sección inferior para ingredientes seleccionados (1/3 de la pantalla)
          Expanded(
            flex: 1,
            child: IngredientesSeleccionados(
              ingredientes: _ingredientesSeleccionados,
              onRemoveIngrediente: _eliminarIngrediente,
              onGenerarReceta: _generarReceta,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 0),
    );
  }
}
