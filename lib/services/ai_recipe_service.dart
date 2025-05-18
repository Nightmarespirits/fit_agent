import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fit_agent/models/user.dart';
import 'package:fit_agent/services/user_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio genérico para generación de recetas con IA
class AIRecipeService {
  // URL de la API - Actualmente usando OpenRouter para acceder a diferentes modelos
  static const String apiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  // API key 
  static String get apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';

  // Modelo de IA a utilizar
  static const String modelId = 'mistralai/mistral-7b-instruct';

  /// Genera una receta personalizada basada en ingredientes y perfil del usuario
  static Future<Map<String, dynamic>> generarReceta(List<String> ingredientes) async {
    try {
      // Obtener el perfil del usuario para personalizar la receta
      final UserProfile usuario = await UserService.loadUser();
      
      // Crear el prompt para la generación de receta
      final String prompt = await _crearPromptReceta(ingredientes, usuario);
      
      // Preparar la solicitud para la API
      final Map<String, dynamic> requestBody = {
        'model': modelId,
        'messages': [
          {
            'role': 'system',
            'content': 'Eres un chef y nutricionista experto que crea recetas saludables, deliciosas y personalizadas según las necesidades del usuario. Siempre respondes en español.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'temperature': 0.7,
        'max_tokens': 1500,
        'response_format': {'type': 'json_object'},
      };

      // Realizar la solicitud HTTP
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(requestBody),
      );

      // Verificar la respuesta
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String contenido = data['choices'][0]['message']['content'];
        
        try {
          // Intentar parsear la respuesta como JSON
          final Map<String, dynamic> recetaJson = jsonDecode(contenido);
          return recetaJson;
        } catch (e) {
          // Si no es JSON válido, devolver un mapa con el contenido como markdown
          return {
            'titulo': 'Receta personalizada',
            'contenido': contenido,
            'formato': 'markdown'
          };
        }
      } else {
        // Devolver una receta de ejemplo si hay error
        return _generarRecetaEjemplo(ingredientes, usuario);
      }
    } catch (e) {
      // Devolver una receta de ejemplo si hay error
      return _generarRecetaEjemplo(ingredientes, await UserService.loadUser());
    }
  }

  /// Crea un prompt personalizado para la generación de receta
  static Future<String> _crearPromptReceta(List<String> ingredientes, UserProfile usuario) async {
    // Calcular IMC si hay datos disponibles
    String infoIMC = '';
    if (usuario.altura != null && usuario.peso != null && usuario.altura! > 0) {
      final double imc = usuario.peso! / ((usuario.altura! / 100) * (usuario.altura! / 100));
      infoIMC = 'IMC: ${imc.toStringAsFixed(1)}';
      
      // Añadir recomendación basada en IMC
      if (imc < 18.5) {
        infoIMC += ' (bajo peso). Necesita recetas con mayor aporte calórico y proteico.';
      } else if (imc < 25) {
        infoIMC += ' (peso normal). Necesita recetas equilibradas.';
      } else if (imc < 30) {
        infoIMC += ' (sobrepeso). Necesita recetas bajas en calorías y grasas.';
      } else {
        infoIMC += ' (obesidad). Necesita recetas muy bajas en calorías y grasas.';
      }
    }
    
    // Calcular edad si hay datos disponibles
    String infoEdad = '';
    if (usuario.fechaNacimiento != null) {
      final DateTime hoy = DateTime.now();
      int edad = hoy.year - usuario.fechaNacimiento!.year;
      if (hoy.month < usuario.fechaNacimiento!.month || 
          (hoy.month == usuario.fechaNacimiento!.month && hoy.day < usuario.fechaNacimiento!.day)) {
        edad--;
      }
      infoEdad = 'Edad: $edad años';
    }
    
    // Recopilar preferencias dietéticas
    List<String> preferencias = [];
    if (usuario.vegetariano) preferencias.add('vegetariano');
    if (usuario.vegano) preferencias.add('vegano');
    if (usuario.sinGluten) preferencias.add('sin gluten');
    if (usuario.sinLactosa) preferencias.add('sin lactosa');
    
    // Añadir alergias si existen
    String alergias = '';
    if (usuario.alergias.isNotEmpty) {
      alergias = 'Alergias: ${usuario.alergias.join(', ')}';
    }
    
    // Tiempo máximo de preparación
    String tiempoMaximo = 'Tiempo máximo de preparación: ${usuario.tiempoMaximoPreparacion.round()} minutos';
    
    // Nivel calórico
    String nivelCalorico = 'Nivel calórico preferido: ${usuario.nivelCalorico}';
    
    // Calcular necesidades calóricas aproximadas (fórmula simplificada)
    String necesidadesCaloricas = '';
    if (usuario.peso != null && usuario.altura != null && usuario.fechaNacimiento != null) {
      final DateTime hoy = DateTime.now();
      int edad = hoy.year - usuario.fechaNacimiento!.year;
      if (hoy.month < usuario.fechaNacimiento!.month || 
          (hoy.month == usuario.fechaNacimiento!.month && hoy.day < usuario.fechaNacimiento!.day)) {
        edad--;
      }
      
      // Fórmula simplificada (Harris-Benedict)
      double tmb = 0; // Tasa Metabólica Basal
      
      // Asumimos género basado en nombre (muy simplificado, en una app real se pediría el género)
      bool esHombre = !usuario.nombre.toLowerCase().endsWith('a'); // Simplificación
      
      if (esHombre) {
        tmb = 66.5 + (13.75 * usuario.peso!) + (5.003 * usuario.altura!) - (6.75 * edad);
      } else {
        tmb = 655.1 + (9.563 * usuario.peso!) + (1.850 * usuario.altura!) - (4.676 * edad);
      }
      
      // Factor de actividad (asumimos moderado)
      double factorActividad = 1.55;
      double caloriasDiarias = tmb * factorActividad;
      
      // Ajustar según IMC
      if (usuario.altura! > 0) {
        final double imc = usuario.peso! / ((usuario.altura! / 100) * (usuario.altura! / 100));
        if (imc > 25) {
          // Reducir para pérdida de peso
          caloriasDiarias *= 0.85;
        } else if (imc < 18.5) {
          // Aumentar para ganancia de peso
          caloriasDiarias *= 1.15;
        }
      }
      
      necesidadesCaloricas = 'Necesidades calóricas diarias aproximadas: ${caloriasDiarias.round()} kcal';
    }

    // Construir el prompt completo
    return '''
Crea una receta saludable utilizando los siguientes ingredientes: ${ingredientes.join(', ')}.

INFORMACIÓN DEL USUARIO:
${infoEdad.isNotEmpty ? '- $infoEdad' : ''}
${infoIMC.isNotEmpty ? '- $infoIMC' : ''}
${preferencias.isNotEmpty ? '- Preferencias dietéticas: ${preferencias.join(', ')}' : ''}
${alergias.isNotEmpty ? '- $alergias' : ''}
- $tiempoMaximo
- Nivel calórico: ${usuario.nivelCalorico}
${necesidadesCaloricas.isNotEmpty ? '- $necesidadesCaloricas' : ''}

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

IMPORTANTE: La respuesta DEBE ser un objeto JSON válido con la estructura exacta indicada arriba. No incluyas texto adicional fuera del JSON.
''';
  }

  /// Genera una receta de ejemplo cuando hay errores
  static Map<String, dynamic> _generarRecetaEjemplo(List<String> ingredientes, UserProfile usuario) {
    // Ajustar la receta según preferencias
    bool esVegetariano = usuario.vegetariano || usuario.vegano;
    
    // Título personalizado
    String titulo = esVegetariano 
        ? "Salteado Vegetariano de ${ingredientes.first}"
        : "Salteado de ${ingredientes.first} con Verduras";
    
    // Lista de ingredientes personalizada
    List<Map<String, String>> listaIngredientes = [];
    
    // Añadir ingredientes seleccionados
    for (String ingrediente in ingredientes) {
      listaIngredientes.add({
        "nombre": ingrediente,
        "cantidad": "100 g"
      });
    }
    
    // Añadir ingredientes base
    listaIngredientes.addAll([
      {"nombre": "Aceite de oliva", "cantidad": "1 cucharada"},
      {"nombre": "Ajo", "cantidad": "2 dientes"},
      {"nombre": "Sal", "cantidad": "al gusto"},
      {"nombre": "Pimienta", "cantidad": "al gusto"},
      {"nombre": "Jugo de limón", "cantidad": "1 cucharada (opcional)"}
    ]);
    
    // Ajustar calorías según IMC
    String calorias = "300";
    if (usuario.altura != null && usuario.peso != null && usuario.altura! > 0) {
      final double imc = usuario.peso! / ((usuario.altura! / 100) * (usuario.altura! / 100));
      if (imc > 25) {
        calorias = "250"; // Menos calorías para sobrepeso
      } else if (imc < 18.5) {
        calorias = "400"; // Más calorías para bajo peso
      }
    }
    
    // Generar la receta completa
    return {
      "titulo": titulo,
      "tiempo_preparacion": "10 minutos",
      "tiempo_coccion": "10 minutos",
      "dificultad": "Fácil",
      "porciones": "2 porciones",
      "ingredientes": listaIngredientes,
      "pasos": [
        "Paso 1: Lava y corta todos los ingredientes en trozos pequeños.",
        "Paso 2: Calienta el aceite en una sartén a fuego medio.",
        "Paso 3: Añade el ajo picado y saltea por 30 segundos hasta que esté fragante.",
        "Paso 4: Agrega los ingredientes y saltea por 5-7 minutos, revolviendo ocasionalmente.",
        "Paso 5: Sazona con sal y pimienta al gusto.",
        "Paso 6: Añade el jugo de limón si deseas un toque cítrico.",
        "Paso 7: Sirve caliente y disfruta."
      ],
      "informacion_nutricional": {
        "calorias": "$calorias kcal por porción",
        "proteinas": "15 g",
        "carbohidratos": "25 g",
        "grasas": "10 g",
        "fibra": "5 g"
      },
      "consejos": [
        "Usa aceite de oliva en spray para reducir las calorías.",
        "Añade más verduras para aumentar el valor nutricional.",
        "Sirve con una porción de granos integrales para una comida completa."
      ],
      "beneficios_salud": [
        "Rico en vitaminas y minerales esenciales.",
        "Bajo en grasas saturadas y azúcares añadidos.",
        "Proporciona fibra para una buena digestión."
      ]
    };
  }
}
