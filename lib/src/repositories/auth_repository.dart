import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // Você pode injetar o FirebaseAuth ou instanciar direto
  AuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  // Método de Login
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Método de Cadastro
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Método para atualizar o email
  Future<void> updateEmail(String newEmail) async {
    // Obter o usuário atual
    final user = _firebaseAuth.currentUser;

    // Verificar login
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Nenhum usuário logado para atualizar o email',
      );
    }

    // Tenta atualizar o email
    try {
      await user.verifyBeforeUpdateEmail(newEmail);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  // Método de Logout
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}
