import 'package:dio/dio.dart';
import 'package:sw2_grupal_movil/api/dio_client.dart';
import 'package:sw2_grupal_movil/models/HealthScoreModel.dart';
import 'package:sw2_grupal_movil/models/SeggestionsGetModel.dart';

class HealthScoreService {
  final DioClient _dioClient = DioClient();

  Future<HeatlhScore> getHealthScore() async {
    try {
      final response = await _dioClient.get('health/score');
      return HeatlhScore.fromJson(response.data);
    } on DioException catch (e) {
      throw 'Error al obtener el puntaje de salud financiera: ${e.message}';
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  //Metodo para obtener las sugerencias del dia de hoy
  Future<SuggestionsGet> getDailySuggestions() async {
    try {
      final response = await _dioClient.get('ai/suggestions');
      return SuggestionsGet.fromJson(response.data);
    } on DioException catch (e) {
      throw 'Error al obtener las sugerencias del día: ${e.message}';
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }
}
