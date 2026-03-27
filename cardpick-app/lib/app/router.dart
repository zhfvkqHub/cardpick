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

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthListenable(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authTokenProvider);

      // 토큰 로딩 중에는 스플래시(/)에 머무름
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
      // 스플래시 (토큰 로딩 중)
      GoRoute(
        path: '/',
        builder: (_, __) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
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
              final id = int.parse(state.pathParameters['id']!);
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

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authTokenProvider, (_, __) => notifyListeners());
  }
}
