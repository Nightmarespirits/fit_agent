import 'package:flutter/material.dart';
import 'package:fit_agent/models/recipe.dart';
import 'package:fit_agent/models/ingrediente_seleccionado.dart';
import 'package:fit_agent/services/recipe_storage_service.dart';
import 'package:fit_agent/screens/recipe_screen.dart';
import 'package:fit_agent/widgets/custom_bottom_navigation.dart';
import 'package:fit_agent/themes/app_theme.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Recipe> _favorites = [];
  List<Recipe> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    // Cargar favoritos y historial
    final favorites = await RecipeStorageService.getFavorites();
    final history = await RecipeStorageService.getHistory();

    setState(() {
      _favorites = favorites;
      _history = history;
      _isLoading = false;
    });
  }

  Future<void> _removeFromFavorites(Recipe recipe) async {
    final success = await RecipeStorageService.removeFromFavorites(recipe.titulo);
    if (success) {
      setState(() {
        _favorites.removeWhere((r) => r.titulo == recipe.titulo);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receta eliminada de favoritos')),
        );
      }
    }
  }

  Future<void> _clearHistory() async {
    final success = await RecipeStorageService.clearHistory();
    if (success) {
      setState(() {
        _history = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Historial limpiado')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Recetas'),
        backgroundColor: AppTheme.verdeMedio,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Favoritos', icon: Icon(Icons.favorite)),
            Tab(text: 'Historial', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFavoritesTab(),
                _buildHistoryTab(),
              ],
            ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildFavoritesTab() {
    if (_favorites.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No tienes recetas favoritas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Marca recetas como favoritas para verlas aquí',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecipes,
      child: ListView.builder(
        itemCount: _favorites.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) {
          final recipe = _favorites[index];
          return _buildRecipeCard(
            recipe: recipe,
            onTap: () => _openRecipe(recipe),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFromFavorites(recipe),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No hay historial de recetas',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Las recetas que veas aparecerán aquí',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecipes,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _clearHistory,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('Limpiar historial'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final recipe = _history[index];
                return _buildRecipeCard(
                  recipe: recipe,
                  onTap: () => _openRecipe(recipe),
                  trailing: Text(
                    index == 0 ? 'Última vista' : '',
                    style: const TextStyle(
                      color: AppTheme.verdeMedio,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard({
    required Recipe recipe,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen de la receta (placeholder por ahora)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  recipe.imagenUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Información de la receta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          recipe.tiempoPreparacion,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.restaurant_menu, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${recipe.ingredientesSeleccionados.length} ingredientes',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          recipe.informacionNutricional.calorias,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Botón de acción
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  void _openRecipe(Recipe recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeScreen(
          ingredientes: recipe.ingredientesSeleccionados
              .map((nombre) => IngredienteSeleccionado(nombre: nombre, cantidad: ''))
              .toList(),
          recetaExistente: recipe,
        ),
      ),
    ).then((_) => _loadRecipes());
  }
}
