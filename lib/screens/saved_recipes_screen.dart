import 'package:flutter/material.dart';
import 'package:fit_agent/widgets/custom_bottom_navigation.dart';
import 'package:fit_agent/themes/app_theme.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de ejemplo de recetas guardadas
    final List<Map<String, dynamic>> savedRecipes = [
      {
        'title': 'Ensalada Mediterránea',
        'ingredients': ['Tomate', 'Pepino', 'Cebolla', 'Aceitunas', 'Queso feta'],
        'time': '15 min',
        'calories': '320 kcal',
        'imageUrl': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd',
      },
      {
        'title': 'Bowl de Quinoa y Vegetales',
        'ingredients': ['Quinoa', 'Aguacate', 'Brócoli', 'Zanahoria', 'Nueces'],
        'time': '25 min',
        'calories': '420 kcal',
        'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
      },
      {
        'title': 'Smoothie de Frutas',
        'ingredients': ['Plátano', 'Fresas', 'Yogurt', 'Miel', 'Avena'],
        'time': '5 min',
        'calories': '240 kcal',
        'imageUrl': 'https://images.unsplash.com/photo-1623065422902-30a2d299bbe4',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recetas Guardadas'),
      ),
      body: savedRecipes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.no_food,
                    size: 64,
                    color: AppTheme.grisTexto,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tienes recetas guardadas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.grisTexto,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Guarda tus recetas favoritas para verlas aquí',
                    style: TextStyle(
                      color: AppTheme.grisTexto,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedRecipes.length,
              itemBuilder: (context, index) {
                final recipe = savedRecipes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen de la receta
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(recipe['imageUrl']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Título de la receta
                            Text(
                              recipe['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.verdeOscuro,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Información de tiempo y calorías
                            Row(
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: AppTheme.grisTexto,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  recipe['time'],
                                  style: const TextStyle(
                                    color: AppTheme.grisTexto,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.local_fire_department_outlined,
                                  size: 16,
                                  color: AppTheme.grisTexto,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  recipe['calories'],
                                  style: const TextStyle(
                                    color: AppTheme.grisTexto,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Ingredientes (mostrar solo los 3 primeros)
                            const Text(
                              'Ingredientes:',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (recipe['ingredients'] as List)
                                  .take(3)
                                  .join(', ') +
                                  (recipe['ingredients'].length > 3
                                      ? ' y ${recipe['ingredients'].length - 3} más'
                                      : ''),
                              style: const TextStyle(
                                color: AppTheme.grisTexto,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Botones de acción
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    // Ver receta completa
                                  },
                                  icon: const Icon(Icons.visibility),
                                  label: const Text('Ver'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.azulBoton,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () {
                                    // Eliminar de favoritos
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Receta eliminada de favoritos'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.favorite),
                                  label: const Text('Eliminar'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.rojoAlerta,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}
