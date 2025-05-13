import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart'; // ✅ Asegúrate de importar correctamente

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
      initialRoute: '/login', // ✅ Ahora inicia en la pantalla de login
      routes: {
        '/login': (context) => const LoginPage(), // ✅ Define la ruta de login
        '/home': (context) => const HomePage(), // ✅ Define la ruta del Home
      },
    );
  }
}
