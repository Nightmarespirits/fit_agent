import 'package:flutter/material.dart';
import 'package:fit_agent/services/secure_api_service.dart';
import 'package:fit_agent/themes/app_theme.dart';

/// Pantalla para configurar la API Key de OpenRouter
class ApiKeyScreen extends StatefulWidget {
  final bool isRequired; // Indica si la API key es obligatoria (redireccionamiento inicial)

  const ApiKeyScreen({
    Key? key,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final SecureApiService _apiService = SecureApiService();
  bool _isLoading = false;
  bool _obscureKey = true;
  String? _apiKeyCurrentStatus;

  @override
  void initState() {
    super.initState();
    _checkExistingApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  /// Verifica si ya hay una API key guardada y actualiza la interfaz
  Future<void> _checkExistingApiKey() async {
    setState(() {
      _isLoading = true;
    });

    bool hasKey = await _apiService.hasApiKey();
    if (hasKey) {
      String? key = await _apiService.getApiKey();
      if (key != null && key.isNotEmpty) {
        // Mostrar solo los últimos 8 caracteres de la API key por seguridad
        String maskedKey = key.length > 8
            ? '••••••••' + key.substring(key.length - 8)
            : '••••••••';
        
        setState(() {
          _apiKeyCurrentStatus = 'API key actual: $maskedKey';
        });
      }
    } else {
      setState(() {
        _apiKeyCurrentStatus = widget.isRequired
            ? 'Se requiere una API key para generar recetas.'
            : 'No hay API key configurada.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Guarda la API key en el almacenamiento seguro
  Future<void> _saveApiKey() async {
    String apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      _showSnackBar('Por favor, ingresa una API key válida.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.saveApiKey(apiKey);
      _apiKeyController.clear();
      _showSnackBar('API key guardada correctamente.');
      await _checkExistingApiKey();

      // Si la API key era requerida, regresamos a la pantalla anterior
      if (widget.isRequired && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Error al guardar la API key: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Elimina la API key actual
  Future<void> _deleteApiKey() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.deleteApiKey();
      _showSnackBar('API key eliminada correctamente.');
      setState(() {
        _apiKeyCurrentStatus = 'No hay API key configurada.';
      });
    } catch (e) {
      _showSnackBar('Error al eliminar la API key: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de API Key'),
        // Si es requerida, no mostrar botón de regresar
        automaticallyImplyLeading: !widget.isRequired,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  
                  // Información sobre OpenRouter y la API key
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Acerca de la API Key',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'FIT Agent utiliza la API de OpenRouter para generar recetas personalizadas con IA.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Para utilizar esta función, necesitas una API key de OpenRouter:',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          // Pasos para obtener la API key
                          _buildStep(
                            '1',
                            'Visita openrouter.ai y crea una cuenta',
                            context,
                          ),
                          _buildStep(
                            '2',
                            'Ve a tu perfil y genera una API key',
                            context,
                          ),
                          _buildStep(
                            '3',
                            'Copia la API key y pégala aquí',
                            context,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Ir a OpenRouter'),
                              onPressed: () {
                                // Aquí iría un código para abrir la URL
                                // Podríamos agregar una dependencia como url_launcher
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Estado actual de la API key
                  if (_apiKeyCurrentStatus != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estado actual',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _apiKeyCurrentStatus!,
                              style: TextStyle(
                                fontSize: 16,
                                color: _apiKeyCurrentStatus!.contains('No hay')
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ),
                            if (_apiKeyCurrentStatus!.contains('actual'))
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.delete_outline),
                                  label: const Text('Eliminar API key'),
                                  onPressed: _deleteApiKey,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Formulario para agregar API key
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Agregar API Key',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _apiKeyController,
                            decoration: InputDecoration(
                              labelText: 'API Key de OpenRouter',
                              hintText: 'sk-or-v1-...',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureKey
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureKey = !_obscureKey;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscureKey,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar API key'),
                              onPressed: _saveApiKey,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStep(String number, String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
