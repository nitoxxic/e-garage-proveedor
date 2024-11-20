import 'package:flutter/material.dart';

class InputTextLogin extends StatelessWidget {
  final String hintText;
  final Icon icon;
  final TextEditingController controller;

  const InputTextLogin({
    Key? key,
    required this.hintText,
    required this.icon,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white), // Texto ingresado en blanco
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey), // Hint en gris
        prefixIcon: icon,
        filled: true,
        fillColor: Colors.black, // Fondo del campo de texto
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.grey), // Borde habilitado en gris
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white), // Borde enfocado en blanco
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}