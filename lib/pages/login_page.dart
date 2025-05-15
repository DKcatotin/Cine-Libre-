import 'package:cine_libre/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import '../services/auth_service.dart';
import 'home_page.dart';
import '../widgets/app_logo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  //final _authService = AuthService();

 void _handleLogin() async {
  final email = _userCtrl.text.trim();
  final password = _passCtrl.text.trim();
if (!RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Formato de correo inválido')),
  );
  return;
}

  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      // Leer datos del usuario desde Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      if (userData != null) {
        debugPrint("Nombre: ${userData['nombre']}");
        debugPrint("Usuario: ${userData['usuario']}");
        // Puedes pasar estos datos al HomePage si quieres
      }
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } on FirebaseAuthException catch (e) {
  String message = 'Error al iniciar sesión';
  switch (e.code) {
    case 'user-not-found':
      message = 'Usuario no encontrado';
      break;
    case 'wrong-password':
      message = 'Contraseña incorrecta';
      break;
    case 'invalid-email':
      message = 'Formato de correo no válido';
      break;
    case 'too-many-requests':
      message = 'Demasiados intentos, intenta más tarde';
      break;
    default:
      message = 'Error desconocido';
  }

  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const AppLogo(size: 100),
                const SizedBox(height: 20),
                const Text(
                  "Cine Libre",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Usuario',
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.white12,
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("Iniciar sesión"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    );
                  },
                  child: const Text(
                    "¿No tienes cuenta? Regístrate",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
