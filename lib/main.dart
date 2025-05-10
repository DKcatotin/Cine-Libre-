import 'package:flutter/material.dart';
import 'pages/login_page.dart'; // Asegúrate de importar esto

void main() {
  runApp(const CineLibreApp());
}

class CineLibreApp extends StatelessWidget {
  const CineLibreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineLibre',
      theme: ThemeData.dark(),
      home: const LoginPage(), // Ahora arranca en el login
    );
  }
}
