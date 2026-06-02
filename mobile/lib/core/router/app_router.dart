import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/groups/groups_screen.dart';
import '../../features/groups/group_detail_screen.dart';
import '../../features/expenses/add_expense_screen.dart';
import '../../features/expenses/expenses_screen.dart';
import '../../features/payments/payments_screen.dart';
import '../../features/payments/payment_detail_screen.dart';
import '../../features/payments/payment_success_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/premium_screen.dart';
import '../../features/subscriptions/subscriptions_screen.dart';
import '../../features/goals/goals_screen.dart';
import '../../features/tasks/tasks_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../providers/auth_provider.dart';
import '../widgets/main_shell.dart';

/// Uygulama navigasyon yönlendiricisi.
/// GoRouter ile declarative routing + auth redirect kullanılıyor.
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  /// Router'ın auth durumunu takip edebilmesi için ref gerekiyor.
  static GoRouter createRouter(Ref ref) {
    final authNotifier = ref.read(authProvider.notifier);

    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = ref.read(authProvider).isLoggedIn;
        final isOnLogin = state.matchedLocation == '/login';

        if (!isLoggedIn && !isOnLogin) return '/login';
        if (isLoggedIn && isOnLogin) return '/';
        return null;
      },
      refreshListenable: _AuthChangeNotifier(ref),
      routes: [
        // ─── Login ──────────────────────────────────
        GoRoute(
          path: '/login',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const LoginScreen(),
        ),
        // ─── Ana Shell (Bottom Navigation / Sol Sidebar ile) ─────
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DashboardScreen(),
              ),
            ),
            GoRoute(
              path: '/groups',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: GroupsScreen(),
              ),
            ),
            GoRoute(
              path: '/expenses',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ExpensesScreen(),
              ),
            ),
            GoRoute(
              path: '/payments',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: PaymentsScreen(),
              ),
            ),
            GoRoute(
              path: '/statistics',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: StatisticsScreen(),
              ),
            ),
            GoRoute(
              path: '/subscriptions',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SubscriptionsScreen(),
              ),
            ),
            GoRoute(
              path: '/goals',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: GoalsScreen(),
              ),
            ),
            GoRoute(
              path: '/tasks',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TasksScreen(),
              ),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: SettingsScreen(),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),

        // ─── Tam Ekran Sayfalar ────────────────────
        GoRoute(
          path: '/groups/:groupId',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => GroupDetailScreen(
            groupId: state.pathParameters['groupId']!,
          ),
        ),
        GoRoute(
          path: '/add-expense',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const AddExpenseScreen(),
        ),
        GoRoute(
          path: '/payment/:paymentId',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => PaymentDetailScreen(
            paymentId: state.pathParameters['paymentId']!,
          ),
        ),
        GoRoute(
          path: '/payment-success',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return PaymentSuccessScreen(
              amount: extra?['amount'] ?? 0.0,
              recipientName: extra?['recipientName'] ?? '',
              totalDebt: extra?['totalDebt'] ?? 0.0,
              remainingAfter: extra?['remainingAfter'] ?? 0.0,
              isPartial: extra?['isPartial'] ?? false,
            );
          },
        ),
        GoRoute(
          path: '/premium',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const PremiumScreen(),
        ),
      ],
    );
  }
}

/// GoRouter'ın auth değişimlerini algılaması için Listenable adaptörü.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

/// Riverpod ile GoRouter'ı birleştiren provider.
final routerProvider = Provider<GoRouter>((ref) {
  return AppRouter.createRouter(ref);
});
