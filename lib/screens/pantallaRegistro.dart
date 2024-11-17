import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/DuenoGarage.dart';
import 'package:e_garage_proveedor/screens/selectionScreen.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistroDuenoGarageScreen extends StatefulWidget {
  const RegistroDuenoGarageScreen({super.key});

  @override
  _RegistroDuenoGarageScreen createState() => _RegistroDuenoGarageScreen();
}

class _RegistroDuenoGarageScreen extends State<RegistroDuenoGarageScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _razonSocialController = TextEditingController();
  final TextEditingController _cuitController = TextEditingController();
  bool _isPasswordValid = false;

  bool _validatePassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasMinLength = password.length >= 8;
    return hasUppercase && hasLowercase && hasDigit && hasMinLength;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/car_logo.png',
                height: 200,
              ),
              const SizedBox(height: 30),
              _buildTextField('Nombre', _nombreController),
              const SizedBox(height: 20),
              _buildTextField('Apellido', _apellidoController),
              const SizedBox(height: 20),
              _buildTextField('Número DNI', _dniController),
              const SizedBox(height: 20),
              _buildTextField('Teléfono', _telefonoController),
              const SizedBox(height: 20),
              _buildTextField('Correo Electrónico', _emailController, TextInputType.emailAddress),
              const SizedBox(height: 20),
              _buildPasswordField('Contraseña', _passwordController, (value) {
                setState(() {
                  _isPasswordValid = _validatePassword(value);
                });
              }),
              const SizedBox(height: 10),
              Text(
                'La contraseña debe contener como mínimo 8 caracteres, letras mayúsculas y minúsculas, 1 número.',
                style: TextStyle(
                  color: _isPasswordValid ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              _buildPasswordField('Reingrese Contraseña', _confirmPasswordController, null),
              const SizedBox(height: 20),
              _buildTextField('Razón Social', _razonSocialController),
              const SizedBox(height: 20),
              _buildTextField('CUIT', _cuitController, TextInputType.number),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const BackButtonWidget(),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.black),
                onPressed: () async {
                  if (_isPasswordValid) {
                    bool isSaved = await _guardarUsuario();
                    if (isSaved) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SelectionScreen()),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('La contraseña no cumple con los requisitos mínimos.'),
                    ));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      [TextInputType inputType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      String labelText, TextEditingController controller, ValueChanged<String>? onChanged) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Future<bool> _guardarUsuario() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Las contraseñas no coinciden'),
      ));
      return false;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        DuenoGarage nuevoDueno = DuenoGarage(
          id: user.uid,
          email: _emailController.text,
          password: _passwordController.text,
          nombre: _nombreController.text,
          apellido: _apellidoController.text,
          dni: _dniController.text,
          telefono: _telefonoController.text,
          razonSocial: _razonSocialController.text,
          CUIT: _cuitController.text,
          garages: [],
          biometriaHabilitada: false,
        );

        await FirebaseFirestore.instance
            .collection('duenos')
            .doc(user.uid)
            .set(nuevoDueno.toFirestore());

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Usuario guardado correctamente'),
        ));
        return true;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = 'El correo electrónico ya está en uso por otra cuenta.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es demasiado débil.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El correo electrónico es inválido.';
      } else {
        errorMessage = 'Error al registrar el usuario: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario: $e')),
      );
    }
    return false;
  }
}