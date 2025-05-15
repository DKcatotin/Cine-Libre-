import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  // Este es tu client_id de OAuth sin el '.apps.googleusercontent.com'
  clientId: '822634328388-mqu0sk6a8f796c8tukpnlk6dlir50ve4',
  scopes: ['email', 'profile'],
);
  final Logger _logger = Logger();

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;
  
Future<AuthResult> signInWithGoogle() async {
  try {
    // 1. Intentar iniciar sesión con Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    // Si el usuario cancela el inicio de sesión
    if (googleUser == null) {
      return AuthResult.error('Inicio de sesión con Google cancelado');
    }
    
    try {
      // 2. Obtener autenticación de Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // 3. Crear credenciales de Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // 4. Intentar iniciar sesión en Firebase
      await _auth.signInWithCredential(credential);
      
      // 5. Este paso es clave: verificar si el usuario está autenticado
      // independientemente de si hubo un error en el paso anterior
      final user = _auth.currentUser;
      
      if (user != null) {
        _logger.i('Usuario autenticado con Google: ${user.email}');
        return AuthResult.success(user);
      } else {
        return AuthResult.error('No se pudo completar el inicio de sesión con Google');
      }
    } catch (firebaseError) {
      _logger.e('Error durante autenticación con Firebase:', error: firebaseError);
      
      // *** IMPORTANTE: Este paso comprueba si, a pesar del error,
      // el usuario logró autenticarse en Firebase
      final user = _auth.currentUser;
      if (user != null) {
        _logger.i('Usuario autenticado a pesar del error: ${user.email}');
        return AuthResult.success(user);
      }
      
      return AuthResult.error('Error durante el proceso de autenticación');
    }
  } catch (e) {
    _logger.e('Error en el inicio de sesión con Google:', error: e);
    
    // A pesar del error, verificamos si hay un usuario autenticado
    final user = _auth.currentUser;
    if (user != null) {
      _logger.i('Usuario autenticado a pesar de errores: ${user.email}');
      return AuthResult.success(user);
    }
    
    return AuthResult.error('No se pudo completar el inicio de sesión con Google');
  }
}
Future<AuthResult> switchGoogleAccount() async {
  try {
    // 1. Cerrar sesión en Firebase
    await _auth.signOut();
    
    // 2. Cerrar sesión en Google
    await _googleSignIn.signOut();
    
    // 3. Forzar el selector de cuentas de Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      return AuthResult.error('Selección de cuenta cancelada');
    }
    
    // 4. Continuar con el proceso normal de autenticación
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    
    await _auth.signInWithCredential(credential);
    
    final user = _auth.currentUser;
    if (user != null) {
      _logger.i('Cambio de cuenta exitoso: ${user.email}');
      return AuthResult.success(user);
    } else {
      return AuthResult.error('No se pudo iniciar sesión con la nueva cuenta');
    }
  } catch (e) {
    _logger.e('Error al cambiar de cuenta:', error: e);
    
    // Verificar si a pesar del error, el usuario está autenticado
    final user = _auth.currentUser;
    if (user != null) {
      return AuthResult.success(user);
    }
    
    return AuthResult.error('Error al cambiar de cuenta');
  }
}
// En auth_service.dart
Future<AuthResult> changePassword(String currentPassword, String newPassword) async {
  try {
    // Verificar que haya un usuario autenticado
    final user = _auth.currentUser;
    if (user == null) {
      return AuthResult.error('No hay ningún usuario autenticado');
    }
    
    // Verificar si el usuario inició sesión con Google
    if (user.providerData.any((provider) => provider.providerId == 'google.com')) {
      return AuthResult.error('No se puede cambiar la contraseña para cuentas de Google. Por favor, gestiona tu cuenta desde la configuración de Google.');
    }
    
    // Verificar que el usuario tenga un email (necesario para reautenticar)
    if (user.email == null) {
      return AuthResult.error('No se puede cambiar la contraseña sin un correo electrónico asociado');
    }
    
    try {
      // Reautenticar al usuario para verificar su contraseña actual
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Cambiar la contraseña
      await user.updatePassword(newPassword);
      
      _logger.i('Contraseña actualizada correctamente para el usuario ${user.email}');
      return AuthResult(
        success: true,
        user: user,
        errorMessage: 'Contraseña actualizada correctamente',
      );
    } catch (e) {
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            return AuthResult.error('La contraseña actual es incorrecta', code: e.code);
          case 'weak-password':
            return AuthResult.error('La nueva contraseña es demasiado débil', code: e.code);
          case 'requires-recent-login':
            return AuthResult.error('Por razones de seguridad, inicia sesión nuevamente antes de cambiar tu contraseña', code: e.code);
          default:
            return AuthResult.error(e.message ?? 'Error al cambiar la contraseña', code: e.code);
        }
      }
      
      return AuthResult.error('Error al cambiar la contraseña: ${e.toString()}');
    }
  } catch (e) {
    _logger.e('Error en changePassword:', error: e);
    return AuthResult.error('Error inesperado al cambiar la contraseña');
  }
}
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