import 'package:dio/dio.dart';
import 'package:sw2_grupal_movil/models/transactionGetByMonth.dart';
import '../api/dio_client.dart';
import '../models/transacctionCreateModel.dart';

class TransactionService {
  final DioClient _dioClient = DioClient();

  /// Procesa una transacción utilizando IA para analizar el texto
  ///
  /// Recibe [text] con la descripción de la transacción y [accountId] de la cuenta asociada
  /// Retorna un [TransactionCreateResponse] con los detalles de la transacción creada
  Future<TransactionCreateResponse> processTransactionWithAI(
      String text, int accountId) async {
    try {
      // Prepara el body con los datos requeridos
      final data = {"text": text, "accountId": accountId};

      // Realiza la petición POST
      final response = await _dioClient.post(
        'ai/process-transaction',
        data: data,
      );

      // Maneja la respuesta directamente como un objeto Dart
      return TransactionCreateResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Manejo específico para errores de Dio
      if (e.response?.statusCode == 400) {
        throw 'La IA no pudo procesar el texto. Intenta con una descripción más clara.';
      } else if (e.response?.statusCode == 401) {
        throw 'No autorizado. Por favor inicie sesión nuevamente.';
      } else if (e.response?.statusCode == 404) {
        throw 'Cuenta no encontrada.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw 'Tiempo de conexión agotado.';
      } else {
        throw 'Error al procesar la transacción: ${e.message}';
      }
    } catch (e) {
      // Otros errores inesperados
      throw 'Error inesperado: $e';
    }
  }

  //Metodo para Obtener transacciones de una cuenta en un mes y año determinado
  Future<List<TransactionGetByMonth>> getTransactionsByAccountAndDate(
      int accountId, int month, int year) async {
    try {
      final response = await _dioClient.get(
        'transactions',
        queryParameters: {
          'idAccount': accountId,
          'month': month,
          'year': year,
        },
      );

      // Mapea la respuesta a una lista de objetos TransactionCreateResponse
      return (response.data as List)
          .map((item) => TransactionGetByMonth.fromJson(item))
          .toList();
    } on DioException catch (e) {
      // Manejo de errores específico para Dio
      throw 'Error al obtener transacciones: ${e.message}';
    } catch (e) {
      // Otros errores inesperados
      throw 'Error inesperado: $e';
    }
  }
}
