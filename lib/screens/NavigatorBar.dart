import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    Home(),
    Home(),
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
                label: 'Cuentas',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.arrow_right_arrow_left),
                activeIcon:
                    Icon(CupertinoIcons.arrow_right_arrow_left_circle_fill),
                label: 'Transacciones',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.person),
                activeIcon: Icon(CupertinoIcons.person_fill),
                label: 'Perfil',
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
