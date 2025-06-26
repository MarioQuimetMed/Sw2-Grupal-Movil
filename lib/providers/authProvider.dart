import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sw2_grupal_movil/models/HealthScoreModel.dart';
import 'package:sw2_grupal_movil/services/healthScoreService.dart';
import '../main.dart';
import '../models/AuthServiceModel.dart';
import '../services/authService.dart';

class AuthProvider extends SafeChangeNotifier {
  final AuthService _authService = AuthService();
  final HealthScoreService _healthScoreService = HealthScoreService();

  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _user != null;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Método de login
  Future<bool> login(String email, String password) async {
    // Comenzamos el proceso de login
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Llamamos al servicio
      final response = await _authService.login(email, password);

      // Guardamos los datos de la respuesta
      _user = response.user;
      _token = response.accessToken;
      _isLoading = false;

      // Aquí podrías guardar el token en almacenamiento persistente

      await _saveTokenToStorage(response.accessToken);

      notifyListeners();
      return true;
    } catch (e) {
      // Manejo de errores
      _isLoading = false;
      _errorMessage = e.toString();

      notifyListeners();
      return false;
    }
  }

// Método para guardar el token
  Future<void> _saveTokenToStorage(String token) async {
    // Ejemplo con SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Método de logout
  void logout() {
    _user = null;
    _token = null;
    _errorMessage = null;

    // Aquí podrías eliminar el token del almacenamiento persistente
    // await _removeToken();

    notifyListeners();
  }

  // Método para verificar si hay un token guardado al iniciar la app
  Future<void> checkAuthStatus() async {
    // Implementar verificación de token guardado
    // final savedToken = await _getSavedToken();
    // if (savedToken != null) {
    //   // Verificar validez del token con el backend si es necesario
    //   _token = savedToken;
    //   // Obtener datos del usuario actual
    //   await _fetchUserProfile();
    //   notifyListeners();
    // }
  }

  /// Método de registro
  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(username, email, password);

      // _user = response.user;
      // _token = response.accessToken;
      // await _saveTokenToStorage(_token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Manejo de errores
      _isLoading = false;
      _errorMessage = e.toString();

      notifyListeners();
      return false;
    }
  }

  //Metodo para obtener la salud financiera del usuario
  Future<HeatlhScore> getHealthScore() async {
    try {
      final healthScore = await _healthScoreService.getHealthScore();
      return healthScore;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      throw e; // Re-lanzar la excepción para manejarla en el lugar donde se llama
    }
  }
}
