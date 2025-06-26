import 'package:dio/dio.dart';
import 'package:sw2_grupal_movil/api/dio_client.dart';
import 'package:sw2_grupal_movil/models/BudgetActiveModel.dart';
import 'package:sw2_grupal_movil/models/BudgetProgressGet.dart';

class BudgetService {
  final DioClient _dioClient = DioClient();

  /// Crea un nuevo presupuesto
  Future<Map<String, dynamic>> createBudget({
    required int amount,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int idAccount,
  }) async {
    try {
      final response = await _dioClient.post(
        'budgets',
        data: {
          'amount': amount,
          'description': description,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'idAccount': idAccount,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw 'No autorizado. Por favor inicie sesión nuevamente.';
      } else if (e.response?.statusCode == 400) {
        throw 'Datos inválidos: ${e.response?.data['message'] ?? e.message}';
      } else {
        throw 'Error al crear el presupuesto: ${e.message}';
      }
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  /// Obtiene los presupuestos activos del usuario
  Future<List<BudgetActiveGet>> getActiveBudgets() async {
    try {
      final response = await _dioClient.get('budgets/active');

      if (response.data is List) {
        return (response.data as List)
            .map((json) => BudgetActiveGet.fromJson(json))
            .toList();
      } else {
        // Si la respuesta no es una lista, devuelve una lista vacía
        return [];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Si no hay presupuestos activos, devolvemos una lista vacía
        return [];
      } else if (e.response?.statusCode == 401) {
        throw 'No autorizado. Por favor inicie sesión nuevamente.';
      } else {
        throw 'Error al obtener presupuestos activos: ${e.message}';
      }
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  /// Obtiene el progreso de un presupuesto específico
  Future<BudgetProgressGet> getBudgetProgress(int budgetId) async {
    try {
      final response = await _dioClient.get('budgets/$budgetId/progress');
      return BudgetProgressGet.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw 'Presupuesto no encontrado.';
      } else if (e.response?.statusCode == 401) {
        throw 'No autorizado. Por favor inicie sesión nuevamente.';
      } else {
        throw 'Error al obtener el progreso del presupuesto: ${e.message}';
      }
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }
}
