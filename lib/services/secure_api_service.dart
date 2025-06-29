import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Servicio para almacenar y recuperar credenciales de API de forma segura
class SecureApiService {
  static final SecureApiService _instance = SecureApiService._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Claves para el almacenamiento
  static const String _apiKeyKey = 'openrouter_api_key';

  factory SecureApiService() => _instance;

  SecureApiService._internal();

  /// Guarda la clave API de forma segura
  Future<void> saveApiKey(String apiKey) async {
    await _secureStorage.write(key: _apiKeyKey, value: apiKey);
  }

  /// Recupera la clave API
  Future<String?> getApiKey() async {
    return await _secureStorage.read(key: _apiKeyKey);
  }

  /// Elimina la clave API
  Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _apiKeyKey);
  }

  /// Verifica si la clave API está guardada
  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }
}
