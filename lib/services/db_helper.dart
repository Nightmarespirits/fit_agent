import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fit_agent/models/user.dart';
import 'package:fit_agent/models/recipe.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  factory DBHelper() => _instance;

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fit_agent.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabla de usuarios
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        altura REAL,
        peso REAL,
        fechaNacimiento TEXT,
        vegetariano INTEGER,
        vegano INTEGER,
        sinGluten INTEGER,
        sinLactosa INTEGER,
        alergias TEXT,
        tiempoMaximoPreparacion REAL,
        nivelCalorico TEXT
      )
    ''');

    // Tabla de recetas
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT,
        tiempoPreparacion TEXT,
        tiempoCoccion TEXT,
        dificultad TEXT,
        porciones TEXT,
        informacionNutricional TEXT,
        consejos TEXT,
        beneficiosSalud TEXT,
        imagenUrl TEXT,
        contenidoMarkdown TEXT,
        ingredientesSeleccionados TEXT,
        esFavorita INTEGER DEFAULT 0,
        fechaCreacion TEXT
      )
    ''');

    // Tabla de ingredientes de recetas
    await db.execute('''
      CREATE TABLE recipe_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipeId INTEGER,
        nombre TEXT,
        cantidad TEXT,
        FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de pasos de recetas
    await db.execute('''
      CREATE TABLE recipe_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipeId INTEGER,
        paso TEXT,
        orden INTEGER,
        FOREIGN KEY (recipeId) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');
  }

  // ==================== MÉTODOS PARA USUARIO ====================

  Future<int> insertUser(UserProfile user) async {
    final db = await database;
    
    // Comprobar si ya existe un usuario
    final List<Map<String, dynamic>> users = await db.query('users');
    if (users.isNotEmpty) {
      // Si existe, actualizar en lugar de insertar
      return await updateUser(user);
    }
    
    return await db.insert(
      'users',
      {
        'nombre': user.nombre,
        'altura': user.altura,
        'peso': user.peso,
        'fechaNacimiento': user.fechaNacimiento?.toIso8601String(),
        'vegetariano': user.vegetariano ? 1 : 0,
        'vegano': user.vegano ? 1 : 0,
        'sinGluten': user.sinGluten ? 1 : 0,
        'sinLactosa': user.sinLactosa ? 1 : 0,
        'alergias': user.alergias.join(','),
        'tiempoMaximoPreparacion': user.tiempoMaximoPreparacion,
        'nivelCalorico': user.nivelCalorico,
      },
    );
  }

  Future<int> updateUser(UserProfile user) async {
    final db = await database;
    return await db.update(
      'users',
      {
        'nombre': user.nombre,
        'altura': user.altura,
        'peso': user.peso,
        'fechaNacimiento': user.fechaNacimiento?.toIso8601String(),
        'vegetariano': user.vegetariano ? 1 : 0,
        'vegano': user.vegano ? 1 : 0,
        'sinGluten': user.sinGluten ? 1 : 0,
        'sinLactosa': user.sinLactosa ? 1 : 0,
        'alergias': user.alergias.join(','),
        'tiempoMaximoPreparacion': user.tiempoMaximoPreparacion,
        'nivelCalorico': user.nivelCalorico,
      },
      where: 'id = ?',
      whereArgs: [1], // Asumimos un solo usuario
    );
  }

  Future<UserProfile> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    
    if (maps.isEmpty) {
      return UserProfile(
        nombre: '',
        altura: null,
        peso: null,
        fechaNacimiento: null,
        vegetariano: false,
        vegano: false,
        sinGluten: false,
        sinLactosa: false,
        alergias: [],
        tiempoMaximoPreparacion: 30,
        nivelCalorico: 'Medio',
      );
    }

    return UserProfile(
      nombre: maps[0]['nombre'] ?? '',
      altura: maps[0]['altura'],
      peso: maps[0]['peso'],
      fechaNacimiento: maps[0]['fechaNacimiento'] != null 
          ? DateTime.parse(maps[0]['fechaNacimiento']) 
          : null,
      vegetariano: maps[0]['vegetariano'] == 1,
      vegano: maps[0]['vegano'] == 1,
      sinGluten: maps[0]['sinGluten'] == 1,
      sinLactosa: maps[0]['sinLactosa'] == 1,
      alergias: maps[0]['alergias']?.split(',') ?? [],
      tiempoMaximoPreparacion: maps[0]['tiempoMaximoPreparacion'] ?? 30.0,
      nivelCalorico: maps[0]['nivelCalorico'] ?? 'Medio',
    );
  }

  // ==================== MÉTODOS PARA RECETAS ====================

  Future<int> insertRecipe(Recipe recipe) async {
    final db = await database;
    
    // Insertar la receta principal
    final recipeId = await db.insert(
      'recipes',
      {
        'titulo': recipe.titulo,
        'tiempoPreparacion': recipe.tiempoPreparacion,
        'tiempoCoccion': recipe.tiempoCoccion,
        'dificultad': recipe.dificultad,
        'porciones': recipe.porciones,
        'informacionNutricional': _serializeNutritionalInfo(recipe.informacionNutricional),
        'consejos': recipe.consejos.join('|||'),
        'beneficiosSalud': recipe.beneficiosSalud.join('|||'),
        'imagenUrl': recipe.imagenUrl,
        'contenidoMarkdown': recipe.contenidoMarkdown,
        'ingredientesSeleccionados': recipe.ingredientesSeleccionados.join('|||'),
        'esFavorita': 0,
        'fechaCreacion': DateTime.now().toIso8601String(),
      },
    );
    
    // Insertar los ingredientes de la receta
    for (var ingrediente in recipe.ingredientes) {
      await db.insert(
        'recipe_ingredients',
        {
          'recipeId': recipeId,
          'nombre': ingrediente.nombre,
          'cantidad': ingrediente.cantidad,
        },
      );
    }
    
    // Insertar los pasos de la receta
    for (var i = 0; i < recipe.pasos.length; i++) {
      await db.insert(
        'recipe_steps',
        {
          'recipeId': recipeId,
          'paso': recipe.pasos[i],
          'orden': i,
        },
      );
    }
    
    return recipeId;
  }

  Future<void> markAsFavorite(int recipeId, bool isFavorite) async {
    final db = await database;
    await db.update(
      'recipes',
      {'esFavorita': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [recipeId],
    );
  }

  Future<List<Recipe>> getFavoriteRecipes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'esFavorita = ?',
      whereArgs: [1],
      orderBy: 'fechaCreacion DESC',
    );
    
    return _constructRecipesFromMaps(maps);
  }

  Future<List<Recipe>> getRecentRecipes(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      orderBy: 'fechaCreacion DESC',
      limit: limit,
    );
    
    return _constructRecipesFromMaps(maps);
  }

  Future<Recipe?> getRecipeById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    
    final List<Recipe> recipes = await _constructRecipesFromMaps(maps);
    return recipes.isNotEmpty ? recipes.first : null;
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'recipes',
      where: 'titulo LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'fechaCreacion DESC',
    );
    
    return _constructRecipesFromMaps(maps);
  }

  // Método privado para construir recetas completas desde mapas de base de datos
  Future<List<Recipe>> _constructRecipesFromMaps(List<Map<String, dynamic>> maps) async {
    final List<Recipe> recipes = [];
    final db = await database;
    
    for (var map in maps) {
      // Obtener ingredientes
      final List<Map<String, dynamic>> ingredientMaps = await db.query(
        'recipe_ingredients',
        where: 'recipeId = ?',
        whereArgs: [map['id']],
      );
      
      List<RecipeIngredient> ingredientes = ingredientMaps
          .map((m) => RecipeIngredient(
                nombre: m['nombre'] ?? '',
                cantidad: m['cantidad'] ?? '',
              ))
          .toList();
      
      // Obtener pasos
      final List<Map<String, dynamic>> stepMaps = await db.query(
        'recipe_steps',
        where: 'recipeId = ?',
        whereArgs: [map['id']],
        orderBy: 'orden ASC',
      );
      
      List<String> pasos = stepMaps.map((m) => m['paso'] as String).toList();
      
      // Construir la receta completa
      recipes.add(Recipe(
        titulo: map['titulo'] ?? '',
        tiempoPreparacion: map['tiempoPreparacion'] ?? '',
        tiempoCoccion: map['tiempoCoccion'] ?? '',
        dificultad: map['dificultad'] ?? '',
        porciones: map['porciones'] ?? '',
        ingredientes: ingredientes,
        pasos: pasos,
        informacionNutricional: _deserializeNutritionalInfo(map['informacionNutricional']),
        consejos: map['consejos']?.split('|||') ?? [],
        beneficiosSalud: map['beneficiosSalud']?.split('|||') ?? [],
        ingredientesSeleccionados: map['ingredientesSeleccionados']?.split('|||') ?? [],
        contenidoMarkdown: map['contenidoMarkdown'] ?? '',
        imagenUrl: map['imagenUrl'] ?? 'assets/images/default_recipe.png',
      ));
    }
    
    return recipes;
  }

  // Serializadores para información nutricional
  String _serializeNutritionalInfo(NutritionalInfo info) {
    return '${info.calorias}|||${info.proteinas}|||${info.carbohidratos}|||${info.grasas}|||${info.fibra}';
  }

  NutritionalInfo _deserializeNutritionalInfo(String data) {
    if (data == null || data.isEmpty) {
      return NutritionalInfo(
        calorias: '0 kcal',
        proteinas: '0 g',
        carbohidratos: '0 g',
        grasas: '0 g',
        fibra: '0 g',
      );
    }

    final parts = data.split('|||');
    return NutritionalInfo(
      calorias: parts.isNotEmpty ? parts[0] : '0 kcal',
      proteinas: parts.length > 1 ? parts[1] : '0 g',
      carbohidratos: parts.length > 2 ? parts[2] : '0 g',
      grasas: parts.length > 3 ? parts[3] : '0 g',
      fibra: parts.length > 4 ? parts[4] : '0 g',
    );
  }

  // Método para eliminar completamente la base de datos (para depuración)
  Future<void> clearDatabase() async {
    String path = join(await getDatabasesPath(), 'fit_agent.db');
    await deleteDatabase(path);
    _database = null;
  }
}
