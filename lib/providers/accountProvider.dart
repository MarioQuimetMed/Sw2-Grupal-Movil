import 'package:flutter/material.dart';
import '../main.dart';
import '../models/AccountGetModel.dart';
import '../services/accountService.dart';

class AccountProvider extends SafeChangeNotifier {
  final AccountService _accountService = AccountService();

  List<AccountGetResponse> _accounts = [];
  AccountGetResponse? _selectedAccount;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<AccountGetResponse> get accounts => _accounts;
  AccountGetResponse? get selectedAccount => _selectedAccount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasAccounts => _accounts.isNotEmpty;

  // Método para obtener todas las cuentas
  Future<void> fetchAccounts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _accounts = await _accountService.getAccounts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Método para obtener una cuenta específica por ID
  Future<void> fetchAccountById(int accountId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedAccount = await _accountService.getAccountById(accountId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Método para seleccionar una cuenta de la lista existente
  void selectAccount(int accountId) {
    try {
      _selectedAccount = _accounts.firstWhere(
        (account) => account.id == accountId,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Cuenta no encontrada en la lista local';
      notifyListeners();
    }
  }

  // Método para limpiar la selección
  void clearSelectedAccount() {
    _selectedAccount = null;
    notifyListeners();
  }

  // Método para reiniciar el estado de error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Método para recargar los datos
  Future<void> refreshAccounts() async {
    _errorMessage = null;
    try {
      _accounts = await _accountService.getAccounts();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
