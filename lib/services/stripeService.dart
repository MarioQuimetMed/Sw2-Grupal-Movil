import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sw2_grupal_movil/models/MyPlanGetModel.dart';
import 'package:sw2_grupal_movil/models/PlansGetModel.dart';
import '../api/dio_client.dart';

class StripeService {
  final DioClient _dioClient = DioClient();

  /// Obtiene la lista de planes disponibles
  Future<List<PlansGetResponse>> getPlans() async {
    try {
      final response = await _dioClient.get('plans');
      return (response.data as List)
          .map((json) => PlansGetResponse.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw 'Error al obtener los planes: ${e.message}';
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }

  /// Crea un PaymentIntent en el backend y procesa el pago nativamente
  Future<Map<String, dynamic>> processNativePayment({
    required int userId,
    required int planId,
    bool isAnnual = false,
  }) async {
    try {
      // 1. Crear PaymentIntent en el backend
      final response = await _dioClient.post(
        'payments/create-payment-intent',
        data: {
          'userId': userId,
          'planId': planId,
          'isAnnual': isAnnual,
        },
      );

      // 2. Obtener el client_secret del PaymentIntent
      final clientSecret = response.data['clientSecret'];

      // 3. Configurar los parámetros de pago
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Mi App Financiera',
          paymentIntentClientSecret: clientSecret,
          style: ThemeMode.light,
          billingDetails: const BillingDetails(
            name: 'Auto', // Será completado por el usuario
          ),
        ),
      );

      // 4. Mostrar la hoja de pago nativa
      await Stripe.instance.presentPaymentSheet();

      // 5. Verificar el resultado
      // Si llegamos aquí sin excepción, el pago fue exitoso
      return {
        'success': true,
        'paymentIntentId': response.data['paymentIntentId'],
      };
    } on StripeException catch (e) {
      throw 'Error en el pago: ${e.error.localizedMessage}';
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw 'No autorizado. Por favor inicie sesión nuevamente.';
      } else {
        throw 'Error al crear intención de pago: ${e.message}';
      }
    } catch (e) {
      throw '$e';
    }
  }

  /// Obtiene el plan activo del usuario
  Future<MyPlayGetResponse?> getMyActivePlan(int userId) async {
    try {
      final response = await _dioClient.get('plans/my-active-plan/$userId');
      return MyPlayGetResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // El usuario no tiene un plan activo
        return null;
      }
      throw 'Error al obtener el plan activo: ${e.message}';
    } catch (e) {
      throw 'Error inesperado: $e';
    }
  }
}
