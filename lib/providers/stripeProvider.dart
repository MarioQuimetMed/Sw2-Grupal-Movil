import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sw2_grupal_movil/api/dio_client.dart';
import 'package:sw2_grupal_movil/models/MyPlanGetModel.dart';
import 'package:sw2_grupal_movil/models/PlansGetModel.dart';
import 'package:sw2_grupal_movil/providers/authProvider.dart';
import '../main.dart';
import '../services/stripeService.dart';

class StripeProvider extends SafeChangeNotifier {
  final StripeService _stripeService = StripeService();

  bool _isLoading = false;
  String? _errorMessage;
  List<PlansGetResponse> _plans = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PlansGetResponse> get plans => _plans;

  /// Obtiene los planes y los guarda en el provider
  Future<void> fetchPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plans = await _stripeService.getPlans();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // En tu StripeProvider:
  Future<MyPlayGetResponse?> fetchMyActivePlan(int userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final activePlan = await _stripeService.getMyActivePlan(userId);
      _isLoading = false;
      notifyListeners();
      return activePlan;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Inicia el proceso de pago nativo para una suscripción
  Future<bool> processSubscriptionPayment({
    required int planId,
    required BuildContext context,
    bool isAnnual = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Obtén el ID del usuario desde el AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        throw 'Usuario no autenticado';
      }

      // Procesar pago nativo con Stripe
      final result = await _stripeService.processNativePayment(
        userId: userId,
        planId: planId,
        isAnnual: isAnnual,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
