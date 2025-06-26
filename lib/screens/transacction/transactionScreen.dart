import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/transactionProvider.dart';
import '../../providers/accountProvider.dart';
import '../../models/transactionGetByMonth.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  late int _selectedMonth;
  late int _selectedYear;
  final List<String> _months = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre'
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTransactions();
    });
  }

  void _fetchTransactions() {
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    final selectedAccount = accountProvider.selectedAccount;
    if (selectedAccount == null) return;
    Provider.of<TransactionProvider>(context, listen: false)
        .fetchTransactionsByAccountAndDate(
            selectedAccount.id, _selectedMonth, _selectedYear);
  }

  void _onMonthChanged(String? newMonth) {
    if (newMonth != null) {
      setState(() {
        _selectedMonth = _months.indexOf(newMonth) + 1;
      });
      _fetchTransactions();
    }
  }

  void _onYearChanged(int? newYear) {
    if (newYear != null) {
      setState(() {
        _selectedYear = newYear;
      });
      _fetchTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final accountProvider = Provider.of<AccountProvider>(context);
    final years = List.generate(6, (i) => DateTime.now().year - 2 + i);

    final selectedAccount = accountProvider.selectedAccount;
    if (selectedAccount == null) {
      return const Center(
        child: Text('Selecciona una cuenta para ver las transacciones.'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Selector de mes y año
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _months[_selectedMonth - 1],
                    decoration: InputDecoration(
                      labelText: 'Mes',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: _months
                        .map((month) => DropdownMenuItem(
                              value: month,
                              child: Text(month),
                            ))
                        .toList(),
                    onChanged: _onMonthChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _selectedYear,
                    decoration: InputDecoration(
                      labelText: 'Año',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: years
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            ))
                        .toList(),
                    onChanged: _onYearChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (transactionProvider.isLoadingTransactionsByMonth) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (transactionProvider.errorTransactionsByMonth != null) {
                    return _buildError(
                        transactionProvider.errorTransactionsByMonth!);
                  }
                  final transactions = transactionProvider.transactionsByMonth;
                  if (transactions.isEmpty) {
                    return _buildEmpty();
                  }
                  return ListView.separated(
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tx = transactions[index];
                      // Colores según tipo
                      Color color;
                      String prefix;
                      if (tx.type.toLowerCase() == 'expense' ||
                          tx.type.toLowerCase() == 'egreso') {
                        color = Colors.red;
                        prefix = '-';
                      } else if (tx.type.toLowerCase() == 'income' ||
                          tx.type.toLowerCase() == 'ingreso') {
                        color = Colors.green;
                        prefix = '+';
                      } else {
                        color = Colors.blue;
                        prefix = '';
                      }
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(
                              tx.type.toLowerCase() == 'income' ||
                                      tx.type.toLowerCase() == 'ingreso'
                                  ? Icons.arrow_downward
                                  : tx.type.toLowerCase() == 'expense' ||
                                          tx.type.toLowerCase() == 'egreso'
                                      ? Icons.arrow_upward
                                      : Icons.compare_arrows,
                              color: color,
                            ),
                          ),
                          title: Text(
                            tx.description,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${tx.category.name} • ${DateFormat('dd/MM/yyyy').format(tx.date)}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: Text(
                            '$prefix ${tx.amount} S/',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red[400], size: 48),
          const SizedBox(height: 12),
          const Text(
            'Error al cargar transacciones',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchTransactions,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, color: Colors.grey[400], size: 60),
          const SizedBox(height: 14),
          const Text(
            'No hay transacciones para este mes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cambia el mes o año para ver otras transacciones.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
