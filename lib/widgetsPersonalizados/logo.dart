import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  final double size; // Permite ajustar el tamaño del logo
  final bool showText; // Permite mostrar o no el texto debajo del logo

  const LogoWidget({
    Key? key,
    this.size = 150,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo_proveedor.png',
          height: size,
          width: size,
        ),
        if (showText) const SizedBox(height: 10),
        if (showText)
          const Text(
            'E-Garage',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
      ],
    );
  }
}
