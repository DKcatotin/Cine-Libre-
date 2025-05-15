import 'package:cine_libre/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    // Verificar si ya hay un usuario autenticado
    _checkCurrentUser();
  }

  // Método para verificar si hay un usuario ya autenticado
  Future<void> _checkCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Si hay un usuario autenticado, ir directamente al HomePage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        }
      });
    }
  }

  // Método simplificado para manejar el registro
  Future<void> _handleRegister() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isRegistering = true;
    });
    
    final email = _emailCtrl.text.trim();
    final password = _passCtrl.text.trim();
    
    try {
      // Crear usuario
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Verificar que tenemos un usuario válido
      if (credential.user != null) {
        final user = credential.user!;
        
        try {
          // Guardar datos adicionales en Firestore
          await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
            'nombre': _nameCtrl.text.trim(),
            'email': email,
            'usuario': _userCtrl.text.trim(),
            'creado': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          debugPrint('Error al guardar datos en Firestore: $e');
          // Continuamos aunque falle Firestore
        }
        
        if (!mounted) return;
        
        setState(() {
          _isRegistering = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Usuario registrado con éxito!')),
        );
        
        // Navegar al HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        throw Exception('No se pudo completar el registro');
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isRegistering = false;
      });
      
      String message = 'Error al registrar usuario';
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            message = 'El correo ya está en uso';
            break;
          case 'weak-password':
            message = 'La contraseña es muy débil';
            break;
          case 'invalid-email':
            message = 'Formato de correo no válido';
            break;
          default:
            message = 'Error de registro: ${e.code}';
        }
      } else {
        // Para otros tipos de errores, captura el mensaje completo
        message = 'Error de registro: ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      
      debugPrint('Error de registro: $e');
    }
  }
}
  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.person_add,
                      size: 80, color: Colors.redAccent),
                  const SizedBox(height: 20),
                  const Text("Registro",
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa tu nombre' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un correo';
                      }
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Correo no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _userCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Usuario',
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa un usuario' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
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
                    validator: (value) =>
                        value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value != _passCtrl.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isRegistering
                      ? const CircularProgressIndicator(color: Colors.redAccent)
                      : ElevatedButton(
                          onPressed: _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text("Registrarse"),
                        ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text("¿Ya tienes cuenta? Inicia sesión",
                        style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}