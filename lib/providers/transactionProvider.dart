import 'package:flutter/material.dart';
import '../main.dart';
import '../models/transacctionCreateModel.dart';
import '../services/transactionService.dart';

class TransactionProvider extends SafeChangeNotifier {
  final TransactionService _transactionService = TransactionService();

  TransactionCreateResponse? _lastTransaction;
  bool _isProcessing = false;
  String? _errorMessage;

  // Getters
  TransactionCreateResponse? get lastTransaction => _lastTransaction;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  bool get hasTransaction => _lastTransaction != null;

  /// Procesa una transacción utilizando IA a partir de un texto
  Future<bool> processTransactionWithAI(String text, int accountId) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lastTransaction =
          await _transactionService.processTransactionWithAI(text, accountId);

      _isProcessing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isProcessing = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Limpia el estado de la última transacción
  void clearLastTransaction() {
    _lastTransaction = null;
    notifyListeners();
  }

  /// Limpia el estado de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Obtiene el tipo de transacción en español
  String getTransactionTypeInSpanish(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return 'Ingreso';
      case 'expense':
        return 'Gasto';
      case 'transfer':
        return 'Transferencia';
      default:
        return type;
    }
  }

  /// Obtiene el color asociado al tipo de transacción
  Color getTransactionColor(String type) {
    switch (type.toLowerCase()) {
      case 'income':
        return Colors.green;
      case 'expense':
        return Colors.red;
      case 'transfer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  /// Formatea el monto para mostrar + o - según el tipo de transacción
  String formatAmount(int amount, String type) {
    final prefix = type.toLowerCase() == 'income' ? '+' : '-';
    return '$prefix $amount';
  }
}
