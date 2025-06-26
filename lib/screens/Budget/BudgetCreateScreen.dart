import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sw2_grupal_movil/models/AccountGetModel.dart';
import 'package:sw2_grupal_movil/models/BudgetActiveModel.dart';
import 'package:sw2_grupal_movil/providers/budgetProvider.dart';
import 'package:sw2_grupal_movil/providers/accountProvider.dart';

class BudgetCreateScreen extends StatefulWidget {
  const BudgetCreateScreen({Key? key}) : super(key: key);

  @override
  State<BudgetCreateScreen> createState() => _BudgetCreateScreenState();
}

class _BudgetCreateScreenState extends State<BudgetCreateScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int? _selectedAccountId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Cargar cuentas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAccounts();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    await accountProvider.fetchAccounts();

    // Seleccionar la primera cuenta por defecto si hay disponibles
    if (mounted && accountProvider.accounts.isNotEmpty) {
      setState(() {
        _selectedAccountId = accountProvider.accounts.first.id;
      });
    }

    _animationController.forward();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: isStartDate ? DateTime.now() : _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ajustar la fecha de finalización si es necesario
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _createBudget() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final budgetProvider =
          Provider.of<BudgetProvider>(context, listen: false);
      final amount = int.parse(_amountController.text.replaceAll(',', ''));

      final result = await budgetProvider.createBudget(
        amount: amount,
        description: _descriptionController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        idAccount: _selectedAccountId!,
      );

      if (result && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Presupuesto creado con éxito!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear el presupuesto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Crear Presupuesto'),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Consumer<AccountProvider>(
            builder: (context, accountProvider, child) {
              if (accountProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (accountProvider.accounts.isEmpty) {
                return _buildNoAccountsMessage();
              }

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta principal con los campos del formulario
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Información del presupuesto',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Descripción
                              _buildTextField(
                                controller: _descriptionController,
                                labelText: 'Descripción',
                                hintText: 'Ej. Gastos de alimentación',
                                prefixIcon: Icons.description,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Por favor ingresa una descripción';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Monto
                              _buildTextField(
                                controller: _amountController,
                                labelText: 'Monto (S/)',
                                hintText: 'Ej. 1000',
                                prefixIcon: Icons.attach_money,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _ThousandsSeparatorInputFormatter(),
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Por favor ingresa un monto';
                                  }
                                  final amount =
                                      int.tryParse(value.replaceAll(',', ''));
                                  if (amount == null || amount <= 0) {
                                    return 'Por favor ingresa un monto válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),

                              // Fechas
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDateSelector(
                                      label: 'Fecha inicial',
                                      date: _startDate,
                                      onTap: () => _selectDate(context, true),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDateSelector(
                                      label: 'Fecha final',
                                      date: _endDate,
                                      onTap: () => _selectDate(context, false),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Selector de cuenta
                              _buildAccountSelector(accountProvider.accounts),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Botón para crear presupuesto
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createBudget,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Crear Presupuesto',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSelector(List<AccountGetResponse> accounts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cuenta',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[400]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
          child: DropdownButtonFormField<int>(
            value: _selectedAccountId,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 2,
            isExpanded: true,
            validator: (value) {
              if (value == null) {
                return 'Por favor selecciona una cuenta';
              }
              return null;
            },
            onChanged: (int? newValue) {
              setState(() {
                _selectedAccountId = newValue;
              });
            },
            items: accounts
                .map<DropdownMenuItem<int>>((AccountGetResponse account) {
              return DropdownMenuItem<int>(
                value: account.id,
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(
                            int.parse(account.name.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        account.name,
                        style: const TextStyle(fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNoAccountsMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: 70,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes cuentas disponibles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Necesitas crear al menos una cuenta antes de poder crear un presupuesto.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Aquí podrías navegar a la pantalla de creación de cuentas
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear una cuenta'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Formateador para mostrar separadores de miles en el campo de monto
class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static final NumberFormat _numberFormat = NumberFormat('#,###', 'es');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Solo procesar si hay cambios en el texto
    if (oldValue.text == newValue.text) {
      return newValue;
    }

    // Eliminar separadores de miles
    final newValueText = newValue.text.replaceAll(',', '');

    // Verificar si es un número válido
    if (int.tryParse(newValueText) == null) {
      return oldValue;
    }

    // Formatear con separadores de miles
    final formattedValue = _numberFormat.format(int.parse(newValueText));

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}
