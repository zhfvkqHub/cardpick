import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme.dart';

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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
        ),
        child: NavigationBar(
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
              selectedIcon: Icon(Icons.credit_card_rounded),
              label: '카드',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: '소비',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: '추천',
            ),
          ],
        ),
      ),
    );
  }
}
