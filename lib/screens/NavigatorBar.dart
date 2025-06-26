import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:sw2_grupal_movil/screens/Budget/BudgetScreen.dart';
import 'package:sw2_grupal_movil/screens/health/healthScoreScreen.dart';
import 'package:sw2_grupal_movil/screens/stripe/PlansScreen.dart';
import 'package:sw2_grupal_movil/screens/transacction/transactionScreen.dart';
import 'account/accountHomeScreen.dart';

class NavigatorBar extends StatefulWidget {
  const NavigatorBar({super.key});

  @override
  State<NavigatorBar> createState() => _NavigatorBarState();
}

class _NavigatorBarState extends State<NavigatorBar> {
  int _selectedIndex = 0;

  // Lista de páginas a mostrar
  final List<Widget> _pages = const [
    AccountHomeScreen(),
    TransactionScreen(),
    BudgetScreen(),
    HealthScoreScreen(),
    PlansScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Obtenemos los colores del tema actual
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.creditcard),
                activeIcon: Icon(CupertinoIcons.creditcard_fill),
                label: 'Cuenta',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.arrow_right_arrow_left),
                activeIcon:
                    Icon(CupertinoIcons.arrow_right_arrow_left_circle_fill),
                label: 'Transacciones',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.doc_chart),
                activeIcon: Icon(CupertinoIcons.doc_chart_fill),
                label: 'Presupuestos',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.waveform_path_ecg),
                activeIcon: Icon(CupertinoIcons.person_fill),
                label: 'Salud',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.calendar_badge_plus),
                activeIcon: Icon(CupertinoIcons.calendar_badge_plus),
                label: 'Plan',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder(
      child: Text('Home Page'),
    );
  }
}
