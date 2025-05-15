import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AuthResult {
  final User? user;
  final String? errorMessage;
  final String? errorCode;
  final bool success;

  AuthResult({
    this.user,
    this.errorMessage,
    this.errorCode,
    required this.success,
  });

  // Constructor de conveniencia para éxito
  factory AuthResult.success(User user) {
    return AuthResult(
      user: user,
      success: true,
    );
  }

  // Constructor de conveniencia para error
  factory AuthResult.error(String message, {String? code}) {
    return AuthResult(
      errorMessage: message,
      errorCode: code,
      success: false,
    );
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // MÉTODO SIMPLIFICADO DE REGISTRO (para evitar errores de tipo)
  Future<AuthResult> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return AuthResult.error('Email o contraseña no pueden estar vacíos');
    }

    try {
      // Realizar registro simplificado
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verificar usuario actual
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        return AuthResult.success(currentUser);
      } else {
        return AuthResult.error('No se pudo completar el registro');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      
      switch (e.code) {
        case 'email-already-in-use':
          message = 'El email ya está en uso';
          break;
        case 'weak-password':
          message = 'La contraseña es demasiado débil';
          break;
        case 'invalid-email':
          message = 'El formato del email no es válido';
          break;
        default:
          message = e.message ?? 'Error desconocido en registro';
      }
      
      _logger.e('Error en registro: $message', error: e);
      return AuthResult.error(message, code: e.code);
    } catch (e) {
      _logger.e('Error inesperado en registro:', error: e);
      return AuthResult.error('Error inesperado durante el registro');
    }
  }

  // MÉTODO SIMPLIFICADO DE LOGIN (para evitar errores de tipo)
  // MÉTODO MODIFICADO DE LOGIN (usando enfoque alternativo)
Future<AuthResult> login(String email, String password) async {
  if (email.isEmpty || password.isEmpty) {
    return AuthResult.error('Email o contraseña no pueden estar vacíos');
  }

  try {
    // ENFOQUE ALTERNATIVO: Usar un flujo diferente para evitar el error de PigeonUserDetails
    
    // 1. Primero intentamos cerrar cualquier sesión existente
    try {
      await _auth.signOut();
      _logger.i('Sesión anterior cerrada correctamente');
    } catch (e) {
      _logger.w('No se pudo cerrar la sesión anterior', error: e);
      // Continuamos de todos modos
    }
    
    // 2. Intentamos el inicio de sesión con manejo adicional de errores
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // 3. Verificamos si tenemos un usuario sin acceder a propiedades específicas
      if (userCredential.user != null) {
        // Crear un objeto User básico para evitar acceder a propiedades problemáticas
        User user = userCredential.user!;
        _logger.i('Usuario inició sesión: ${user.email}');
        return AuthResult.success(user);
      }
    } catch (e) {
      _logger.e('Error en inicio de sesión:', error: e);
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            return AuthResult.error('Usuario no encontrado', code: e.code);
          case 'wrong-password':
            return AuthResult.error('Contraseña incorrecta', code: e.code);
          case 'invalid-email':
            return AuthResult.error('El formato del email no es válido', code: e.code);
          case 'user-disabled':
            return AuthResult.error('Este usuario ha sido deshabilitado', code: e.code);
          default:
            return AuthResult.error(e.message ?? 'Error de autenticación', code: e.code);
        }
      }
      // No relanzamos errores específicos de PigeonUserDetails
      if (e.toString().contains('PigeonUserDetails')) {
        // 4. Verificamos si a pesar del error el usuario está autenticado
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          _logger.i('Usuario autenticado a pesar del error: ${currentUser.email}');
          return AuthResult.success(currentUser);
        }
      }
      
      // Para otros errores, devolvemos un mensaje genérico
      return AuthResult.error('Error inesperado durante el inicio de sesión');
    }
    
    // 5. Verificación final por si acaso
    final finalUser = _auth.currentUser;
    if (finalUser != null) {
      _logger.i('Usuario encontrado después de intentos: ${finalUser.email}');
      return AuthResult.success(finalUser);
    }
    
    return AuthResult.error('No se pudo completar el inicio de sesión');
  } catch (e) {
    _logger.e('Error inesperado global en login:', error: e);
    return AuthResult.error('Error inesperado durante el inicio de sesión');
  }
}

  // LOGOUT
  Future<bool> logout() async {
    try {
      await _auth.signOut();
      _logger.i('Usuario cerró sesión');
      return true;
    } catch (e) {
      _logger.e('Error al cerrar sesión:', error: e);
      return false;
    }
  }

  // ESCUCHAR CAMBIOS EN EL USUARIO
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Verificar si el usuario está autenticado
  bool isAuthenticated() {
    return _auth.currentUser != null;
  }

  // Enviar email de verificación
  Future<bool> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        _logger.i('Email de verificación enviado a ${user.email}');
        return true;
      } catch (e) {
        _logger.e('Error al enviar email de verificación:', error: e);
        return false;
      }
    }
    return false;
  }

  // Reestablecer contraseña
  Future<AuthResult> resetPassword(String email) async {
    if (email.isEmpty) {
      return AuthResult.error('El email no puede estar vacío');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _logger.i('Email de recuperación enviado a $email');
      return AuthResult(
        success: true,
        errorMessage: 'Email de recuperación enviado', 
        errorCode: 'reset-email-sent'
      );
    } on FirebaseAuthException catch (e) {
      String message;
      
      switch (e.code) {
        case 'user-not-found':
          message = 'No existe una cuenta con este email';
          break;
        case 'invalid-email':
          message = 'El formato del email no es válido';
          break;
        default:
          message = e.message ?? 'Error al enviar email de recuperación';
      }
      
      _logger.e('Error en resetPassword: $message', error: e);
      return AuthResult.error(message, code: e.code);
    } catch (e) {
      _logger.e('Error inesperado en resetPassword:', error: e);
      return AuthResult.error('Error inesperado al enviar email de recuperación');
    }
  }
}