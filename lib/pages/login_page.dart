import 'package:cine_libre/pages/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import '../widgets/app_logo.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Añadimos la clave del formulario
  final _formKey = GlobalKey<FormState>();
  
  // Cambiamos _userCtrl por _emailCtrl para consistencia
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();
  
  // Renombramos _isLoading a _isLoggingIn para consistencia
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    // Verificar si ya hay un usuario autenticado
    _checkCurrentUser();
  }

  // Método para verificar si hay un usuario ya autenticado
  Future<void> _checkCurrentUser() async {
    if (_authService.isAuthenticated()) {
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

  // Método actualizado para manejar el inicio de sesión usando AuthService
  Future<void> _handleLogin() async {
    // Verificamos que el formulario exista antes de validarlo
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      setState(() {
        _isLoggingIn = true;
      });
      
      final email = _emailCtrl.text.trim();
      final password = _passCtrl.text.trim();
      
      try {
        final result = await _authService.login(email, password);
        
        if (!mounted) return;
        
        if (result.success) {
          // Éxito - navegar a la página principal
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          );
        } else {
          // Error con mensaje de authService
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.errorMessage ?? 'Error de inicio de sesión')),
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        String message = 'Error al iniciar sesión';
        
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              message = 'No se encontró usuario con ese correo';
              break;
            case 'wrong-password':
              message = 'Contraseña incorrecta';
              break;
            case 'invalid-email':
              message = 'Formato de correo no válido';
              break;
            default:
              message = 'Error de autenticación: ${e.code}';
          }
        } else {
          // Bypass especial para el error de PigeonUserDetails
          if (e.toString().contains('PigeonUserDetails')) {
            // Verificar si a pesar del error, el usuario está autenticado
            final user = FirebaseAuth.instance.currentUser;
            if (user != null && mounted) {
              // Si hay un usuario a pesar del error, continuar al HomePage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
              return;
            }
            message = 'Error de sesión. Por favor, intenta de nuevo.';
          } else {
            message = 'Error inesperado: ${e.toString()}';
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoggingIn = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
            // Añadimos el Form alrededor de nuestros widgets
            child: Form(
              key: _formKey,
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
                  // Cambiamos TextField a TextFormField para validación
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu correo';
                      }
                      if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                        return 'Ingresa un correo válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Cambiamos TextField a TextFormField para validación
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _isLoggingIn 
                    ? const CircularProgressIndicator(color: Colors.redAccent)
                    : ElevatedButton(
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
                  // Botón adicional para recuperar contraseña
                  TextButton(
                    onPressed: () {
                      _showResetPasswordDialog();
                    },
                    child: const Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Método para mostrar diálogo de recuperación de contraseña
  void _showResetPasswordDialog() {
    final resetEmailController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Recuperar contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading) const CircularProgressIndicator(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final email = resetEmailController.text.trim();
                          
                          if (email.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(email)) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ingresa un correo electrónico válido')),
                              );
                            }
                            return;
                          }
                          
                          setState(() {
                            isLoading = true;
                          });
                          
                          final result = await _authService.resetPassword(email);
                          
                          if (!mounted) return;
                          
                          setState(() {
                            isLoading = false;
                          });
                          
                          Navigator.pop(context);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result.success
                                    ? 'Se ha enviado un correo para restablecer tu contraseña'
                                    : result.errorMessage ?? 'Error al enviar correo de recuperación'
                              ),
                            ),
                          );
                        },
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}