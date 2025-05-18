import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fit_agent/models/recipe.dart';

class RecipeStorageService {
  static const String _favoritesKey = 'favorites_recipes';
  static const String _historyKey = 'history_recipes';
  static const int _maxHistoryItems = 10; // Máximo número de recetas en el historial

  // Guardar una receta en favoritos
  static Future<bool> addToFavorites(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtener favoritos actuales
      List<Recipe> favorites = await getFavorites();
      
      // Verificar si la receta ya está en favoritos (por título)
      if (favorites.any((r) => r.titulo == recipe.titulo)) {
        return false; // Ya existe en favoritos
      }
      
      // Añadir a favoritos
      favorites.add(recipe);
      
      // Guardar la lista actualizada
      List<String> favoritesJson = favorites.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
      
      return true;
    } catch (e) {
      print('Error al guardar en favoritos: $e');
      return false;
    }
  }

  // Eliminar una receta de favoritos
  static Future<bool> removeFromFavorites(String recipeTitle) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtener favoritos actuales
      List<Recipe> favorites = await getFavorites();
      
      // Filtrar la receta a eliminar
      favorites.removeWhere((r) => r.titulo == recipeTitle);
      
      // Guardar la lista actualizada
      List<String> favoritesJson = favorites.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_favoritesKey, favoritesJson);
      
      return true;
    } catch (e) {
      print('Error al eliminar de favoritos: $e');
      return false;
    }
  }

  // Obtener todas las recetas favoritas
  static Future<List<Recipe>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtener la lista de favoritos
      List<String>? favoritesJson = prefs.getStringList(_favoritesKey);
      
      if (favoritesJson == null || favoritesJson.isEmpty) {
        return [];
      }
      
      // Convertir de JSON a objetos Recipe
      return favoritesJson
          .map((json) => Recipe.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error al obtener favoritos: $e');
      return [];
    }
  }

  // Verificar si una receta está en favoritos
  static Future<bool> isFavorite(String recipeTitle) async {
    List<Recipe> favorites = await getFavorites();
    return favorites.any((r) => r.titulo == recipeTitle);
  }

  // Añadir una receta al historial
  static Future<bool> addToHistory(Recipe recipe) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtener historial actual
      List<Recipe> history = await getHistory();
      
      // Eliminar la receta del historial si ya existe (para moverla al principio)
      history.removeWhere((r) => r.titulo == recipe.titulo);
      
      // Añadir al principio del historial
      history.insert(0, recipe);
      
      // Limitar el tamaño del historial
      if (history.length > _maxHistoryItems) {
        history = history.sublist(0, _maxHistoryItems);
      }
      
      // Guardar la lista actualizada
      List<String> historyJson = history.map((r) => jsonEncode(r.toJson())).toList();
      await prefs.setStringList(_historyKey, historyJson);
      
      return true;
    } catch (e) {
      print('Error al guardar en historial: $e');
      return false;
    }
  }

  // Obtener el historial de recetas
  static Future<List<Recipe>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Obtener la lista del historial
      List<String>? historyJson = prefs.getStringList(_historyKey);
      
      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }
      
      // Convertir de JSON a objetos Recipe
      return historyJson
          .map((json) => Recipe.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error al obtener historial: $e');
      return [];
    }
  }

  // Limpiar el historial de recetas
  static Future<bool> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      return true;
    } catch (e) {
      print('Error al limpiar historial: $e');
      return false;
    }
  }
}
