import 'package:flutter/material.dart';
import 'package:fit_agent/themes/app_theme.dart';

class Ingrediente {
  final String nombre;
  final String imagen;
  final String categoria; // Categoría del ingrediente
  final bool esPersonalizado; // Para identificar ingredientes personalizados

  Ingrediente({
    required this.nombre, 
    required this.imagen,
    this.categoria = 'Otros',
    this.esPersonalizado = false,
  });
}

class SeleccionIngredientes extends StatefulWidget {
  //Metodo para capturar el ingrediente seleccionado
  final Function(Ingrediente) onIngredienteSeleccionado;

  const SeleccionIngredientes({
    super.key,
    required this.onIngredienteSeleccionado,
  });
  
  @override
  State<SeleccionIngredientes> createState() => _SeleccionIngredientesState();
}

class _SeleccionIngredientesState extends State<SeleccionIngredientes> {
  // Controlador para el campo de texto
  final TextEditingController _ingredienteController = TextEditingController();
  
  // Controlador para el FocusNode
  final FocusNode _focusNode = FocusNode();
  
  // Variable para controlar la visibilidad del campo de búsqueda
  bool _mostrarCampoBusqueda = false;
  
  // Término de búsqueda
  String _terminoBusqueda = '';
  
  @override
  void dispose() {
    _ingredienteController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  // Lista de ingredientes disponibles
  static final List<Ingrediente> ingredientesDisponibles = [
    // Proteínas
    Ingrediente(
      nombre: 'Pollo',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1046/1046751.png',
      categoria: 'Proteínas',
    ),
    Ingrediente(
      nombre: 'Pescado',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1999/1999823.png',
      categoria: 'Proteínas',
    ),
    Ingrediente(
      nombre: 'Carne de res',
      imagen: 'https://cdn-icons-png.flaticon.com/512/3143/3143643.png',
      categoria: 'Proteínas',
    ),
    Ingrediente(
      nombre: 'Cerdo',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1046/1046769.png',
      categoria: 'Proteínas',
    ),
    Ingrediente(
      nombre: 'Huevo',
      imagen: 'https://cdn-icons-png.flaticon.com/512/837/837560.png',
      categoria: 'Proteínas',
    ),
    Ingrediente(
      nombre: 'Tofu',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2515/2515263.png',
      categoria: 'Proteínas',
    ),
    Ingrediente(
      nombre: 'Lentejas',
      imagen: 'https://cdn-icons-png.flaticon.com/512/6124/6124589.png',
      categoria: 'Proteínas',
    ),
    Ingrediente(
      nombre: 'Garbanzos',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2548/2548440.png',
      categoria: 'Proteínas',
    ),
    
    // Cereales y almidones
    Ingrediente(
      nombre: 'Arroz',
      imagen: 'https://cdn-icons-png.flaticon.com/512/3082/3082051.png',
      categoria: 'Cereales y almidones',
    ),
    Ingrediente(
      nombre: 'Pasta',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2518/2518176.png',
      categoria: 'Cereales y almidones',
    ),
    Ingrediente(
      nombre: 'Quinoa',
      imagen: 'https://cdn-icons-png.flaticon.com/512/6978/6978195.png',
      categoria: 'Cereales y almidones',
    ),
    Ingrediente(
      nombre: 'Avena',
      imagen: 'https://cdn-icons-png.flaticon.com/512/3823/3823564.png',
      categoria: 'Cereales y almidones',
    ),
    Ingrediente(
      nombre: 'Papa',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1135/1135448.png',
      categoria: 'Cereales y almidones',
    ),
    Ingrediente(
      nombre: 'Batata',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2346/2346782.png',
      categoria: 'Cereales y almidones',
    ),
    
    // Verduras
    Ingrediente(
      nombre: 'Tomate',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1412/1412511.png',
      categoria: 'Verduras',
    ),
    Ingrediente(
      nombre: 'Lechuga',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2909/2909841.png',
      categoria: 'Verduras',
    ),
    Ingrediente(
      nombre: 'Zanahoria',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2224/2224265.png',
      categoria: 'Verduras',
    ),
    Ingrediente(
      nombre: 'Cebolla',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1147/1147801.png',
      categoria: 'Verduras',
    ),
    Ingrediente(
      nombre: 'Pimiento',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2909/2909761.png',
      categoria: 'Verduras',
    ),
    Ingrediente(
      nombre: 'Brócoli',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2346/2346952.png',
      categoria: 'Verduras',
    ),
    Ingrediente(
      nombre: 'Espinaca',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1147/1147832.png',
      categoria: 'Verduras',
    ),
    Ingrediente(
      nombre: 'Calabacín',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2909/2909844.png',
      categoria: 'Verduras',
    ),
    Ingrediente(
      nombre: 'Berenjena',
      imagen: 'https://cdn-icons-png.flaticon.com/512/5346/5346400.png',
      categoria: 'Verduras',
    ),
    Ingrediente(
      nombre: 'Champiñones',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1147/1147805.png',
      categoria: 'Verduras',
    ),
    
    // Frutas
    Ingrediente(
      nombre: 'Manzana',
      imagen: 'https://cdn-icons-png.flaticon.com/512/415/415682.png',
      categoria: 'Frutas',
    ),
    Ingrediente(
      nombre: 'Plátano',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2909/2909761.png',
      categoria: 'Frutas',
    ),
    Ingrediente(
      nombre: 'Naranja',
      imagen: 'https://cdn-icons-png.flaticon.com/512/415/415733.png',
      categoria: 'Frutas',
    ),
    Ingrediente(
      nombre: 'Fresa',
      imagen: 'https://cdn-icons-png.flaticon.com/512/590/590772.png',
      categoria: 'Frutas',
    ),
    Ingrediente(
      nombre: 'Aguacate',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2909/2909761.png',
      categoria: 'Frutas',
    ),
    Ingrediente(
      nombre: 'Limón',
      imagen: 'https://cdn-icons-png.flaticon.com/512/415/415735.png',
      categoria: 'Frutas',
    ),
    
    // Lácteos y alternativas
    Ingrediente(
      nombre: 'Leche',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2674/2674486.png',
      categoria: 'Lácteos',
    ),
    Ingrediente(
      nombre: 'Yogur',
      imagen: 'https://cdn-icons-png.flaticon.com/512/3076/3076046.png',
      categoria: 'Lácteos',
    ),
    Ingrediente(
      nombre: 'Queso',
      imagen: 'https://cdn-icons-png.flaticon.com/512/3076/3076031.png',
      categoria: 'Lácteos',
    ),
    Ingrediente(
      nombre: 'Leche de almendras',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2405/2405562.png',
      categoria: 'Lácteos',
    ),
    
    // Condimentos y especias
    Ingrediente(
      nombre: 'Ajo',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1147/1147809.png',
      categoria: 'Condimentos',
    ),
    Ingrediente(
      nombre: 'Jengibre',
      imagen: 'https://cdn-icons-png.flaticon.com/512/2909/2909841.png',
      categoria: 'Condimentos',
    ),
    Ingrediente(
      nombre: 'Cilantro',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1147/1147832.png',
      categoria: 'Condimentos',
    ),
    Ingrediente(
      nombre: 'Albahaca',
      imagen: 'https://cdn-icons-png.flaticon.com/512/1147/1147832.png',
      categoria: 'Condimentos',
    ),
  ];

  // Obtener las categorías únicas de los ingredientes
  List<String> _obtenerCategorias() {
    final categorias = ingredientesDisponibles
        .map((ingrediente) => ingrediente.categoria)
        .toSet()
        .toList();
    categorias.sort(); // Ordenar alfabéticamente
    return categorias;
  }
  
  // Método para filtrar ingredientes según el término de búsqueda
  Map<String, List<Ingrediente>> _filtrarIngredientesPorCategoria() {
    final Map<String, List<Ingrediente>> resultado = {};
    final List<Ingrediente> ingredientesFiltrados;
    
    // Filtrar por término de búsqueda si existe
    if (_terminoBusqueda.isEmpty) {
      ingredientesFiltrados = List.from(ingredientesDisponibles);
    } else {
      ingredientesFiltrados = ingredientesDisponibles
          .where((ingrediente) => 
            ingrediente.nombre.toLowerCase().contains(_terminoBusqueda.toLowerCase()))
          .toList();
    }
    
    // Agrupar por categoría
    for (final ingrediente in ingredientesFiltrados) {
      if (!resultado.containsKey(ingrediente.categoria)) {
        resultado[ingrediente.categoria] = [];
      }
      resultado[ingrediente.categoria]!.add(ingrediente);
    }
    
    return resultado;
  }
  
  // Método para agregar un ingrediente personalizado
  void _agregarIngredientePersonalizado() {
    if (_ingredienteController.text.trim().isEmpty) return;
    
    // Crear nuevo ingrediente personalizado
    final nuevoIngrediente = Ingrediente(
      nombre: _ingredienteController.text.trim(),
      // Usamos un ícono genérico para ingredientes personalizados
      imagen: 'https://cdn-icons-png.flaticon.com/512/1046/1046782.png',
      esPersonalizado: true,
    );
    
    // Enviar el ingrediente personalizado
    widget.onIngredienteSeleccionado(nuevoIngrediente);
    
    // Limpiar el campo de texto
    _ingredienteController.clear();
    setState(() {
      _terminoBusqueda = '';
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // Ingredientes filtrados y agrupados por categoría
    final ingredientesPorCategoria = _filtrarIngredientesPorCategoria();
    final categorias = ingredientesPorCategoria.keys.toList();
    categorias.sort(); // Ordenar alfabéticamente
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y botón de búsqueda
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selecciona tus ingredientes:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: Icon(
                  _mostrarCampoBusqueda ? Icons.close : Icons.search,
                  color: AppTheme.verdeMedio,
                ),
                onPressed: () {
                  setState(() {
                    _mostrarCampoBusqueda = !_mostrarCampoBusqueda;
                    if (!_mostrarCampoBusqueda) {
                      _terminoBusqueda = '';
                      _ingredienteController.clear();
                    } else {
                      // Enfocar el campo cuando se muestra
                      Future.delayed(const Duration(milliseconds: 100), () {
                        FocusScope.of(context).requestFocus(_focusNode);
                      });
                    }
                  });
                },
              ),
            ],
          ),
          
          // Campo de búsqueda/entrada de ingredientes personalizados
          if (_mostrarCampoBusqueda) ...[  
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // Eliminar altura fija para evitar overflow
              constraints: const BoxConstraints(minHeight: 80),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _ingredienteController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Buscar o agregar ingrediente...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.verdeMedio,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: AppTheme.naranjaAccion,
                          ),
                          onPressed: _agregarIngredientePersonalizado,
                          tooltip: 'Agregar ingrediente personalizado',
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.verdeMedio.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.verdeMedio.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.verdeMedio,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (valor) {
                        setState(() {
                          _terminoBusqueda = valor;
                        });
                      },
                      onSubmitted: (valor) {
                        if (valor.trim().isNotEmpty) {
                          _agregarIngredientePersonalizado();
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Presiona + para agregar un ingrediente personalizado',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.grisTexto.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 8),
          
          // Mensajes informativos
          if (_terminoBusqueda.isNotEmpty && ingredientesPorCategoria.isEmpty) ...[  
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.azulSuave,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.azulBoton.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.azulBoton,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No se encontró "${_ingredienteController.text}". Puedes agregarlo como ingrediente personalizado.',
                      style: const TextStyle(color: AppTheme.azulBoton),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // Lista de ingredientes por categoría
          Expanded(
            child: ingredientesPorCategoria.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      final ingredientesEnCategoria = ingredientesPorCategoria[categoria] ?? [];
                      
                      if (ingredientesEnCategoria.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Encabezado de categoría
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.verdeMedio,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    categoria,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.grey.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Grid de ingredientes en esta categoría
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: ingredientesEnCategoria.length,
                            itemBuilder: (context, idx) {
                              return _buildIngredienteCard(ingredientesEnCategoria[idx]);
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  // Widget para mostrar cuando no hay ingredientes
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 64,
            color: AppTheme.verdeMedio.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay ingredientes disponibles',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.grisTexto,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _mostrarCampoBusqueda = true;
                // Enfocar el campo cuando se muestra
                Future.delayed(const Duration(milliseconds: 100), () {
                  FocusScope.of(context).requestFocus(_focusNode);
                });
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Agregar ingrediente'),
          ),
        ],
      ),
    );
  }
  
  // Widget para construir cada tarjeta de ingrediente
  Widget _buildIngredienteCard(Ingrediente ingrediente) {
    return GestureDetector(
      onTap: () {
        widget.onIngredienteSeleccionado(ingrediente);
      },
      child: Card(
        elevation: 3,
        shadowColor: AppTheme.verdeMedio.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge para ingredientes personalizados
              if (ingrediente.esPersonalizado)
                const Align(
                  alignment: Alignment.topRight,
                  child: Icon(
                    Icons.star,
                    color: AppTheme.naranjaAccion,
                    size: 16,
                  ),
                ),
                
              // Imagen del ingrediente
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.network(
                    ingrediente.imagen,
                    height: 50,
                    width: 50,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.restaurant,
                        size: 50,
                        color: AppTheme.verdeMedio,
                      );
                    },
                  ),
                ),
              ),
              
              // Nombre del ingrediente
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: AppTheme.verdeClaro.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  ingrediente.nombre,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

