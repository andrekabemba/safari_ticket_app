abstract class AuthRepository {
  Future<void> signIn(String email, String motDePasse);
  Future<void> signUp(String email, String motDePasse);
  Future<void> signOut();

  Stream<dynamic> get authStateChanges;
  String? get currentUserId;
}
