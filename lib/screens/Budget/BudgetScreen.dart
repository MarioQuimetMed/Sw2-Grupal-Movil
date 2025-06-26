import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sw2_grupal_movil/models/BudgetActiveModel.dart';
import 'package:sw2_grupal_movil/models/BudgetProgressGet.dart';
import 'package:sw2_grupal_movil/providers/budgetProvider.dart';
import 'package:sw2_grupal_movil/providers/accountProvider.dart';
import 'package:sw2_grupal_movil/screens/Budget/BudgetCreateScreen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  BudgetActiveGet? _selectedBudget;
  final _currencyFormat =
      NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);

  @override
  void initState() {
    super.initState();

    // Configurar animaciones
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Cargar datos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Cargar cuentas si es necesario
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);
    if (accountProvider.accounts.isEmpty) {
      await accountProvider.fetchAccounts();
    }

    // Cargar presupuestos
    await _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    await budgetProvider.fetchActiveBudgets();

    // Si hay presupuestos activos, seleccionar el primero y mostrar su progreso
    if (budgetProvider.activeBudgets.isNotEmpty && mounted) {
      setState(() {
        _selectedBudget = budgetProvider.activeBudgets.first;
      });
      await budgetProvider.fetchBudgetProgress(_selectedBudget!.id);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final hasBudgets = budgetProvider.activeBudgets.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(hasBudgets ? 'Mis Presupuestos' : 'Presupuestos'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadBudgets,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      // Solo mostrar el FAB cuando NO hay presupuestos activos
      floatingActionButton: hasBudgets
          ? null
          : FloatingActionButton(
              onPressed: () => _navigateToBudgetCreate(),
              child: const Icon(Icons.add),
              tooltip: 'Crear nuevo presupuesto',
            ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, child) {
          if (budgetProvider.isLoadingActiveBudgets) {
            return const Center(child: CircularProgressIndicator());
          }

          if (budgetProvider.errorActiveBudgets != null) {
            return _buildErrorWidget(budgetProvider.errorActiveBudgets!);
          }

          if (budgetProvider.activeBudgets.isEmpty) {
            return _buildEmptyBudgetsWidget();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lista horizontal de presupuestos activos
              // _buildBudgetsList(budgetProvider),

              // Mostrar el detalle del presupuesto seleccionado
              if (_selectedBudget != null)
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: _buildBudgetProgressDetail(budgetProvider),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _navigateToBudgetCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BudgetCreateScreen()),
    );

    if (result == true) {
      _loadBudgets();
    }
  }

  Widget _buildBudgetsList(BudgetProvider budgetProvider) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: budgetProvider.activeBudgets.length,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemBuilder: (context, index) {
          final budget = budgetProvider.activeBudgets[index];
          final isSelected = _selectedBudget?.id == budget.id;

          return GestureDetector(
            onTap: () async {
              setState(() {
                _selectedBudget = budget;
              });
              await budgetProvider.fetchBudgetProgress(budget.id);
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.9)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    budget.description,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currencyFormat.format(budget.amount),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBudgetProgressDetail(BudgetProvider budgetProvider) {
    if (budgetProvider.isLoadingProgress) {
      return const Center(child: CircularProgressIndicator());
    }

    if (budgetProvider.errorProgress != null) {
      return _buildErrorWidget(budgetProvider.errorProgress!);
    }

    final progress = budgetProvider.currentProgress;
    if (progress == null) {
      return const Center(
        child: Text('No se pudo cargar el progreso del presupuesto'),
      );
    }

    // Calcular valores necesarios para el gráfico
    final totalAmount = progress.spent + progress.remaining;
    final spentPercentage =
        totalAmount > 0 ? progress.spent / totalAmount : 0.0;
    final remainingPercentage =
        totalAmount > 0 ? progress.remaining / totalAmount : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta principal con gráfico y detalles
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Encabezado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                progress.budget.description,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Cuenta: ${progress.budget.account.name}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusChip(progress.status),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Gráfico de progreso
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Row(
                        children: [
                          // Gráfico circular
                          Expanded(
                            flex: 1,
                            child: totalAmount > 0
                                ? PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: progress.spent.toDouble(),
                                          title: '',
                                          color: progress.progressPercentage >
                                                  100
                                              ? Colors.red
                                              : Theme.of(context).primaryColor,
                                          radius: 45,
                                          showTitle: false,
                                        ),
                                        if (progress.remaining > 0)
                                          PieChartSectionData(
                                            value:
                                                progress.remaining.toDouble(),
                                            title: '',
                                            color: Colors.grey[300],
                                            radius: 45,
                                            showTitle: false,
                                          ),
                                      ],
                                      sectionsSpace: 0,
                                      centerSpaceRadius: 35,
                                      startDegreeOffset: -90,
                                    ),
                                    swapAnimationDuration:
                                        const Duration(milliseconds: 800),
                                    swapAnimationCurve: Curves.easeInOutQuint,
                                  )
                                : Center(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.account_balance_wallet_outlined,
                                        size: 40,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                          ),

                          // Leyenda y datos
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Porcentaje en el centro
                                  Text(
                                    "${progress.progressPercentage.toStringAsFixed(1)}%",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: progress.progressPercentage > 100
                                          ? Colors.red
                                          : Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "del presupuesto usado",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  // Gastado vs Restante
                                  _buildLegendItem(
                                    "Gastado",
                                    _currencyFormat.format(progress.spent),
                                    progress.progressPercentage > 100
                                        ? Colors.red
                                        : Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildLegendItem(
                                    "Restante",
                                    _currencyFormat.format(progress.remaining),
                                    Colors.grey[600]!,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Tarjeta con detalles adicionales
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Detalles del presupuesto",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Presupuesto total
                    _buildDetailRow(
                      "Monto total:",
                      _currencyFormat.format(progress.budget.amount),
                      icon: Icons.account_balance_wallet,
                    ),

                    // Período
                    _buildDetailRow(
                      "Período:",
                      "${DateFormat('dd/MM/yyyy').format(progress.budget.startDate)} - ${DateFormat('dd/MM/yyyy').format(progress.budget.endDate)}",
                      icon: Icons.date_range,
                    ),

                    // Días restantes
                    _buildDetailRow(
                      "Días restantes:",
                      "${progress.daysRemaining} días",
                      icon: Icons.timer,
                    ),

                    // Tipo de presupuesto
                    _buildDetailRow(
                      "Tipo:",
                      progress.isLongTerm ? "Largo plazo" : "Corto plazo",
                      icon: Icons.watch_later_outlined,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // // Botón para crear nuevo presupuesto (solo visible cuando ya hay presupuestos)
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton.icon(
            //     onPressed: _navigateToBudgetCreate,
            //     icon: const Icon(Icons.add),
            //     label: const Text('Crear otro presupuesto'),
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 12),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    IconData chipIcon;

    switch (status.toLowerCase()) {
      case 'en progreso':
        chipColor = Colors.blue;
        chipIcon = Icons.access_time;
        break;
      case 'completado':
        chipColor = Colors.green;
        chipIcon = Icons.check_circle;
        break;
      case 'excedido':
        chipColor = Colors.red;
        chipIcon = Icons.warning;
        break;
      default:
        chipColor = Colors.orange;
        chipIcon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(chipIcon, size: 16, color: chipColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBudgetsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes presupuestos activos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea tu primer presupuesto para empezar a controlar tus gastos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToBudgetCreate,
            icon: const Icon(Icons.add),
            label: const Text('Crear presupuesto'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar presupuestos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBudgets,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
