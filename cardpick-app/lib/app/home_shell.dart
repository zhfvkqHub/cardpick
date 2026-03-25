import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatelessWidget {
  final String location;
  final Widget child;

  const HomeShell({super.key, required this.location, required this.child});

  int get _currentIndex {
    if (location.startsWith('/spending')) return 1;
    if (location.startsWith('/recommendation')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/cards');
              break;
            case 1:
              context.go('/spending');
              break;
            case 2:
              context.go('/recommendation');
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.credit_card_outlined),
            selectedIcon: Icon(Icons.credit_card),
            label: '카드',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: '소비 패턴',
          ),
          NavigationDestination(
            icon: Icon(Icons.stars_outlined),
            selectedIcon: Icon(Icons.stars),
            label: '추천',
          ),
        ],
      ),
    );
  }
}
