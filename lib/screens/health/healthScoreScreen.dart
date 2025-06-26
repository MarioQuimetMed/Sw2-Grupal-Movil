import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sw2_grupal_movil/providers/authProvider.dart';
import 'package:sw2_grupal_movil/models/HealthScoreModel.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HealthScoreScreen extends StatefulWidget {
  const HealthScoreScreen({super.key});

  @override
  State<HealthScoreScreen> createState() => _HealthScoreScreenState();
}

class _HealthScoreScreenState extends State<HealthScoreScreen> {
  late Future<HeatlhScore> _futureScore;

  @override
  void initState() {
    super.initState();
    _futureScore =
        Provider.of<AuthProvider>(context, listen: false).getHealthScore();
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'alta':
        return Colors.green;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'alta':
        return Icons.sentiment_very_satisfied;
      case 'media':
        return Icons.sentiment_satisfied;
      case 'baja':
        return Icons.sentiment_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  String _getLevelText(String level) {
    switch (level.toLowerCase()) {
      case 'alta':
        return "Salud financiera alta";
      case 'media':
        return "Salud financiera media";
      case 'baja':
        return "Salud financiera baja";
      default:
        return "Sin información";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salud financiera'),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<HeatlhScore>(
        future: _futureScore,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return _buildError("No se pudo obtener la información.");
          }

          final score = snapshot.data!;
          final scores = score.scores;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Score total y nivel
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 12),
                    child: Column(
                      children: [
                        CircularPercentIndicator(
                          radius: 70,
                          lineWidth: 14,
                          percent: (score.totalScore / 100).clamp(0.0, 1.0),
                          animation: true,
                          animationDuration: 900,
                          center: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${score.totalScore}",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: _getLevelColor(score.healthLevel),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Puntaje",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          progressColor: _getLevelColor(score.healthLevel),
                          backgroundColor: Colors.grey[200]!,
                          circularStrokeCap: CircularStrokeCap.round,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getLevelIcon(score.healthLevel),
                              color: _getLevelColor(score.healthLevel),
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getLevelText(score.healthLevel),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getLevelColor(score.healthLevel),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tu salud financiera general es ${score.healthLevel.toLowerCase()}.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Indicadores individuales
                _buildIndicatorCard(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: "Balance positivo",
                  value: scores.balancePositivo,
                  description: scores.balancePositivo < 0.5
                      ? "Tus egresos superan ampliamente tus ingresos. Revisa tus gastos y busca aumentar tus ingresos."
                      : "Tus ingresos superan tus egresos. ¡Buen manejo!",
                  color:
                      scores.balancePositivo < 0.5 ? Colors.red : Colors.green,
                ),
                const SizedBox(height: 16),
                _buildIndicatorCard(
                  context,
                  icon: Icons.receipt_long,
                  title: "Pago de facturas a tiempo",
                  value: scores.pagoFacturasATiempo,
                  description:
                      "No hay problemas detectados en el pago de facturas (o no se evalúa).",
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildIndicatorCard(
                  context,
                  icon: Icons.savings,
                  title: "Ahorros líquidos",
                  value: scores.ahorrosLiquidos,
                  description: scores.ahorrosLiquidos > 0.7
                      ? "Muy buena capacidad de respuesta ante emergencias o imprevistos."
                      : "Tus ahorros líquidos son bajos. Considera ahorrar más para emergencias.",
                  color: scores.ahorrosLiquidos > 0.7
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildIndicatorCard(
                  context,
                  icon: Icons.trending_down,
                  title: "Deuda sostenible",
                  value: scores.deudaSostenible,
                  description: scores.deudaSostenible == 1
                      ? "Excelente, no estás sobreendeudado."
                      : "Tu nivel de deuda es alto respecto a tus ingresos.",
                  color:
                      scores.deudaSostenible == 1 ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 16),
                _buildIndicatorCard(
                  context,
                  icon: Icons.check_circle_outline,
                  title: "Planificación",
                  value: scores.planificacion,
                  description: scores.planificacion == 1
                      ? "Muy buena planificación financiera."
                      : "Estás gastando más de lo presupuestado.",
                  color:
                      scores.planificacion == 1 ? Colors.green : Colors.orange,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicatorCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required double value,
    required String description,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.13),
              child: Icon(icon, color: color, size: 28),
              radius: 28,
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: value.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    color: color,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${(value * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 48),
            const SizedBox(height: 12),
            const Text(
              'Error al obtener la salud financiera',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _futureScore =
                      Provider.of<AuthProvider>(context, listen: false)
                          .getHealthScore();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
