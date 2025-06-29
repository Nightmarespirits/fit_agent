import 'package:flutter/material.dart';
import 'package:fit_agent/widgets/custom_bottom_navigation.dart';
import 'package:fit_agent/themes/app_theme.dart';
import 'package:fit_agent/models/user.dart';
import 'package:fit_agent/services/user_service.dart';
import 'package:fit_agent/services/secure_api_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Valores para las preferencias
  bool _vegetariano = false;
  bool _vegano = false;
  bool _sinGluten = false;
  bool _sinLactosa = false;
  String _nivelCaloriasSeleccionado = 'Medio';
  double _tiempoMaximo = 30.0;
  List<String> _alergiasSeleccionadas = [];
  
  // Estado de carga
  bool _isLoading = true;
  bool _isSaving = false;
  late UserProfile _userProfile;
  
  // Estado de la API Key
  bool _hasApiKey = false;
  final SecureApiService _apiService = SecureApiService();

  // Opciones para nivel de calorías
  final List<String> _nivelesCaloricas = ['Bajo', 'Medio', 'Alto'];

  // Opciones para alergias comunes
  final List<String> _alergias = [
    'Frutos secos',
    'Mariscos',
    'Huevo',
    'Lácteos',
    'Soja',
    'Trigo'
  ];

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
    _checkApiKeyStatus();
  }
  
  // Comprobar si hay API key configurada
  Future<void> _checkApiKeyStatus() async {
    final hasKey = await _apiService.hasApiKey();
    setState(() {
      _hasApiKey = hasKey;
    });
  }
  
  // Cargar las preferencias del usuario
  Future<void> _cargarPreferencias() async {
    try {
      final userProfile = await UserService.loadUser();
      setState(() {
        _userProfile = userProfile;
        _vegetariano = userProfile.vegetariano;
        _vegano = userProfile.vegano;
        _sinGluten = userProfile.sinGluten;
        _sinLactosa = userProfile.sinLactosa;
        _alergiasSeleccionadas = List<String>.from(userProfile.alergias);
        _nivelCaloriasSeleccionado = userProfile.nivelCalorico;
        _tiempoMaximo = userProfile.tiempoMaximoPreparacion;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userProfile = UserProfile.empty();
        _isLoading = false;
      });
    }
  }
  
  // Guardar las preferencias del usuario
  Future<void> _guardarPreferencias() async {
    setState(() {
      _isSaving = true;
    });
    
    try {
      // Actualizar las preferencias en el objeto de usuario
      _userProfile.vegetariano = _vegetariano;
      _userProfile.vegano = _vegano;
      _userProfile.sinGluten = _sinGluten;
      _userProfile.sinLactosa = _sinLactosa;
      _userProfile.alergias = List<String>.from(_alergiasSeleccionadas);
      _userProfile.nivelCalorico = _nivelCaloriasSeleccionado;
      _userProfile.tiempoMaximoPreparacion = _tiempoMaximo;
      
      // Guardar el perfil actualizado
      await UserService.saveUser(_userProfile);
      
      setState(() {
        _isSaving = false;
      });
      
      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferencias guardadas correctamente'),
          backgroundColor: AppTheme.verdeMedio,
        ),
      );
      
      // Redirigir a la pantalla de perfil
      Navigator.pushReplacementNamed(context, 'profile');
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      
      // Mostrar mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al guardar las preferencias'),
          backgroundColor: AppTheme.rojoAlerta,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias'),
        backgroundColor: AppTheme.verdeMedio,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restricciones Alimentarias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.verdeOscuro,
              ),
            ),
            const SizedBox(height: 16),
            
            // Opciones de restricciones dietéticas
            _buildSwitchOption(
              title: 'Vegetariano',
              value: _vegetariano,
              onChanged: (value) {
                setState(() {
                  _vegetariano = value;
                  if (value) {
                    // Si es vegetariano, no puede ser vegano al mismo tiempo
                    _vegano = false;
                  }
                });
              },
            ),
            
            _buildSwitchOption(
              title: 'Vegano',
              value: _vegano,
              onChanged: (value) {
                setState(() {
                  _vegano = value;
                  if (value) {
                    // Si es vegano, automáticamente es vegetariano
                    _vegetariano = true;
                  }
                });
              },
            ),
            
            _buildSwitchOption(
              title: 'Sin Gluten',
              value: _sinGluten,
              onChanged: (value) {
                setState(() {
                  _sinGluten = value;
                });
              },
            ),
            
            _buildSwitchOption(
              title: 'Sin Lactosa',
              value: _sinLactosa,
              onChanged: (value) {
                setState(() {
                  _sinLactosa = value;
                });
              },
            ),
            
            const Divider(height: 32),
            
            // Nivel calórico
            const Text(
              'Nivel Calórico',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.verdeOscuro,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              children: _nivelesCaloricas.map((nivel) {
                return ChoiceChip(
                  label: Text(nivel),
                  selected: _nivelCaloriasSeleccionado == nivel,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _nivelCaloriasSeleccionado = nivel;
                      });
                    }
                  },
                  selectedColor: AppTheme.verdeMedio,
                  labelStyle: TextStyle(
                    color: _nivelCaloriasSeleccionado == nivel
                        ? AppTheme.blanco
                        : AppTheme.grisTexto,
                  ),
                );
              }).toList(),
            ),
            
            const Divider(height: 32),
            
            // Tiempo máximo de preparación
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiempo Máximo de Preparación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.verdeOscuro,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_tiempoMaximo.round()} minutos',
                  style: const TextStyle(
                    color: AppTheme.grisTexto,
                  ),
                ),
                Slider(
                  value: _tiempoMaximo,
                  min: 10,
                  max: 60,
                  divisions: 10,
                  label: '${_tiempoMaximo.round()} min',
                  onChanged: (value) {
                    setState(() {
                      _tiempoMaximo = value;
                    });
                  },
                  activeColor: AppTheme.verdeMedio,
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            // Alergias
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alergias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.verdeOscuro,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _alergias.map((alergia) {
                    return FilterChip(
                      label: Text(alergia),
                      selected: _alergiasSeleccionadas.contains(alergia),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _alergiasSeleccionadas.add(alergia);
                          } else {
                            _alergiasSeleccionadas.remove(alergia);
                          }
                        });
                      },
                      selectedColor: AppTheme.rojoAlerta.withOpacity(0.7),
                      checkmarkColor: AppTheme.blanco,
                      labelStyle: TextStyle(
                        color: _alergiasSeleccionadas.contains(alergia)
                            ? AppTheme.blanco
                            : AppTheme.grisTexto,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Sección de configuración de la aplicación
            const Divider(height: 40),
            
            const Text(
              'Configuración de la Aplicación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.verdeOscuro,
              ),
            ),
            const SizedBox(height: 16),
            
            // API Key de OpenRouter
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: AppTheme.grisClaro,
              elevation: 0,
              child: ListTile(
                title: const Text(
                  'API Key de OpenRouter',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  _hasApiKey 
                      ? 'Configurada' 
                      : 'No configurada - Las recetas no se generarán sin una API key',
                  style: TextStyle(
                    color: _hasApiKey ? Colors.green : Colors.orange,
                  ),
                ),
                trailing: const Icon(Icons.keyboard_arrow_right),
                leading: const Icon(Icons.key),
                onTap: () {
                  Navigator.of(context).pushNamed('api-key').then((_) {
                    // Actualizar el estado al volver
                    _checkApiKeyStatus();
                  });
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botón para guardar preferencias
            Center(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _guardarPreferencias,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: _isSaving
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Guardando...'),
                          ],
                        )
                      : const Text('Guardar Preferencias'),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigation(currentIndex: 3),
    );
  }
  
  // Widget para construir opciones de tipo switch
  Widget _buildSwitchOption({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppTheme.grisClaro,
      elevation: 0,
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.verdeMedio,
      ),
    );
  }
}
