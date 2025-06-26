import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:sw2_grupal_movil/models/transacctionCreateModel.dart';
import 'package:sw2_grupal_movil/providers/authProvider.dart';
import 'package:sw2_grupal_movil/providers/transactionProvider.dart';
import 'package:sw2_grupal_movil/screens/account/createAccountScreen.dart';
import 'package:sw2_grupal_movil/screens/account/suggestionsScreen.dart';
import 'package:sw2_grupal_movil/screens/auth/LoginScreen.dart';
import '../../providers/accountProvider.dart';
import 'package:intl/intl.dart';

class AccountHomeScreen extends StatefulWidget {
  const AccountHomeScreen({super.key});

  @override
  State<AccountHomeScreen> createState() => _AccountHomeScreenState();
}

class _AccountHomeScreenState extends State<AccountHomeScreen> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _recognizedText = '';
  @override
  void initState() {
    super.initState();
    // Cargar cuentas al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
      _initSpeech(); // Inicializar el reconocimiento de voz
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    setState(() {
      _recognizedText = '';
    });

    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'es_ES', // Para español
    );

    setState(() {});

    // Mostrar un modal con efecto de grabación
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildVoiceRecognitionModal(),
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});

    // Cerrar el modal
    if (context.mounted) {
      Navigator.of(context).pop();

      // Si reconoció texto, mostrar diálogo de confirmación
      if (_recognizedText.isNotEmpty) {
        _showConfirmationDialog(_recognizedText);
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _recognizedText = result.recognizedWords;
    });
  }

  // Formateador para los montos
  String _formatBalance(String balance) {
    try {
      final numericBalance = double.parse(balance);
      return NumberFormat.currency(
        symbol: 'Bs/. ',
        decimalDigits: 2,
      ).format(numericBalance);
    } catch (e) {
      return balance;
    }
  }

  Widget _buildVoiceRecognitionModal() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarGlow(
            animate: _speechToText.isListening,
            glowColor: Theme.of(context).primaryColor,
            // endRadius: 75.0,
            // glowRadiusFactor: 75 - 0,
            duration: const Duration(milliseconds: 2000),
            // repeatPauseDuration: const Duration(milliseconds: 100),
            startDelay: const Duration(milliseconds: 100),
            repeat: true,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                CupertinoIcons.mic,
                color: Theme.of(context).primaryColor,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _speechToText.isListening
                ? 'Escuchando...'
                : 'Presiona para hablar',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              _recognizedText.isEmpty
                  ? 'Di tu transacción. Por ejemplo: "Gasté 30 bs en comida"'
                  : _recognizedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _stopListening,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Detener',
                style: TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(String text) {
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);

    if (accountProvider.accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tienes cuenta disponible')),
      );
      return;
    }

    final account = accountProvider.accounts.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar transacción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Quieres procesar esta transacción?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cuenta: ${account.name}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processTransaction(text, account.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Procesar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              )),
        ],
      ),
    );
  }

  void _processTransaction(String text, int accountId) async {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    final accountProvider =
        Provider.of<AccountProvider>(context, listen: false);

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success =
          await transactionProvider.processTransactionWithAI(text, accountId);

      // Cerrar el indicador de carga
      if (context.mounted) Navigator.pop(context);

      if (success) {
        // Recargar la cuenta para actualizar el balance
        await accountProvider.refreshAccounts();

        // Mostrar el resultado
        if (context.mounted) {
          _showTransactionSuccessDialog(transactionProvider.lastTransaction!);
        }
      } else {
        // Mostrar el error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${transactionProvider.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar el indicador de carga
      if (context.mounted) Navigator.pop(context);

      // Mostrar el error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTransactionSuccessDialog(TransactionCreateResponse transaction) {
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Transacción exitosa!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: transactionProvider
                    .getTransactionColor(transaction.type)
                    .withOpacity(0.2),
                child: Icon(
                  transaction.type.toLowerCase() == 'income'
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color:
                      transactionProvider.getTransactionColor(transaction.type),
                ),
              ),
              title: Text(
                transaction.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${transactionProvider.getTransactionTypeInSpanish(transaction.type)} • ${DateFormat('dd/MM/yyyy').format(transaction.date)}',
              ),
              trailing: Text(
                transactionProvider.formatAmount(
                    transaction.amount, transaction.type),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color:
                      transactionProvider.getTransactionColor(transaction.type),
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Aceptar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Mis Cuentas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.refresh, color: Colors.black54),
            onPressed: () {
              Provider.of<AccountProvider>(context, listen: false)
                  .refreshAccounts();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              // Aquí llamas a tu método de logout del AuthProvider
              Provider.of<AuthProvider>(context, listen: false).logout();
              // Y navegas al LoginScreen o pantalla inicial
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AccountProvider>(
        builder: (context, accountProvider, _) {
          // Mostrar indicador de carga
          if (accountProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Mostrar mensaje de error
          if (accountProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    size: 50,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Algo salió mal',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Text(
                      accountProvider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.red[700],
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      accountProvider.fetchAccounts();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red[700],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Mostrar mensaje cuando no hay cuentas
          if (!accountProvider.hasAccounts) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.creditcard,
                    size: 70,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes cuenta',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contacta con soporte para crear una cuenta',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  // Boton para crear una cuenta
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Aquí podrías navegar a una pantalla para crear una cuenta
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccountCreateScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Crear cuenta'),
                  ),
                ],
              ),
            );
          }

          // Si solo hay una cuenta, mostrarla de forma especial
          if (accountProvider.accounts.length == 1) {
            final account = accountProvider.accounts.first;
            //setear la cuenta seleccionada en el provider

            WidgetsBinding.instance.addPostFrameCallback((_) {
              accountProvider.selectAccount(account.id);
            });

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Encabezado "Tu cuenta"
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    child: Text(
                      'Tu cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                  // Tarjeta principal con detalles de la cuenta
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                account.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                account.isActive
                                    ? CupertinoIcons.checkmark_seal_fill
                                    : CupertinoIcons.xmark_seal_fill,
                                color: account.isActive
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const Text(
                            'Balance disponible',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatBalance(account.balance),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Botones de acciones
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      'Acciones rápidas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          icon: CupertinoIcons.arrow_right,
                          label: 'Transacciones',
                          onTap: () {
                            // Acción para transferir
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: CupertinoIcons.doc_text,
                          label: 'Presupuesto',
                          onTap: () {
                            // Acción para ver movimientos
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          icon: CupertinoIcons.settings,
                          label: 'Sugerencias',
                          onTap: () {
                            // Acción para ir a sugenrencias
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SuggestionsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }

          // Mostrar lista de cuentas (más de una)
          return RefreshIndicator(
            onRefresh: () => accountProvider.refreshAccounts(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
                    child: Text(
                      'Tus cuentas (${accountProvider.accounts.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: accountProvider.accounts.length,
                      itemBuilder: (context, index) {
                        final account = accountProvider.accounts[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              accountProvider.selectAccount(account.id);
                              // Aquí podrías navegar a una pantalla de detalles
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.creditcard,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          account.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          account.isActive
                                              ? 'Activa'
                                              : 'Inactiva',
                                          style: TextStyle(
                                            color: account.isActive
                                                ? Colors.green[700]
                                                : Colors.red[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatBalance(account.balance),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // Botón para agregar nueva cuenta (opcional)

      floatingActionButton: AvatarGlow(
        animate: _speechToText.isListening,
        glowColor: Theme.of(context).primaryColor,
        // glowRadiusFactor: 40.0,
        // endRadius: 40.0,
        duration: const Duration(milliseconds: 2000),
        // repeatPauseDuration: const Duration(milliseconds: 100),
        startDelay: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: () {
            if (_speechToText.isNotListening) {
              _startListening();
            } else {
              _stopListening();
            }
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(_speechToText.isNotListening ? Icons.mic : Icons.stop),
        ),
      ),
    );
  }

  // Widget helper para los botones de acción
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
