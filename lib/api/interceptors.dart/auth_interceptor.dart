import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Obtener token desde almacenamiento
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Si recibimos un 401, podríamos intentar renovar el token o redirigir al login
    if (err.response?.statusCode == 401) {
      // Lógica de refresh token o redirigir a login
    }

    return handler.next(err);
  }
}
