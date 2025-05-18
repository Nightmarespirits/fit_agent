import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fit_agent/models/recipe.dart';
import 'package:fit_agent/models/user.dart';
import 'package:fit_agent/models/ingrediente_seleccionado.dart';
import 'package:fit_agent/services/ai_recipe_service.dart';
import 'package:fit_agent/services/user_service.dart';
import 'package:fit_agent/services/recipe_storage_service.dart';
import 'package:fit_agent/widgets/seleccion_ingredientes.dart';
import 'package:fit_agent/widgets/custom_bottom_navigation.dart';
import 'package:fit_agent/themes/app_theme.dart';

class RecipeScreen extends StatefulWidget {
  final List<IngredienteSeleccionado>? ingredientes;
  final Recipe? recetaExistente; // Receta existente para mostrar (desde favoritos o historial)

  const RecipeScreen({Key? key, this.ingredientes, this.recetaExistente}) : super(key: key);

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  bool _isLoading = true;
  bool _loadingUserProfile = true;
  String _recipeContent = '';
  late Recipe _recipe;
  late UserProfile _userProfile;
  bool _showingPreferences = false;
  bool _isFavorite = false;
  bool _checkingFavorite = true;

  @override
  void initState() {
    super.initState();
    _cargarPerfilUsuario().then((_) {
      // Si hay una receta existente, mostrarla
      if (widget.recetaExistente != null) {
        setState(() {
          _recipe = widget.recetaExistente!;
          _recipeContent = _recipe.toMarkdown();
          _isLoading = false;
          // Verificar si está en favoritos
          _checkFavoriteStatus();
          // Añadir al historial
          RecipeStorageService.addToHistory(_recipe);
        });
      }
      // Si no hay receta existente pero hay ingredientes, generar una nueva
      else if (widget.ingredientes != null && widget.ingredientes!.isNotEmpty) {
        _generarReceta();
      } 
      // Si no hay ni receta ni ingredientes, mostrar mensaje
      else {
        setState(() {
          _isLoading = false;
          _recipeContent = '# Selecciona ingredientes\n\nVuelve a la pantalla principal y selecciona ingredientes para generar una receta.';
          _recipe = Recipe.fromMarkdown(_recipeContent, []);
          _checkingFavorite = false;
        });
      }
    });
  }
  
  Future<void> _cargarPerfilUsuario() async {
    try {
      _userProfile = await UserService.loadUser();
    } catch (e) {
      _userProfile = UserProfile.empty();
    } finally {
      setState(() {
        _loadingUserProfile = false;
      });
    }
  }

  // Método para generar la receta usando el servicio de IA
  Future<void> _generarReceta() async {
    setState(() {
      _isLoading = true;
      _checkingFavorite = true;
    });

    try {
      // Convertir IngredienteSeleccionado a nombres de ingredientes
      List<String> nombresIngredientes = [];
      if (widget.ingredientes != null) {
        nombresIngredientes = widget.ingredientes!.map((ing) => ing.nombre).toList();
      }
      
      Map<String, dynamic> recipeJson = await AIRecipeService.generarReceta(nombresIngredientes);

      setState(() {
        _recipe = Recipe.fromJson(recipeJson);
        _recipeContent = _recipe.toMarkdown();
        _isLoading = false;
      });
      
      // Verificar si la receta está en favoritos
      _checkFavoriteStatus();
      
      // Añadir al historial
      RecipeStorageService.addToHistory(_recipe);
    } catch (e) {
      setState(() {
        _recipeContent = '# Error al generar la receta\n\nHa ocurrido un error al generar la receta. Por favor, intenta nuevamente.';
        List<String> ingredientesNombres = widget.ingredientes != null 
            ? widget.ingredientes!.map((ing) => ing.nombre).toList() 
            : [];
        _recipe = Recipe.fromMarkdown(_recipeContent, ingredientesNombres);
        _isLoading = false;
        _checkingFavorite = false;
      });
    }
  }
  
  // Verificar si la receta está en favoritos
  Future<void> _checkFavoriteStatus() async {
    bool isFav = await RecipeStorageService.isFavorite(_recipe.titulo);
    setState(() {
      _isFavorite = isFav;
      _checkingFavorite = false;
    });
  }
  
  // Alternar estado de favorito
  Future<void> _toggleFavorite() async {
    setState(() {
      _checkingFavorite = true;
    });
    
    bool success;
    if (_isFavorite) {
      success = await RecipeStorageService.removeFromFavorites(_recipe.titulo);
    } else {
      success = await RecipeStorageService.addToFavorites(_recipe);
    }
    
    if (success) {
      setState(() {
        _isFavorite = !_isFavorite;
        _checkingFavorite = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Añadido a favoritos' : 'Eliminado de favoritos'),
          backgroundColor: _isFavorite ? AppTheme.verdeMedio : Colors.grey,
        ),
      );
    } else {
      setState(() {
        _checkingFavorite = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al actualizar favoritos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isLoading 
            ? const Text('Generando receta...') 
            : Text(_recipe.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generarReceta,
            tooltip: 'Regenerar receta',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'Generando tu receta saludable...',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Esto puede tomar unos segundos',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : _buildRecipeContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí podrías implementar la funcionalidad para guardar la receta
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receta guardada')),
          );
        },
        tooltip: 'Guardar receta',
        child: const Icon(Icons.favorite),
      ),
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
  
  Widget _buildRecipeContent() {
    // Si tenemos el formato antiguo (markdown), mostrar el contenido como antes
    if (_recipe.contenidoMarkdown.isNotEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la receta
            _buildRecipeImage(),
            const SizedBox(height: 20),
            
            // Ingredientes utilizados
            _buildSelectedIngredients(),
            const SizedBox(height: 20),
            
            // Contenido de la receta en markdown
            MarkdownBody(
              data: _recipeContent,
              styleSheet: MarkdownStyleSheet(
                h1: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.verdeOscuro,
                ),
                h2: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.verdeMedio,
                ),
                p: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }
    
    // Nuevo formato estructurado con mejor UX
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado con imagen y título
          _buildRecipeHeader(),
          
          // Información general
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildGeneralInfo(),
          ),
          
          const SizedBox(height: 16),
          
          // Ingredientes seleccionados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSelectedIngredients(),
          ),
          
          const SizedBox(height: 16),
          
          // Ingredientes de la receta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildIngredientsList(),
          ),
          
          const SizedBox(height: 16),
          
          // Pasos de preparación
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildStepsList(),
          ),
          
          const SizedBox(height: 16),
          
          // Información nutricional
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildNutritionalInfo(),
          ),
          
          const SizedBox(height: 16),
          
          // Consejos y beneficios
          if (_recipe.consejos.isNotEmpty || _recipe.beneficiosSalud.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTipsAndBenefits(),
            ),
            
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildRecipeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _recipe.titulo,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.verdeOscuro,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.restaurant, size: 16, color: AppTheme.verdeMedio),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Receta con ${_recipe.ingredientesSeleccionados.join(', ')}',
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildFavoriteButton(),
        ],
      ),
    );
  }
  
  Widget _buildFavoriteButton() {
    if (_checkingFavorite) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.verdeMedio),
            ),
          ),
        ),
      );
    }
    
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: _isFavorite ? Colors.red : Colors.grey,
        size: 28,
      ),
      onPressed: _toggleFavorite,
      tooltip: _isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
    );
  }
  
  Widget _buildRecipeImage() {
    return Image.network(
      _recipe.imagenUrl,
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Icon(
            Icons.restaurant,
            size: 80,
            color: Colors.grey,
          ),
        );
      },
    );
  }
  
  Widget _buildGeneralInfo() {
    // Verificar si el tiempo de preparación cumple con las preferencias del usuario
    final tiempoPreparacionMinutos = _extractMinutes(_recipe.tiempoPreparacion);
    final cumpleTiempoMaximo = tiempoPreparacionMinutos <= _userProfile.tiempoMaximoPreparacion;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.timer, 
                  'Preparación', 
                  _recipe.tiempoPreparacion,
                  destacado: cumpleTiempoMaximo,
                  mensaje: cumpleTiempoMaximo ? 'Según tus preferencias' : 'Excede tu tiempo máximo',
                ),
                _buildInfoItem(Icons.local_fire_department, 'Cocción', _recipe.tiempoCoccion),
                _buildInfoItem(
                  Icons.signal_cellular_alt, 
                  'Dificultad', 
                  _recipe.dificultad,
                ),
                _buildInfoItem(Icons.people, 'Porciones', _recipe.porciones),
              ],
            ),
            const SizedBox(height: 8),
            _buildPreferenciasChips(),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showingPreferences = !_showingPreferences;
                });
              },
              icon: Icon(_showingPreferences ? Icons.visibility_off : Icons.settings),
              label: Text(_showingPreferences ? 'Ocultar preferencias' : 'Ajustar preferencias'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.verdeMedio,
              ),
            ),
            if (_showingPreferences) _buildPreferenciasAjustes(),
          ],
        ),
      ),
    );
  }
  
  // Extraer minutos de una cadena como "30 minutos"
  int _extractMinutes(String tiempo) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(tiempo);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }
  
  // Construir chips de preferencias del usuario
  Widget _buildPreferenciasChips() {
    List<Widget> chips = [];
    
    // Añadir preferencias dietéticas
    if (_userProfile.vegetariano) {
      chips.add(_buildPreferenciaChip('Vegetariano', Icons.eco));
    }
    if (_userProfile.vegano) {
      chips.add(_buildPreferenciaChip('Vegano', Icons.spa));
    }
    if (_userProfile.sinGluten) {
      chips.add(_buildPreferenciaChip('Sin gluten', Icons.no_food));
    }
    if (_userProfile.sinLactosa) {
      chips.add(_buildPreferenciaChip('Sin lactosa', Icons.icecream));
    }
    
    // Añadir nivel calórico
    chips.add(_buildPreferenciaChip('Cal: ${_userProfile.nivelCalorico}', Icons.local_fire_department));
    
    // Añadir tiempo máximo
    chips.add(_buildPreferenciaChip('Máx: ${_userProfile.tiempoMaximoPreparacion.round()} min', Icons.timer));
    
    // Si no hay chips, mostrar mensaje
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: chips,
    );
  }
  
  Widget _buildPreferenciaChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.verdeMedio),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: AppTheme.verdeClaro.withOpacity(0.3),
      visualDensity: VisualDensity.compact,
    );
  }
  
  // Construir ajustes de preferencias
  Widget _buildPreferenciasAjustes() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.grisClaro,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ajusta tus preferencias para esta receta:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Tiempo máximo de preparación
          Row(
            children: [
              const Icon(Icons.timer, size: 18, color: AppTheme.verdeMedio),
              const SizedBox(width: 8),
              const Text('Tiempo máximo:'),
              Expanded(
                child: Slider(
                  value: _userProfile.tiempoMaximoPreparacion,
                  min: 10,
                  max: 60,
                  divisions: 10,
                  label: '${_userProfile.tiempoMaximoPreparacion.round()} min',
                  onChanged: (value) {
                    setState(() {
                      _userProfile.tiempoMaximoPreparacion = value;
                    });
                  },
                ),
              ),
              Text('${_userProfile.tiempoMaximoPreparacion.round()} min'),
            ],
          ),
          // Nivel calórico
          Row(
            children: [
              const Icon(Icons.local_fire_department, size: 18, color: AppTheme.verdeMedio),
              const SizedBox(width: 8),
              const Text('Nivel calórico:'),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: ['Bajo', 'Medio', 'Alto'].map((nivel) => ChoiceChip(
                    label: Text(nivel, style: TextStyle(
                      color: _userProfile.nivelCalorico == nivel ? Colors.white : Colors.black,
                      fontSize: 12,
                    )),
                    selected: _userProfile.nivelCalorico == nivel,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _userProfile.nivelCalorico = nivel;
                        });
                      }
                    },
                    selectedColor: AppTheme.verdeMedio,
                    backgroundColor: AppTheme.grisClaro,
                  )).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                onPressed: () async {
                  // Guardar preferencias
                  await UserService.saveUser(_userProfile);
                  setState(() {
                    _showingPreferences = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preferencias guardadas')),
                  );
                },
                child: const Text('Guardar'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Guardar y regenerar
                  UserService.saveUser(_userProfile).then((_) {
                    _generarReceta();
                    setState(() {
                      _showingPreferences = false;
                    });
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Regenerar receta'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String label, String value, {bool destacado = false, String? mensaje}) {
    return Column(
      children: [
        Icon(icon, color: destacado ? AppTheme.verdeMedio : Colors.grey),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: destacado ? AppTheme.verdeMedio : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        if (mensaje != null)
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: destacado ? AppTheme.verdeClaro : AppTheme.grisClaro,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: 10,
                color: destacado ? AppTheme.verdeOscuro : Colors.grey,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildSelectedIngredients() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingredientes seleccionados:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.verdeOscuro,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (widget.ingredientes ?? []).map((ingrediente) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: AppTheme.verdeClaro,
                    child: const Icon(Icons.food_bank, size: 14, color: Colors.white),
                  ),
                  label: Text(ingrediente.nombre),
                  backgroundColor: AppTheme.verdeClaro.withOpacity(0.3),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIngredientsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shopping_basket, color: AppTheme.verdeMedio),
                SizedBox(width: 8),
                Text(
                  'Ingredientes de la receta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.verdeOscuro,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recipe.ingredientes.length,
              itemBuilder: (context, index) {
                final ingrediente = _recipe.ingredientes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: [
                              TextSpan(
                                text: ingrediente.nombre,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ': ${ingrediente.cantidad}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStepsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.format_list_numbered, color: AppTheme.verdeMedio),
                SizedBox(width: 8),
                Text(
                  'Instrucciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.verdeOscuro,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recipe.pasos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppTheme.verdeMedio,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_recipe.pasos[index]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNutritionalInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.monitor_heart, color: AppTheme.verdeMedio),
                SizedBox(width: 8),
                Text(
                  'Información Nutricional',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.verdeOscuro,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Por porción:',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientInfo('Calorías', _recipe.informacionNutricional.calorias, Icons.local_fire_department),
                _buildNutrientInfo('Proteínas', _recipe.informacionNutricional.proteinas, Icons.fitness_center),
                _buildNutrientInfo('Carbohidratos', _recipe.informacionNutricional.carbohidratos, Icons.grain),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutrientInfo('Grasas', _recipe.informacionNutricional.grasas, Icons.opacity),
                _buildNutrientInfo('Fibra', _recipe.informacionNutricional.fibra, Icons.grass),
                const SizedBox(width: 80), // Para equilibrar la fila
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNutrientInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.verdeMedio),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildTipsAndBenefits() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recipe.consejos.isNotEmpty) ...[              
              const Row(
                children: [
                  Icon(Icons.lightbulb, color: AppTheme.naranjaAccion),
                  SizedBox(width: 8),
                  Text(
                    'Consejos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.verdeOscuro,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recipe.consejos.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 18, color: AppTheme.naranjaAccion)),
                        Expanded(child: Text(_recipe.consejos[index])),
                      ],
                    ),
                  );
                },
              ),
            ],
            if (_recipe.beneficiosSalud.isNotEmpty) ...[              
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.favorite, color: Colors.redAccent),
                  SizedBox(width: 8),
                  Text(
                    'Beneficios para la Salud',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.verdeOscuro,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _recipe.beneficiosSalud.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 18, color: Colors.redAccent)),
                        Expanded(child: Text(_recipe.beneficiosSalud[index])),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
