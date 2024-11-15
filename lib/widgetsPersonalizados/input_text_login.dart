import 'package:flutter/material.dart';

class InputTextLogin extends StatelessWidget {
  final String hintText;
  final Icon icon;

  const InputTextLogin({
    super.key,
    required this.hintText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 2.0,
            color: Colors.grey,
          ),
        ),
        child: TextField(
          decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey[200]),
              icon: icon,
              iconColor: Colors.grey[500]),
        ));
  }
}
