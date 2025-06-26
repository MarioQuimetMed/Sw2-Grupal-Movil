import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stripeProvider.dart';

class StripeScreen extends StatelessWidget {
  const StripeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stripeProvider = Provider.of<StripeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripción Premium'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información sobre la suscripción
            const Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Premium',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Acceso completo a todas las funciones:'),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Análisis avanzado de transacciones'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Reportes financieros personalizados'),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Sin límites en transacciones mensuales'),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Precio: \$50.00/mes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Mensaje de error si existe
            if (stripeProvider.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stripeProvider.errorMessage!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ),
              ),

            // Botón para realizar el pago
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: stripeProvider.isLoading
                    ? null
                    : () async {
                        final success =
                            await stripeProvider.processSubscriptionPayment(
                          planId: 1, // ID del plan de suscripción
                          context: context,
                          isAnnual: false, // Cambia a true si es anual
                        );
                        if (success) {
                          // Mostrar mensaje de éxito
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('¡Pago completado con éxito!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Navegar de regreso o a pantalla de confirmación
                            // Navigator.pop(context);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: stripeProvider.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Suscribirse ahora',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Los pagos son procesados de forma segura a través de Stripe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
