import 'package:fit_agent/models/recipe.dart';
import 'package:fit_agent/services/db_helper.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RecipeRepository {
  final DBHelper _dbHelper = DBHelper();
  
  // Guardar una receta generada
  Future<int> saveRecipe(Recipe recipe) async {
    return await _dbHelper.insertRecipe(recipe);
  }
  
  // Marcar receta como favorita
  Future<void> markAsFavorite(int recipeId, bool isFavorite) async {
    await _dbHelper.markAsFavorite(recipeId, isFavorite);
  }
  
  // Obtener recetas favoritas
  Future<List<Recipe>> getFavorites() async {
    return await _dbHelper.getFavoriteRecipes();
  }
  
  // Obtener historial reciente de recetas
  Future<List<Recipe>> getRecentRecipes({int limit = 10}) async {
    return await _dbHelper.getRecentRecipes(limit);
  }
  
  // Buscar recetas por texto
  Future<List<Recipe>> searchRecipes(String query) async {
    return await _dbHelper.searchRecipes(query);
  }
  
  // Obtener receta por ID
  Future<Recipe?> getRecipeById(int id) async {
    return await _dbHelper.getRecipeById(id);
  }
  
  // Verificar si hay conexión a internet
  Future<bool> isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  // Obtener recetas predefinidas para modo offline
  List<Recipe> getOfflineRecipes() {
    return [
      Recipe(
        titulo: "Ensalada mediterránea",
        tiempoPreparacion: "15 minutos",
        tiempoCoccion: "0 minutos",
        dificultad: "Fácil",
        porciones: "2 porciones",
        ingredientes: [
          RecipeIngredient(nombre: "Lechuga", cantidad: "1 unidad"),
          RecipeIngredient(nombre: "Tomate", cantidad: "2 unidades"),
          RecipeIngredient(nombre: "Pepino", cantidad: "1 unidad"),
          RecipeIngredient(nombre: "Aceitunas negras", cantidad: "50 g"),
          RecipeIngredient(nombre: "Queso feta", cantidad: "100 g"),
          RecipeIngredient(nombre: "Aceite de oliva", cantidad: "2 cucharadas"),
          RecipeIngredient(nombre: "Orégano", cantidad: "Al gusto"),
          RecipeIngredient(nombre: "Sal", cantidad: "Al gusto"),
        ],
        pasos: [
          "Lava y corta la lechuga en trozos pequeños.",
          "Corta los tomates y el pepino en cubos.",
          "Desmenuza el queso feta.",
          "Mezcla todos los ingredientes en un bowl grande.",
          "Aliña con aceite de oliva, sal y orégano al gusto."
        ],
        informacionNutricional: NutritionalInfo(
          calorias: "320 kcal",
          proteinas: "12 g",
          carbohidratos: "15 g",
          grasas: "25 g",
          fibra: "5 g",
        ),
        consejos: [
          "Puedes añadir cebolla roja para más sabor.",
          "Para una versión vegana, sustituye el queso feta por tofu firme."
        ],
        beneficiosSalud: [
          "Rica en vitaminas y minerales esenciales.",
          "Alta en grasas saludables del aceite de oliva."
        ],
        ingredientesSeleccionados: ["Lechuga", "Tomate", "Pepino", "Aceitunas"],
        imagenUrl: "assets/images/default_recipe.png",
      ),
      Recipe(
        titulo: "Batido proteico de plátano",
        tiempoPreparacion: "5 minutos",
        tiempoCoccion: "0 minutos",
        dificultad: "Fácil",
        porciones: "1 porción",
        ingredientes: [
          RecipeIngredient(nombre: "Plátano", cantidad: "1 unidad"),
          RecipeIngredient(nombre: "Leche o bebida vegetal", cantidad: "250 ml"),
          RecipeIngredient(nombre: "Proteína en polvo", cantidad: "1 cucharada"),
          RecipeIngredient(nombre: "Canela", cantidad: "1 pizca"),
          RecipeIngredient(nombre: "Miel", cantidad: "1 cucharadita (opcional)"),
        ],
        pasos: [
          "Pela y trocea el plátano.",
          "Añade todos los ingredientes a una batidora.",
          "Bate hasta conseguir una textura homogénea.",
          "Sirve inmediatamente."
        ],
        informacionNutricional: NutritionalInfo(
          calorias: "280 kcal",
          proteinas: "20 g",
          carbohidratos: "40 g",
          grasas: "5 g",
          fibra: "3 g",
        ),
        consejos: [
          "Usa plátano congelado para una textura más cremosa.",
          "Puedes añadir una cucharada de mantequilla de cacahuete para más proteínas y grasas saludables."
        ],
        beneficiosSalud: [
          "Alto en proteínas para la recuperación muscular.",
          "El plátano aporta potasio y energía natural."
        ],
        ingredientesSeleccionados: ["Plátano", "Leche"],
        imagenUrl: "assets/images/default_recipe.png",
      ),
      Recipe(
        titulo: "Pollo al limón con verduras",
        tiempoPreparacion: "15 minutos",
        tiempoCoccion: "25 minutos",
        dificultad: "Media",
        porciones: "2 porciones",
        ingredientes: [
          RecipeIngredient(nombre: "Pechugas de pollo", cantidad: "300 g"),
          RecipeIngredient(nombre: "Limón", cantidad: "1 unidad"),
          RecipeIngredient(nombre: "Pimiento", cantidad: "1 unidad"),
          RecipeIngredient(nombre: "Cebolla", cantidad: "1 unidad"),
          RecipeIngredient(nombre: "Ajo", cantidad: "2 dientes"),
          RecipeIngredient(nombre: "Aceite de oliva", cantidad: "2 cucharadas"),
          RecipeIngredient(nombre: "Tomillo", cantidad: "Al gusto"),
          RecipeIngredient(nombre: "Sal y pimienta", cantidad: "Al gusto"),
        ],
        pasos: [
          "Corta el pollo en tiras y sazona con sal, pimienta y zumo de medio limón.",
          "Corta las verduras en trozos similares.",
          "Calienta el aceite en una sartén a fuego medio-alto.",
          "Saltea el ajo picado hasta que esté fragante.",
          "Añade el pollo y cocina hasta que esté dorado (unos 5-7 minutos).",
          "Incorpora las verduras y cocina por 10 minutos más.",
          "Añade el zumo del medio limón restante y el tomillo.",
          "Cocina 5 minutos más y sirve caliente."
        ],
        informacionNutricional: NutritionalInfo(
          calorias: "350 kcal",
          proteinas: "35 g",
          carbohidratos: "15 g",
          grasas: "18 g",
          fibra: "4 g",
        ),
        consejos: [
          "Puedes marinar el pollo en el limón por 30 minutos antes para más sabor.",
          "Sirve con arroz integral o quinoa para una comida completa."
        ],
        beneficiosSalud: [
          "Alto en proteínas magras para el desarrollo muscular.",
          "Las verduras aportan fibra y micronutrientes esenciales."
        ],
        ingredientesSeleccionados: ["Pollo", "Limón", "Pimiento", "Cebolla"],
        imagenUrl: "assets/images/default_recipe.png",
      ),
    ];
  }
}
