import 'package:flutter/material.dart';
import 'package:fit_agent/widgets/custom_bottom_navigation.dart';
import 'package:fit_agent/themes/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de historial de recetas generadas (ejemplo)
    final List<Map<String, dynamic>> recipeHistory = [
      {
        'title': 'Pasta de Vegetales',
        'date': '15 May 2025',
        'ingredients': ['Pasta integral', 'Calabacín', 'Tomate', 'Albahaca'],
      },
      {
        'title': 'Desayuno Proteico',
        'date': '12 May 2025',
        'ingredients': ['Huevo', 'Espinacas', 'Champiñones', 'Queso'],
      },
      {
        'title': 'Batido Verde',
        'date': '10 May 2025',
        'ingredients': ['Espinaca', 'Manzana', 'Jengibre', 'Limón'],
      },
      {
        'title': 'Wok de Verduras',
        'date': '07 May 2025',
        'ingredients': ['Brócoli', 'Zanahoria', 'Pimiento', 'Arroz integral'],
      },
      {
        'title': 'Ensalada de Quinoa',
        'date': '04 May 2025',
        'ingredients': ['Quinoa', 'Aguacate', 'Tomate', 'Pepino'],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Recetas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              // Mostrar diálogo de confirmación para borrar historial
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Borrar historial'),
                  content: const Text('¿Estás seguro que deseas borrar todo tu historial de recetas?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Historial borrado'),
                          ),
                        );
                      },
                      child: const Text('Borrar'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.rojoAlerta,
                      ),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Borrar historial',
          ),
        ],
      ),
      body: recipeHistory.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppTheme.grisTexto,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay historial de recetas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.grisTexto,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Las recetas que generes aparecerán aquí',
                    style: TextStyle(
                      color: AppTheme.grisTexto,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipeHistory.length,
              itemBuilder: (context, index) {
                final recipe = recipeHistory[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    title: Text(
                      recipe['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.verdeOscuro,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          'Fecha: ${recipe['date']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.grisTexto,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ingredientes: ${(recipe['ingredients'] as List).join(', ')}',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            color: AppTheme.verdeMedio,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Receta añadida a favoritos'),
                              ),
                            );
                          },
                          tooltip: 'Guardar receta',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.open_in_new,
                            color: AppTheme.azulBoton,
                          ),
                          onPressed: () {
                            // Navegar a la receta
                          },
                          tooltip: 'Ver receta',
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navegar a la pantalla de detalle de la receta
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
