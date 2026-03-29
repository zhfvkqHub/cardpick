import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_view.dart';
import '../features/auth/signup_view.dart';
import '../features/card/card_list_view.dart';
import '../features/card/card_detail_view.dart';
import '../features/spending/spending_view.dart';
import '../features/spending/spending_form_view.dart';
import '../features/recommendation/recommendation_view.dart';
import '../shared/providers/auth_provider.dart';
import 'home_shell.dart';
import 'theme.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthListenable(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authTokenProvider);

      if (authState.isLoading) {
        return state.uri.path == '/' ? null : '/';
      }

      final isLoggedIn = authState.value != null;
      final loc = state.uri.path;
      final isOnAuthPage = loc == '/login' || loc == '/signup';

      if (!isLoggedIn && !isOnAuthPage) return '/login';
      if (isLoggedIn && (isOnAuthPage || loc == '/')) return '/cards';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const _SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginView()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupView()),
      ShellRoute(
        builder: (ctx, state, child) =>
            HomeShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/cards',
            builder: (_, __) => const CardListView(),
          ),
          GoRoute(
            path: '/cards/:id',
            builder: (_, state) {
              final idStr = state.pathParameters['id'] ?? '';
              final id = int.tryParse(idStr);
              if (id == null) {
                return const Scaffold(
                  body: Center(child: Text('잘못된 카드 ID입니다')),
                );
              }
              return CardDetailView(cardId: id);
            },
          ),
          GoRoute(
            path: '/spending',
            builder: (_, __) => const SpendingView(),
          ),
          GoRoute(
            path: '/spending/edit',
            builder: (_, __) => const SpendingFormView(),
          ),
          GoRoute(
            path: '/recommendation',
            builder: (_, __) => const RecommendationView(),
          ),
        ],
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.credit_card_rounded,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'CardPick',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authTokenProvider, (_, __) => notifyListeners());
  }
}
