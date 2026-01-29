import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/providers/supabase_provider.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/finance/presentation/screens/finance_screen.dart';
import '../features/finance/presentation/screens/add_transaction_screen.dart';
import '../features/spiritual/presentation/screens/spiritual_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../features/wishlist/presentation/screens/add_wishlist_screen.dart';
import '../shared/widgets/app_shell.dart';

/// Route names for type-safe navigation
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String finance = '/finance';
  static const String addTransaction = '/finance/add';
  static const String spiritual = '/spiritual';
  static const String calendar = '/calendar';
  static const String wishlist = '/wishlist';
  static const String addWishlist = '/wishlist/add';
}

/// Navigation key for accessing navigator state
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter provider
final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = ref.watch(authListenableProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: authListenable,
    redirect: (context, state) {
      // Get auth state from stream
      final authState = ref.read(authStateChangesProvider);
      final isAuthenticated = authState.valueOrNull?.session != null;
      
      // Also check synchronous session for initial load
      final hasSession = Supabase.instance.client.auth.currentSession != null;
      final isLoggedIn = isAuthenticated || hasSession;
      
      final isLoggingIn = state.matchedLocation == AppRoutes.login;
      final isRegistering = state.matchedLocation == AppRoutes.register;
      final isSplash = state.matchedLocation == AppRoutes.splash;

      // If not authenticated, redirect to login (except for login/register pages)
      if (!isLoggedIn) {
        if (isLoggingIn || isRegistering) {
          return null; // Stay on login/register page
        }
        return AppRoutes.login;
      }

      // If authenticated and on auth pages, redirect to dashboard
      if (isLoggedIn && (isLoggingIn || isRegistering || isSplash)) {
        return AppRoutes.dashboard;
      }

      return null; // No redirect
    },
    routes: [
      // Splash/Initial route
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.finance,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FinanceScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.spiritual,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SpiritualScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.calendar,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.wishlist,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WishlistScreen(),
            ),
          ),
        ],
      ),

      // Full screen routes (outside shell)
      GoRoute(
        path: AppRoutes.addTransaction,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: AppRoutes.addWishlist,
        builder: (context, state) => const AddWishlistScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error?.message ?? 'Unknown error'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Splash screen shown during initialization
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.self_improvement,
              size: 80,
              color: Color(0xFF0D9488),
            ),
            SizedBox(height: 24),
            Text(
              'Fahmi Alfaqih',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Personal Productivity Tracker',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
            ),
          ],
        ),
      ),
    );
  }
}
