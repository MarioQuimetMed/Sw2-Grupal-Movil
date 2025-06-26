import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stripeProvider.dart';
import '../../providers/authProvider.dart';
import '../../models/PlansGetModel.dart';
import '../../models/MyPlanGetModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  bool _isAnnual = false;
  bool _isLoading = false;
  MyPlayGetResponse? _activePlan;

  @override
  void initState() {
    super.initState();

    // Programar la carga después del build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  String _inferPlanType() {
    // Calcular la duración del plan
    final startDate = _activePlan!.userPlan.startDate;
    final endDate = _activePlan!.userPlan.endDate;
    final duration = endDate.difference(startDate).inDays;

    // Si es aproximadamente un año (365 ± margen de error)
    return (duration > 300) ? 'Anual' : 'Mensual';
  }

  // Método para cargar tanto el plan activo como los planes disponibles
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _activePlan = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final stripeProvider = Provider.of<StripeProvider>(context, listen: false);

    // Solo si hay un usuario autenticado
    if (authProvider.user?.id != null) {
      // Primero intentamos cargar el plan activo
      _activePlan =
          await stripeProvider.fetchMyActivePlan(authProvider.user!.id);
    }

    // Cargar los planes disponibles si no hay plan activo
    if (_activePlan == null) {
      await stripeProvider.fetchPlans();
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final stripeProvider = Provider.of<StripeProvider>(context);
    final plans = stripeProvider.plans;
    final errorMessage = stripeProvider.errorMessage;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_activePlan != null ? 'Mi Suscripción' : 'Escoge tu Plan'),
        elevation: 0,
        actions: _activePlan != null
            ? [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                  tooltip: 'Actualizar información',
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _activePlan != null
                ? _buildActivePlanView()
                : _buildPlansListView(plans, errorMessage),
      ),
    );
  }

  Widget _buildActivePlanView() {
    // Formatear las fechas
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    // final startDate = _activePlan!.userPlan.startDate;
    final startDate = formatter.format(_activePlan!.userPlan.startDate);
    // final endDate = _activePlan!.userPlan.endDate;
    final endDate = formatter.format(_activePlan!.userPlan.endDate);

    // Calcular días restantes
    final now = DateTime.now();
    final end = _activePlan!.userPlan.endDate;
    final daysRemaining = end.difference(now).inDays;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estado de la suscripción
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Suscripción Activa',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Quedan $daysRemaining días',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Detalles del plan
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _activePlan!.userPlan.plan.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${_activePlan!.userPlan.plan.priceMonthly}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cuerpo
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detalles de la suscripción',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Fecha de inicio
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          title: 'Fecha de inicio',
                          value: startDate,
                        ),
                        const SizedBox(height: 8),

                        // Fecha de finalización
                        _buildInfoRow(
                          icon: Icons.event,
                          title: 'Fecha de finalización',
                          value: endDate,
                        ),
                        const SizedBox(height: 8),

                        // Tipo de plan
                        _buildInfoRow(
                          icon: Icons.repeat,
                          title: 'Tipo',
                          // La propiedad isAnnual no existe directamente en el modelo
                          // Debemos inferirla comparando fechas o por otro método
                          value: _inferPlanType(),
                        ),

                        const SizedBox(height: 16),

                        // Descripción
                        Text(
                          _activePlan!.userPlan.plan.description,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Nota sobre renovación
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Renovación automática',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu suscripción se renovará automáticamente al finalizar el período actual. Puedes cancelar en cualquier momento desde la configuración de tu cuenta.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[700]),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPlansListView(
      List<PlansGetResponse> plans, String? errorMessage) {
    return Column(
      children: [
        // Toggle para cambiar entre planes mensuales y anuales

        //Que muestre que su plan actual es el Gratutito
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Plan Gratuito',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Actualmente estás usando el plan gratuito. Disfruta de las funciones básicas sin costo.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Mensual',
                style: TextStyle(
                  fontWeight: _isAnnual ? FontWeight.normal : FontWeight.bold,
                  color:
                      _isAnnual ? Colors.grey : Theme.of(context).primaryColor,
                ),
              ),
              CupertinoSwitch(
                value: _isAnnual,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) {
                  setState(() {
                    _isAnnual = value;
                  });
                },
              ),
              Text(
                'Anual',
                style: TextStyle(
                  fontWeight: _isAnnual ? FontWeight.bold : FontWeight.normal,
                  color:
                      _isAnnual ? Theme.of(context).primaryColor : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ahorra 20%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Error message
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // No plans found
        if (plans.isEmpty && errorMessage == null)
          const Expanded(
            child: Center(
              child: Text(
                'No hay planes disponibles en este momento.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),

        // Plans list
        if (plans.isNotEmpty)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  return _buildPlanCard(context, plans[index]);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, PlansGetResponse plan) {
    final price =
        _isAnnual ? '\$${plan.priceAnnual}/año' : '\$${plan.priceMonthly}/mes';

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  plan.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _selectPlan(context, plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'Seleccionar ${plan.name}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectPlan(BuildContext context, PlansGetResponse plan) async {
    final stripeProvider = Provider.of<StripeProvider>(context, listen: false);

    try {
      final success = await stripeProvider.processSubscriptionPayment(
        planId: plan.id,
        context: context,
        isAnnual: _isAnnual,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Suscripción activada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );

        // Cargar el plan activo después de una compra exitosa
        _loadData();
      }
    } catch (e) {
      // El error ya está manejado en el provider
    }
  }
}
