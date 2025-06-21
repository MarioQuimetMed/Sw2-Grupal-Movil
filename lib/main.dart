import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sw2_grupal_movil/providers/accountProvider.dart';
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

void main() {
  // Configuración para múltiples providers en la raíz de la aplicación
  runApp(
    MultiProvider(
      providers: [
        // Añadimos el AuthProvider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
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
    // final authProvider = Provider.of<AuthProvider>(context);

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
