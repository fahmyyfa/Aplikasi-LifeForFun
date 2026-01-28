import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

/// Repository for authentication operations
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Get current user
  User? get currentUser => _client.auth.currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );
    return response;
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Get user profile
  Future<ProfileModel?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return ProfileModel.fromJson(response);
  }

  /// Update user profile
  Future<ProfileModel> updateProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    final response = await _client
        .from('profiles')
        .update({
          if (fullName != null) 'full_name': fullName,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId)
        .select()
        .single();

    return ProfileModel.fromJson(response);
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }
}
