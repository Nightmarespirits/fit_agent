class RecipeIngredient {
  final String nombre;
  final String cantidad;

  RecipeIngredient({required this.nombre, required this.cantidad});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      nombre: json['nombre'] ?? '',
      cantidad: json['cantidad'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'cantidad': cantidad,
  };
}

class NutritionalInfo {
  final String calorias;
  final String proteinas;
  final String carbohidratos;
  final String grasas;
  final String fibra;

  NutritionalInfo({
    required this.calorias,
    required this.proteinas,
    required this.carbohidratos,
    required this.grasas,
    required this.fibra,
  });

  factory NutritionalInfo.fromJson(Map<String, dynamic> json) {
    return NutritionalInfo(
      calorias: json['calorias'] ?? '0 kcal',
      proteinas: json['proteinas'] ?? '0 g',
      carbohidratos: json['carbohidratos'] ?? '0 g',
      grasas: json['grasas'] ?? '0 g',
      fibra: json['fibra'] ?? '0 g',
    );
  }

  Map<String, dynamic> toJson() => {
    'calorias': calorias,
    'proteinas': proteinas,
    'carbohidratos': carbohidratos,
    'grasas': grasas,
    'fibra': fibra,
  };
}

class Recipe {
  final String titulo;
  final String tiempoPreparacion;
  final String tiempoCoccion;
  final String dificultad;
  final String porciones;
  final List<RecipeIngredient> ingredientes;
  final List<String> pasos;
  final NutritionalInfo informacionNutricional;
  final List<String> consejos;
  final List<String> beneficiosSalud;
  final String imagenUrl;
  final String contenidoMarkdown; // Para compatibilidad con versiones anteriores
  final List<String> ingredientesSeleccionados; // Ingredientes seleccionados por el usuario

  Recipe({
    required this.titulo,
    required this.tiempoPreparacion,
    required this.tiempoCoccion,
    required this.dificultad,
    required this.porciones,
    required this.ingredientes,
    required this.pasos,
    required this.informacionNutricional,
    required this.consejos,
    required this.beneficiosSalud,
    required this.ingredientesSeleccionados,
    this.contenidoMarkdown = '',
    this.imagenUrl = 'https://cdn-icons-png.flaticon.com/512/3565/3565418.png',
  });

  // Propiedad para compatibilidad con código existente
  String get title => titulo;
  String get content => contenidoMarkdown;

  // Método para crear una receta a partir de JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> ingredientesSeleccionados = [];
    if (json['ingredientes_seleccionados'] != null) {
      ingredientesSeleccionados = (json['ingredientes_seleccionados'] as List<dynamic>)
          .map((e) => e.toString())
          .toList();
    }
    return Recipe(
      titulo: json['titulo'] ?? 'Receta Saludable',
      tiempoPreparacion: json['tiempo_preparacion'] ?? '0 minutos',
      tiempoCoccion: json['tiempo_coccion'] ?? '0 minutos',
      dificultad: json['dificultad'] ?? 'Media',
      porciones: json['porciones'] ?? '1 porción',
      ingredientes: (json['ingredientes'] as List<dynamic>?)
          ?.map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      pasos: (json['pasos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      informacionNutricional: json['informacion_nutricional'] != null
          ? NutritionalInfo.fromJson(json['informacion_nutricional'] as Map<String, dynamic>)
          : NutritionalInfo(
              calorias: '0 kcal',
              proteinas: '0 g',
              carbohidratos: '0 g',
              grasas: '0 g',
              fibra: '0 g',
            ),
      consejos: (json['consejos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      beneficiosSalud: (json['beneficios_salud'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      ingredientesSeleccionados: ingredientesSeleccionados,
    );
  }

  // Método para crear una receta a partir del contenido markdown (para compatibilidad)
  factory Recipe.fromMarkdown(String markdownContent, List<String> ingredientes) {
    final title = extractTitle(markdownContent);
    
    // Crear una versión simplificada para mantener compatibilidad
    return Recipe(
      titulo: title,
      tiempoPreparacion: 'N/A',
      tiempoCoccion: 'N/A',
      dificultad: 'Media',
      porciones: '2 porciones',
      ingredientes: ingredientes.map((e) => RecipeIngredient(nombre: e, cantidad: 'Al gusto')).toList(),
      pasos: ['Ver receta completa abajo'],
      informacionNutricional: NutritionalInfo(
        calorias: 'N/A',
        proteinas: 'N/A',
        carbohidratos: 'N/A',
        grasas: 'N/A',
        fibra: 'N/A',
      ),
      consejos: [],
      beneficiosSalud: [],
      ingredientesSeleccionados: ingredientes,
      contenidoMarkdown: markdownContent,
    );
  }

  // Método para extraer el título de la receta del contenido markdown
  static String extractTitle(String markdownContent) {
    final lines = markdownContent.split('\n');
    for (final line in lines) {
      if (line.startsWith('# ')) {
        return line.substring(2).trim();
      }
    }
    return 'Receta Saludable';
  }

  // Convertir la receta a formato markdown para compatibilidad
  String toMarkdown() {
    if (contenidoMarkdown.isNotEmpty) {
      return contenidoMarkdown;
    }

    final buffer = StringBuffer();
    
    // Título
    buffer.writeln('# $titulo\n');
    
    // Información general
    buffer.writeln('**Tiempo de preparación:** $tiempoPreparacion');
    buffer.writeln('**Tiempo de cocción:** $tiempoCoccion');
    buffer.writeln('**Dificultad:** $dificultad');
    buffer.writeln('**Porciones:** $porciones\n');
    
    // Ingredientes
    buffer.writeln('## Ingredientes');
    for (final ingrediente in ingredientes) {
      buffer.writeln('- ${ingrediente.nombre}: ${ingrediente.cantidad}');
    }
    buffer.writeln();
    
    // Pasos
    buffer.writeln('## Instrucciones');
    for (int i = 0; i < pasos.length; i++) {
      buffer.writeln('${i + 1}. ${pasos[i]}');
    }
    buffer.writeln();
    
    // Información nutricional
    buffer.writeln('## Información Nutricional (por porción)');
    buffer.writeln('- **Calorías:** ${informacionNutricional.calorias}');
    buffer.writeln('- **Proteínas:** ${informacionNutricional.proteinas}');
    buffer.writeln('- **Carbohidratos:** ${informacionNutricional.carbohidratos}');
    buffer.writeln('- **Grasas:** ${informacionNutricional.grasas}');
    buffer.writeln('- **Fibra:** ${informacionNutricional.fibra}\n');
    
    // Consejos
    if (consejos.isNotEmpty) {
      buffer.writeln('## Consejos');
      for (final consejo in consejos) {
        buffer.writeln('- $consejo');
      }
      buffer.writeln();
    }
    
    // Beneficios para la salud
    if (beneficiosSalud.isNotEmpty) {
      buffer.writeln('## Beneficios para la Salud');
      for (final beneficio in beneficiosSalud) {
        buffer.writeln('- $beneficio');
      }
    }
    
    return buffer.toString();
  }
  
  // Convertir la receta a JSON para almacenamiento
  Map<String, dynamic> toJson() => {
    'titulo': titulo,
    'tiempo_preparacion': tiempoPreparacion,
    'tiempo_coccion': tiempoCoccion,
    'dificultad': dificultad,
    'porciones': porciones,
    'ingredientes': ingredientes.map((i) => i.toJson()).toList(),
    'pasos': pasos,
    'informacion_nutricional': informacionNutricional.toJson(),
    'consejos': consejos,
    'beneficios_salud': beneficiosSalud,
    'imagen_url': imagenUrl,
    'contenido_markdown': contenidoMarkdown,
    'ingredientes_seleccionados': ingredientesSeleccionados,
  };
}
