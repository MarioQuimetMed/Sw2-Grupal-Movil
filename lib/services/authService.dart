import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../models/AuthServiceModel.dart';

class AuthService {
  final DioClient _dioClient = DioClient();

  /// Realiza el proceso de login con las credenciales proporcionadas
  ///
  /// Recibe [email] y [password] y devuelve un [AuthResponse] con el usuario y token
  /// o lanza una excepción en caso de error
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dioClient.post(
        'auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Manejo específico para errores de Dio
      if (e.response?.statusCode == 401) {
        throw 'Credenciales incorrectas';
      } else if (e.response?.statusCode == 404) {
        throw 'Usuario no encontrado';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw 'Tiempo de conexión agotado';
      } else {
        throw 'Error de conexión: ${e.message}';
      }
    } catch (e) {
      // Otros errores inesperados
      throw 'Error inesperado: $e';
    }
  }

  /// Realiza el proceso de registro de un nuevo usuario
  ///
  /// Recibe [username], [email], [password] y devuelve un [AuthResponse] con el usuario y token
  /// o lanza una excepción en caso de error
  Future<AuthResponse> register(
      String username, String email, String password) async {
    try {
      final response = await _dioClient.post(
        'auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'status': 'active'
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Manejo específico para errores de Dio
      if (e.response?.statusCode == 400) {
        throw 'Datos de registro inválidos';
      } else if (e.response?.statusCode == 409) {
        throw 'El correo electrónico ya está registrado';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw 'Tiempo de conexión agotado';
      } else {
        throw 'Error de conexión: ${e.message}';
      }
    } catch (e) {
      // Otros errores inesperados
      throw 'Error inesperado: $e';
    }
  }
}
