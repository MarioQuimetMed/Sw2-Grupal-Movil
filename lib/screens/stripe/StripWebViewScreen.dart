import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String sessionId;

  const StripeWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.sessionId,
  });

  @override
  State<StripeWebViewScreen> createState() => _StripeWebViewScreenState();
}

class _StripeWebViewScreenState extends State<StripeWebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) {
              setState(() {
                isLoading = false;
              });

              // Si la URL contiene "success" o "completed", probablemente el pago fue exitoso
              if (url.toLowerCase().contains('success') ||
                  url.toLowerCase().contains('completed') ||
                  url.toLowerCase().contains('thankyou') ||
                  url.toLowerCase().contains('receipt')) {
                Navigator.pop(context, true); // Indicar éxito
              }
              // Si contiene "cancel" o "failed", el pago fue cancelado o falló
              else if (url.toLowerCase().contains('cancel') ||
                  url.toLowerCase().contains('failed') ||
                  url.toLowerCase().contains('error')) {
                Navigator.pop(context, false); // Indicar cancelación
              }
            }
          },
        ),
      );

    // Cargar la URL después de la inicialización
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.loadRequest(Uri.parse(widget.checkoutUrl));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Confirmar antes de salir si está en proceso de pago
        if (!isLoading) {
          final shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('¿Cancelar pago?'),
                  content: const Text(
                      'Si sales ahora, el proceso de pago se cancelará.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Continuar pago'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Cancelar pago'),
                    ),
                  ],
                ),
              ) ??
              false;

          if (shouldPop) {
            Navigator.pop(
                context, false); // Regresa con resultado de cancelación
          }
          return false; // No cierra el WebView
        }
        return true; // Cierra el WebView si aún está cargando
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Completar Pago'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              // Mismo comportamiento que onWillPop
              if (!isLoading) {
                final shouldClose = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Cancelar pago?'),
                        content: const Text(
                            'Si sales ahora, el proceso de pago se cancelará.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Continuar pago'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Cancelar pago'),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (shouldClose) {
                  Navigator.pop(context, false);
                }
              } else {
                Navigator.pop(context, false);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
        // Botones de ayuda para el usuario
        bottomNavigationBar: isLoading
            ? null
            : BottomAppBar(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('¿Pago completado?'),
                            content: const Text(
                                'Si ya completaste el pago exitosamente pero no fuiste redirigido automáticamente, presiona "Confirmar pago".'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cerrar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context, true); // Indicar éxito
                                },
                                child: const Text('Confirmar pago'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text('¿Completaste el pago?'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
