import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fit_agent/models/user.dart';
import 'package:fit_agent/models/recipe.dart';
import 'package:fit_agent/repositories/user_repository.dart';
import 'package:fit_agent/repositories/recipe_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class EnhancedRecipeService {
  static final EnhancedRecipeService _instance = EnhancedRecipeService._internal();
  static const String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String modelId = 'mistralai/mistral-7b-instruct';

  final UserRepository _userRepository = UserRepository();
  final RecipeRepository _recipeRepository = RecipeRepository();

  factory EnhancedRecipeService() => _instance;

  EnhancedRecipeService._internal();

  // Verifica si hay conexión a Internet
  Future<bool> _isConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Obtiene la API key de forma segura
  Future<String?> _getApiKey() async {
    return await _userRepository.getApiKey();
  }

  // Método principal para generar receta
  Future<Recipe> generateRecipe(List<String> ingredients) async {
    try {
      // Verificar si hay conexión a internet
      if (!await _isConnected()) {
        return _generateOfflineRecipe(ingredients);
      }

      // Obtener la API key
      final String? apiKey = await _getApiKey();
      
      // Si no hay API key, usar modo offline
      if (apiKey == null || apiKey.isEmpty) {
        return _generateOfflineRecipe(ingredients);
      }

      // Obtener el perfil del usuario
      final UserProfile user = await _userRepository.loadUser();
      
      // Generar el prompt para la API
      final String prompt = await _createRecipePrompt(ingredients, user);
      
      // Preparar la solicitud
      final response = await _makeApiRequest(prompt, apiKey);
      
      // Procesar la respuesta
      return await _processApiResponse(response, ingredients, user);
    } catch (e) {
      debugPrint('Error en generación de receta: $e');
      return _generateOfflineRecipe(ingredients);
    }
  }

  // Crea el prompt para la API
  Future<String> _createRecipePrompt(List<String> ingredients, UserProfile user) async {
    // Calcular IMC si hay datos disponibles
    String bmiInfo = '';
    if (user.altura != null && user.peso != null && user.altura! > 0) {
      final double bmi =
          user.peso! / ((user.altura! / 100) * (user.altura! / 100));
      bmiInfo = 'IMC: ${bmi.toStringAsFixed(1)}';

      // Añadir recomendación basada en IMC
      if (bmi < 18.5) {
        bmiInfo +=
            ' (bajo peso). Necesita recetas con mayor aporte calórico y proteico.';
      } else if (bmi < 25) {
        bmiInfo += ' (peso normal). Necesita recetas equilibradas.';
      } else if (bmi < 30) {
        bmiInfo += ' (sobrepeso). Necesita recetas bajas en calorías y grasas.';
      } else {
        bmiInfo +=
            ' (obesidad). Necesita recetas muy bajas en calorías y grasas.';
      }
    }
    // Calcular edad si hay datos disponibles
    String ageInfo = '';
    if (user.fechaNacimiento != null) {
      final DateTime today = DateTime.now();
      int age = today.year - user.fechaNacimiento!.year;
      if (today.month < user.fechaNacimiento!.month ||
          (today.month == user.fechaNacimiento!.month &&
              today.day < user.fechaNacimiento!.day)) {
        age--;
      }
      ageInfo = 'Edad: $age años';
    }

    // Recopilar preferencias dietéticas
    List<String> preferences = [];
    if (user.vegetariano) preferences.add('vegetariano');
    if (user.vegano) preferences.add('vegano');
    if (user.sinGluten) preferences.add('sin gluten');
    if (user.sinLactosa) preferences.add('sin lactosa');

    // Añadir alergias si existen
    String allergies = '';
    if (user.alergias.isNotEmpty) {
      allergies = 'Alergias: ${user.alergias.join(', ')}';
    }

    // Tiempo máximo de preparación
    String maxPrepTime =
        'Tiempo máximo de preparación: ${user.tiempoMaximoPreparacion.round()} minutos';

    // Nivel calórico
    String calorieLevel = 'Nivel calórico preferido: ${user.nivelCalorico}';

    // Construir el prompt completo
    return '''
Crea una receta saludable utilizando los siguientes ingredientes: ${ingredients.join(', ')}.

INFORMACIÓN DEL USUARIO:
${ageInfo.isNotEmpty ? '- $ageInfo' : ''}
${bmiInfo.isNotEmpty ? '- $bmiInfo' : ''}
${preferences.isNotEmpty ? '- Preferencias dietéticas: ${preferences.join(', ')}' : ''}
${allergies.isNotEmpty ? '- $allergies' : ''}
- $maxPrepTime
- $calorieLevel

REQUISITOS DE LA RECETA:
1. Debe ser compatible con las preferencias dietéticas del usuario
2. Debe evitar cualquier ingrediente al que el usuario sea alérgico
3. Debe ajustarse a las necesidades calóricas y de salud según el IMC
4. Debe ser saludable, nutritiva y deliciosa
5. Debe ser detallada y fácil de seguir

FORMATO DE RESPUESTA:
Debes responder ÚNICAMENTE en formato JSON con la siguiente estructura exacta:
{
  "titulo": "Título creativo de la receta",
  "tiempo_preparacion": "X minutos",
  "tiempo_coccion": "X minutos",
  "dificultad": "Fácil/Media/Difícil",
  "porciones": "X porciones",
  "ingredientes": [
    {"nombre": "Ingrediente 1", "cantidad": "X unidades/gramos"},
    {"nombre": "Ingrediente 2", "cantidad": "X unidades/gramos"}
  ],
  "pasos": [
    "Paso 1: Descripción detallada",
    "Paso 2: Descripción detallada"
  ],
  "informacion_nutricional": {
    "calorias": "X kcal por porción",
    "proteinas": "X g",
    "carbohidratos": "X g",
    "grasas": "X g",
    "fibra": "X g"
  },
  "consejos": [
    "Consejo 1 para hacer la receta más saludable",
    "Consejo 2 para adaptarla a necesidades específicas"
  ],
  "beneficios_salud": [
    "Beneficio 1 para la salud",
    "Beneficio 2 para la salud"
  ]
}
''';
  }

  // Realiza la solicitud a la API
  Future<http.Response> _makeApiRequest(String prompt, String apiKey) async {
    final Map<String, dynamic> requestBody = {
      'model': modelId,
      'messages': [
        {
          'role': 'system',
          'content':
              'Eres un chef y nutricionista experto que crea recetas saludables, deliciosas y personalizadas según las necesidades del usuario. Siempre respondes en español.',
        },
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.7,
      'max_tokens': 1500,
      'response_format': {'type': 'json_object'},
    };

    // Añadir manejo de errores y reintentos
    int attempts = 0;
    const maxAttempts = 3;
    
    while (attempts < maxAttempts) {
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(requestBody),
        );
        
        // Si la solicitud es exitosa, devolver la respuesta
        if (response.statusCode == 200) {
          return response;
        }
        
        // Si es un error de autorización, no reintentar
        if (response.statusCode == 401 || response.statusCode == 403) {
          break;
        }
        
        // Incrementar intentos y esperar antes de reintentar
        attempts++;
        await Future.delayed(Duration(seconds: 2 * attempts));
      } catch (e) {
        attempts++;
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }
    
    // Si llegamos aquí, todos los intentos fallaron
    throw Exception('No se pudo conectar con la API después de $maxAttempts intentos');
  }

  // Procesa la respuesta de la API
  Future<Recipe> _processApiResponse(http.Response response, List<String> ingredients, UserProfile user) async {
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String content = data['choices'][0]['message']['content'];

      try {
        // Intentar parsear la respuesta como JSON
        final Map<String, dynamic> recipeJson = jsonDecode(content);
        
        // Crear la receta desde el JSON
        Recipe recipe = _createRecipeFromJson(recipeJson, ingredients);
        
        // Guardar la receta en la base de datos
        await _recipeRepository.saveRecipe(recipe);
        
        return recipe;
      } catch (e) {
        debugPrint('Error al parsear JSON: $e');
        // Si no es JSON válido, convertir el texto a una receta
        Recipe recipe = Recipe.fromMarkdown(content, ingredients);
        
        // Guardar la receta en la base de datos
        await _recipeRepository.saveRecipe(recipe);
        
        return recipe;
      }
    } else {
      throw Exception('Error en la API: ${response.statusCode}');
    }
  }

  // Crea una receta a partir del JSON
  Recipe _createRecipeFromJson(Map<String, dynamic> json, List<String> selectedIngredients) {
    return Recipe(
      titulo: json['titulo'] ?? 'Receta personalizada',
      tiempoPreparacion: json['tiempo_preparacion'] ?? '0 minutos',
      tiempoCoccion: json['tiempo_coccion'] ?? '0 minutos',
      dificultad: json['dificultad'] ?? 'Media',
      porciones: json['porciones'] ?? '1 porción',
      ingredientes: (json['ingredientes'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient(
                nombre: e['nombre'] ?? '',
                cantidad: e['cantidad'] ?? '',
              ))
          .toList() ??
          [],
      pasos: (json['pasos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      informacionNutricional: NutritionalInfo(
        calorias: json['informacion_nutricional']?['calorias'] ?? '0 kcal',
        proteinas: json['informacion_nutricional']?['proteinas'] ?? '0 g',
        carbohidratos: json['informacion_nutricional']?['carbohidratos'] ?? '0 g',
        grasas: json['informacion_nutricional']?['grasas'] ?? '0 g',
        fibra: json['informacion_nutricional']?['fibra'] ?? '0 g',
      ),
      consejos: (json['consejos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      beneficiosSalud: (json['beneficios_salud'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      ingredientesSeleccionados: selectedIngredients,
      imagenUrl: 'assets/images/default_recipe.png',
      isLocalImage: true,
    );
  }

  // Genera una receta en modo offline
  Recipe _generateOfflineRecipe(List<String> ingredients) {
    // Obtener recetas predefinidas
    List<Recipe> offlineRecipes = _recipeRepository.getOfflineRecipes();
    
    // Seleccionar una receta aleatoria o crear una basada en los ingredientes
    if (offlineRecipes.isNotEmpty) {
      offlineRecipes.shuffle();
      Recipe selectedRecipe = offlineRecipes.first;
      
      // Modificar la receta para incluir los ingredientes seleccionados
      return Recipe(
        titulo: "Versión offline: ${selectedRecipe.titulo}",
        tiempoPreparacion: selectedRecipe.tiempoPreparacion,
        tiempoCoccion: selectedRecipe.tiempoCoccion,
        dificultad: selectedRecipe.dificultad,
        porciones: selectedRecipe.porciones,
        ingredientes: _mergeIngredients(selectedRecipe.ingredientes, ingredients),
        pasos: selectedRecipe.pasos,
        informacionNutricional: selectedRecipe.informacionNutricional,
        consejos: [
          ...selectedRecipe.consejos,
          "Esta receta fue generada en modo offline."
        ],
        beneficiosSalud: selectedRecipe.beneficiosSalud,
        ingredientesSeleccionados: ingredients,
        imagenUrl: 'assets/images/default_recipe.png',
        isLocalImage: true,
      );
    } else {
      // Crear una receta genérica si no hay recetas predefinidas
      return Recipe(
        titulo: "Salteado con ${ingredients.isNotEmpty ? ingredients.first : 'verduras'}",
        tiempoPreparacion: "15 minutos",
        tiempoCoccion: "10 minutos",
        dificultad: "Fácil",
        porciones: "2 porciones",
        ingredientes: ingredients.map((e) => RecipeIngredient(nombre: e, cantidad: "Al gusto")).toList(),
        pasos: [
          "Prepara todos los ingredientes, lavándolos y cortándolos en trozos similares.",
          "Calienta un poco de aceite en una sartén a fuego medio-alto.",
          "Añade los ingredientes empezando por los que necesitan más cocción.",
          "Saltea durante 5-7 minutos, revolviendo ocasionalmente.",
          "Sazona al gusto con sal, pimienta y tus especias favoritas.",
          "Sirve caliente y disfruta de tu plato.",
        ],
        informacionNutricional: NutritionalInfo(
          calorias: "300 kcal",
          proteinas: "15 g",
          carbohidratos: "30 g",
          grasas: "12 g",
          fibra: "8 g",
        ),
        consejos: [
          "Esta receta fue generada en modo offline.",
          "Añade proteínas como pollo, tofu o garbanzos para una comida más completa.",
        ],
        beneficiosSalud: [
          "Rico en vitaminas y minerales esenciales.",
          "Alta en fibra para una buena digestión.",
        ],
        ingredientesSeleccionados: ingredients,
        imagenUrl: 'assets/images/default_recipe.png',
        isLocalImage: true,
      );
    }
  }

  // Combina los ingredientes de la receta con los seleccionados por el usuario
  List<RecipeIngredient> _mergeIngredients(List<RecipeIngredient> baseIngredients, List<String> selectedIngredients) {
    List<RecipeIngredient> mergedIngredients = List.from(baseIngredients);
    
    // Añadir los ingredientes seleccionados que no estén ya en la receta base
    for (String ingredient in selectedIngredients) {
      bool alreadyInList = mergedIngredients.any((i) => 
        i.nombre.toLowerCase().contains(ingredient.toLowerCase()) || 
        ingredient.toLowerCase().contains(i.nombre.toLowerCase())
      );
      
      if (!alreadyInList) {
        mergedIngredients.add(RecipeIngredient(nombre: ingredient, cantidad: "Al gusto"));
      }
    }
    
    return mergedIngredients;
  }
}