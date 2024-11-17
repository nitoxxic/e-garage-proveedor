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
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: icon,
        border: OutlineInputBorder(),
      ),
    );
  }
}

