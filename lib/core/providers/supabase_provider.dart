import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for accessing the Supabase client instance
/// Use this provider throughout the app for all Supabase operations
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for accessing the current authenticated user
final currentUserProvider = Provider<User?>((ref) {
  // Watch auth state changes to get reactive updates
  final authState = ref.watch(authStateChangesProvider);
  return authState.valueOrNull?.session?.user;
});

/// Provider for listening to auth state changes
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

/// Provider to check if user is authenticated
/// This listens to auth stream for real-time updates
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.valueOrNull?.session != null;
});

/// Listenable for GoRouter to refresh on auth state changes
class AuthNotifierListenable extends ChangeNotifier {
  AuthNotifierListenable(this._ref) {
    _ref.listen(authStateChangesProvider, (previous, next) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

/// Provider for auth listenable (used by GoRouter)
final authListenableProvider = Provider<AuthNotifierListenable>((ref) {
  return AuthNotifierListenable(ref);
});
