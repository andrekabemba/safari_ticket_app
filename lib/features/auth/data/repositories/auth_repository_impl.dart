import 'package:achat_ticketbus/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabase;

  AuthRepositoryImpl(this._supabase);

  @override
  Future<void> signIn(String email, String motDePasse) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: motDePasse,
      );
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }

  @override
  Future<void> signUp(String email, String motDePasse) async {
    try {
      await _supabase.auth.signUp(email: email, password: motDePasse);
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }

  @override
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  @override
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  @override
  String? get currentUserId => _supabase.auth.currentUser?.id;
}
