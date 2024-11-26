import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PasswordResetPage extends StatefulWidget {
  static const String name = 'PasswordResetPage';

  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _emailController = TextEditingController();

  /// Función para enviar un correo de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print("Correo de recuperación enviado");
    } catch (e) {
      print("Error: $e");
      throw e;
    }
  }

  /// Valida si el correo tiene un formato válido
  bool isValidEmail(String email) {
    return RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$",
    ).hasMatch(email);
  }

  /// Método para manejar el restablecimiento de contraseña
  void _resetPassword() async {
    String email = _emailController.text.trim();
    FocusScope.of(context).unfocus(); // Oculta el teclado

    if (email.isNotEmpty && isValidEmail(email)) {
      try {
        // Mostrar indicador de carga
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(child: CircularProgressIndicator()),
        );

        await sendPasswordResetEmail(email);

        // Cerrar indicador de carga
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Correo de recuperación enviado a $email')),
        );
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context); // Cierra el indicador de carga
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage =
              'No se encontró un usuario con ese correo electrónico.';
        } else {
          errorMessage = 'Ocurrió un error. Inténtalo nuevamente.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        Navigator.pop(context); // Cierra el indicador de carga
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, ingresa un correo válido')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Restablecer contraseña",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
            const SizedBox(height: 40),
            TextField(
              style: const TextStyle(color: Colors.white),
              controller: _emailController,
              decoration: InputDecoration(
                labelStyle: TextStyle(color: Colors.white),
                labelText: "Correo electrónico",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _resetPassword,
              child: const Text("Enviar correo de recuperación"),
            ),
          ],
        ),
      ),
      floatingActionButton: BackButtonWidget(
        onPressed: () {
          context.push('SelectionScreen');
        },
      ),
    );
  }
}
