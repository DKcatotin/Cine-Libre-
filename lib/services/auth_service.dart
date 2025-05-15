import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // REGISTRO
  Future<User?> register(String email, String password) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      _logger.e('Error en registro:', error: e);
      return null;
    }
  }

  // LOGIN
  Future<User?> login(String email, String password) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCred.user;
    } catch (e) {
      _logger.e('Error en login:', error: e);
      return null;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    _logger.i('Usuario cerró sesión');
  }

  // ESCUCHAR CAMBIOS EN EL USUARIO
  Stream<User?> get userChanges => _auth.authStateChanges();
}
