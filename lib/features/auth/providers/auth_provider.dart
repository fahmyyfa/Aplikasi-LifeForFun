import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/supabase_provider.dart';
import '../data/models/profile_model.dart';
import '../data/repositories/auth_repository.dart';

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

/// Auth state for the app (renamed to avoid conflict with Supabase AuthState)
sealed class AppAuthState {
  const AppAuthState();
}

class AppAuthStateInitial extends AppAuthState {
  const AppAuthStateInitial();
}

class AppAuthStateLoading extends AppAuthState {
  const AppAuthStateLoading();
}

class AppAuthStateAuthenticated extends AppAuthState {
  final User user;
  final ProfileModel? profile;

  const AppAuthStateAuthenticated({required this.user, this.profile});
}

class AppAuthStateUnauthenticated extends AppAuthState {
  const AppAuthStateUnauthenticated();
}

class AppAuthStateError extends AppAuthState {
  final String message;

  const AppAuthStateError(this.message);
}

/// Auth notifier using AsyncNotifier pattern
class AuthNotifier extends AsyncNotifier<AppAuthState> {
  late AuthRepository _repository;

  @override
  Future<AppAuthState> build() async {
    _repository = ref.read(authRepositoryProvider);

    // Listen to auth state changes
    ref.listen(authStateChangesProvider, (previous, next) {
      next.whenData((authState) {
        if (authState.session != null) {
          _loadUserProfile();
        } else {
          state = const AsyncData(AppAuthStateUnauthenticated());
        }
      });
    });

    // Check current auth state
    final user = _repository.currentUser;
    if (user != null) {
      final profile = await _repository.getProfile(user.id);
      return AppAuthStateAuthenticated(user: user, profile: profile);
    }

    return const AppAuthStateUnauthenticated();
  }

  Future<void> _loadUserProfile() async {
    final user = _repository.currentUser;
    if (user != null) {
      final profile = await _repository.getProfile(user.id);
      state = AsyncData(AppAuthStateAuthenticated(user: user, profile: profile));
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );

      if (response.user != null) {
        final profile = await _repository.getProfile(response.user!.id);
        state = AsyncData(
          AppAuthStateAuthenticated(user: response.user!, profile: profile),
        );
      } else {
        state = const AsyncData(AppAuthStateError('Sign up failed. Please try again.'));
      }
    } on AuthException catch (e) {
      state = AsyncData(AppAuthStateError(e.message));
    } catch (e) {
      state = AsyncData(AppAuthStateError(e.toString()));
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final response = await _repository.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final profile = await _repository.getProfile(response.user!.id);
        state = AsyncData(
          AppAuthStateAuthenticated(user: response.user!, profile: profile),
        );
      } else {
        state = const AsyncData(AppAuthStateError('Sign in failed. Please try again.'));
      }
    } on AuthException catch (e) {
      state = AsyncData(AppAuthStateError(e.message));
    } catch (e) {
      state = AsyncData(AppAuthStateError(e.toString()));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AsyncLoading();

    try {
      await _repository.signOut();
      state = const AsyncData(AppAuthStateUnauthenticated());
    } catch (e) {
      state = AsyncData(AppAuthStateError(e.toString()));
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _repository.resetPassword(email);
    } on AuthException catch (e) {
      state = AsyncData(AppAuthStateError(e.message));
    }
  }
}

/// Provider for AuthNotifier
final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AppAuthState>(() {
  return AuthNotifier();
});
