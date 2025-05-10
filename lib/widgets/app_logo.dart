import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 1,
      backgroundImage: const AssetImage('assets/images/logoCine.jpeg'),
      backgroundColor: const Color.fromARGB(0, 64, 130, 252), // o usa un color si quieres fondo
    );
  }
}
