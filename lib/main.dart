import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:sw2_grupal_movil/providers/accountProvider.dart';
import 'package:sw2_grupal_movil/providers/budgetProvider.dart';
import 'package:sw2_grupal_movil/providers/stripeProvider.dart';
import 'package:sw2_grupal_movil/providers/transactionProvider.dart';
import 'package:sw2_grupal_movil/screens/auth/LoginScreen.dart';
import 'providers/authProvider.dart';

// Clase base segura para todos tus ChangeNotifiers
class SafeChangeNotifier extends ChangeNotifier {
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Stripe con tu clave publicable
  Stripe.publishableKey =
      'pk_test_51PGr4tJmV4ccFmKGcucIIVmeu0RoeDOzHpgqmEJ4nQm29Pw5uzSD6M2GAivvkGArSCU16Zcja1qbtxtEXIwjMVxm009e8DBGFI';

  // Configuración para múltiples providers en la raíz de la aplicación
  runApp(
    MultiProvider(
      providers: [
        // Añadimos el AuthProvider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => StripeProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Podríamos usar el AuthProvider aquí para decidir qué pantalla mostrar
    // final authProvider = Provider.of<AuthPr
    // ovider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Aplicación',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
