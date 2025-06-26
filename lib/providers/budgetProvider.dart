import 'package:flutter/material.dart';
import 'package:sw2_grupal_movil/models/BudgetActiveModel.dart';
import 'package:sw2_grupal_movil/models/BudgetProgressGet.dart';
import 'package:sw2_grupal_movil/services/budgetService.dart';
import '../main.dart';

class BudgetProvider extends SafeChangeNotifier {
  final BudgetService _budgetService = BudgetService();

  // Estado para presupuestos activos
  List<BudgetActiveGet> _activeBudgets = [];
  bool _isLoadingActiveBudgets = false;
  String? _errorActiveBudgets;

  // Estado para progreso de presupuesto
  BudgetProgressGet? _currentProgress;
  bool _isLoadingProgress = false;
  String? _errorProgress;

  // Estado para creación de presupuesto
  bool _isCreatingBudget = false;
  String? _errorCreateBudget;

  // Getters
  List<BudgetActiveGet> get activeBudgets => _activeBudgets;
  bool get isLoadingActiveBudgets => _isLoadingActiveBudgets;
  String? get errorActiveBudgets => _errorActiveBudgets;

  BudgetProgressGet? get currentProgress => _currentProgress;
  bool get isLoadingProgress => _isLoadingProgress;
  String? get errorProgress => _errorProgress;

  bool get isCreatingBudget => _isCreatingBudget;
  String? get errorCreateBudget => _errorCreateBudget;

  // Obtener presupuestos activos
  Future<void> fetchActiveBudgets() async {
    _isLoadingActiveBudgets = true;
    _errorActiveBudgets = null;
    notifyListeners();

    try {
      _activeBudgets = await _budgetService.getActiveBudgets();
    } catch (e) {
      _errorActiveBudgets = e.toString();
    }

    _isLoadingActiveBudgets = false;
    notifyListeners();
  }

  // Obtener progreso de un presupuesto específico
  Future<void> fetchBudgetProgress(int budgetId) async {
    _isLoadingProgress = true;
    _errorProgress = null;
    _currentProgress = null;
    notifyListeners();

    try {
      _currentProgress = await _budgetService.getBudgetProgress(budgetId);
    } catch (e) {
      _errorProgress = e.toString();
    }

    _isLoadingProgress = false;
    notifyListeners();
  }

  // Crear un nuevo presupuesto
  Future<bool> createBudget({
    required int amount,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int idAccount,
  }) async {
    _isCreatingBudget = true;
    _errorCreateBudget = null;
    notifyListeners();

    try {
      await _budgetService.createBudget(
        amount: amount,
        description: description,
        startDate: startDate,
        endDate: endDate,
        idAccount: idAccount,
      );

      // Actualizar la lista de presupuestos activos después de crear uno nuevo
      await fetchActiveBudgets();

      _isCreatingBudget = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorCreateBudget = e.toString();
      _isCreatingBudget = false;
      notifyListeners();
      return false;
    }
  }

  // Limpiar errores
  void clearErrors() {
    _errorActiveBudgets = null;
    _errorProgress = null;
    _errorCreateBudget = null;
    notifyListeners();
  }
}
