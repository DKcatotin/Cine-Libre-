import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = AuthService();
  final _googleSignIn = GoogleSignIn();
  bool _isLoading = false;
  
  // Obtener tipo de proveedor (email o Google)
  String get _authProvider {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Desconocido';
    
    // Verificar si el usuario inició sesión con Google
    if (user.providerData.any((info) => info.providerId == 'google.com')) {
      return 'Google';
    }
    
    return 'Email y contraseña';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      // Redireccionar a la página de login si no hay usuario
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return const Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: Colors.redAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar y nombre de usuario
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade800,
              backgroundImage: user.photoURL != null 
                ? NetworkImage(user.photoURL!) 
                : null,
              child: user.photoURL == null
                ? Icon(Icons.person, size: 50, color: Colors.grey.shade200)
                : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? 'Usuario',
              style: const TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold
              ),
            ),
            Text(
              user.email ?? 'No email',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text('Inicio de sesión con $_authProvider'),
              backgroundColor: _authProvider == 'Google' 
                ? Colors.blue.shade900 
                : Colors.green.shade900,
              labelStyle: const TextStyle(color: Colors.white),
            ),
            
            const SizedBox(height: 32),
            const Divider(),
            
            // Sección de opciones de cuenta
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Información de la cuenta'),
              subtitle: const Text('Ver detalles de tu cuenta'),
              onTap: () {
                // Mostrar un diálogo con información detallada
                _showAccountInfo(context, user);
              },
            ),
            
            // Añadir opción de cambiar contraseña para usuarios que no son de Google
            if (_authProvider != 'Google')
              ListTile(
                leading: const Icon(Icons.lock, color: Colors.amber),
                title: const Text('Cambiar contraseña'),
                subtitle: const Text('Restablecer por correo electrónico'),
                onTap: () {
                  _sendPasswordResetEmail();
                },
              ),
            
            if (_authProvider == 'Google')
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Cambiar cuenta de Google'),
                onTap: _handleGoogleAccountSwitch,
              ),
            
            const Divider(),
            
            // Botón de cerrar sesión
            _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _handleLogout,
                ),
          ],
        ),
      ),
    );
  }
  
  // Método para mostrar información detallada de la cuenta
  void _showAccountInfo(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de la cuenta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('ID:', user.uid),
            _infoRow('Email:', user.email ?? 'No disponible'),
            _infoRow('Nombre:', user.displayName ?? 'No disponible'),
            _infoRow('Proveedor:', _authProvider),
            _infoRow('Email verificado:', user.emailVerified ? 'Sí' : 'No'),
            _infoRow('Teléfono:', user.phoneNumber ?? 'No disponible'),
            _infoRow('Creado:', user.metadata.creationTime?.toString() ?? 'Desconocido'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  // Método para mostrar un elemento de información
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
  
  // Método para enviar correo de restablecimiento
  Future<void> _sendPasswordResetEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user != null && user.email != null) {
      try {
        setState(() {
          _isLoading = true;
        });
        
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
        
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Se ha enviado un enlace de restablecimiento a ${user.email}'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar correo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay un correo asociado a esta cuenta'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Método para cambiar de cuenta de Google usando la implementación de AuthService
  void _handleGoogleAccountSwitch() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Usamos el método específico de AuthService para cambiar cuenta
      final result = await _authService.switchGoogleAccount();
      
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cuenta cambiada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage ?? 'Error al cambiar de cuenta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Método para cerrar sesión con cierre completo de Google
  void _handleLogout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 1. Primero cerrar sesión con Google explícitamente
      await _googleSignIn.signOut();
      
      // 2. Luego cerrar sesión en Firebase
      await _authService.logout();
      
      if (!mounted) return;
      
      // 3. Navegar a la página de login con limpieza de historial
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}