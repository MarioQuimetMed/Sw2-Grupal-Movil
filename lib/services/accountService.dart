import 'package:dio/dio.dart';
import '../api/dio_client.dart';
import '../models/AccountGetModel.dart';

class AccountService {
  final DioClient _dioClient = DioClient();

  /// Obtiene todas las cuentas del usuario
  ///
  /// Realiza una petición GET a la ruta "accounts"
  /// Retorna una lista de [AccountGetResponse] o lanza una excepción en caso de error
  Future<List<AccountGetResponse>> getAccounts() async {
    try {
      final response = await _dioClient.get('accounts');

      final List<dynamic> accountsData = response.data;

      return accountsData
          .map((data) => AccountGetResponse.fromJson(data))
          .toList();
    } on DioException catch (e) {
      // Manejo específico para errores de Dio
      if (e.response?.statusCode == 401) {
        throw 'No autorizado. Por favor inicie sesión nuevamente';
      } else if (e.response?.statusCode == 403) {
        throw 'No tiene permisos para ver las cuentas';
      } else if (e.response?.statusCode == 404) {
        throw 'No se encontraron cuentas';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw 'Tiempo de conexión agotado';
      } else {
        throw 'Error al obtener cuentas: ${e.message}';
      }
    } catch (e) {
      // Otros errores inesperados
      throw 'Error inesperado: $e';
    }
  }

  /// Obtiene una cuenta específica por ID
  ///
  /// Recibe [accountId] y retorna un [AccountGetResponse]
  /// o lanza una excepción en caso de error
  Future<AccountGetResponse> getAccountById(int accountId) async {
    try {
      final response = await _dioClient.get('accounts/$accountId');

      // Como la respuesta es un objeto único y no una lista
      return AccountGetResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw 'Cuenta no encontrada';
      } else if (e.response?.statusCode == 401) {
        throw 'No autorizado para ver esta cuenta';
      } else {
        throw 'Error al obtener la cuenta: ${e.message}';
      }
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }
}
