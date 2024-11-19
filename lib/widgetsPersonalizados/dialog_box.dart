import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BoxDialog extends StatelessWidget {
  final String message;
  final VoidCallback onCancel;

  // Constructor que recibe el mensaje a mostrar y la función de cancelación
  BoxDialog({
    super.key,
    required this.message,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[200],
      content: Column(
        mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del contenido
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Muestra el mensaje proporcionado
          Text(
            message,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20), // Espaciado entre texto y botones
          // Botón para cerrar el diálogo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MaterialButton(
                onPressed: onCancel,
                child: const Text('Ok'),
              ),
              MaterialButton(
                onPressed: onCancel,
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
