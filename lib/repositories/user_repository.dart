import 'dart:convert';
import '../models/user.dart';
import '../services/db_helper.dart';
import '../services/secure_api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserRepository {
  final DBHelper _dbHelper = DBHelper();
  final SecureApiService _secureApiService = SecureApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  static const String _apiKeyKey = 'openrouter_api_key';

  // Métodos para gestionar el usuario
  Future<UserProfile> loadUser() async {
    return await _dbHelper.getUser() ?? UserProfile(
      nombre: '',
      alergias: [],
      vegetariano: false,
      vegano: false,
      sinGluten: false,
      sinLactosa: false,
      tiempoMaximoPreparacion: 30, // 30 minutos por defecto
      nivelCalorico: 'Medio', // Nivel calórico medio por defecto
    );
  }

  Future<void> saveUser(UserProfile user) async {
    await _dbHelper.insertUser(user);
  }
  
  Future<void> updateUser(UserProfile user) async {
    await _dbHelper.updateUser(user);
  }
  
  // Métodos para manejar la API key de forma segura
  Future<void> saveApiKey(String apiKey) async {
    await _secureStorage.write(key: _apiKeyKey, value: apiKey);
  }

  Future<void> deleteApiKey() async {
    await _secureStorage.delete(key: _apiKeyKey);
  }
}
