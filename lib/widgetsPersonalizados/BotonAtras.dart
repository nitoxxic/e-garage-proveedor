import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;

  const BackButtonWidget({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onPressed ??
              () {
                Navigator.of(context).pop();
              },
        ),
      ),
    );
  }
}
