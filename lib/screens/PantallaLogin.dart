import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Providers/user_provider.dart';
import 'package:e_garage_proveedor/services/bloc/notifications_bloc.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});
  String _email = '';
  String _clave = '';
  final db = FirebaseFirestore.instance;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    context.read<NotificationsBloc>().requestPermission();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const LogoWidget(size: 300, showText: false),
              const SizedBox(height: 20),
              const SizedBox(height: 50),
              _buildTextField('Usuario', (value) => _email = value),
              const SizedBox(height: 20),
              _buildTextField('Password', (value) => _clave = value,
                  obscureText: true),
              const SizedBox(height: 50),
              GestureDetector(
                child: const Text(
                  'Olvide la contraseña',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  context.goNamed('PasswordResetPage');
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  context.push('/selectionScreen');
                },
              ),
            ),
            IconButton(
              icon:
                  const Icon(Icons.fingerprint, color: Colors.white, size: 40),
              onPressed: () async {
                await _authenticateDuenoGarage(context, ref);
              },
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.black),
                onPressed: () {
                  validarCredenciales(context, ref);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, ValueChanged<String> onChanged,
      {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
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

  validarCredenciales(BuildContext context, WidgetRef ref) async {
    _email = _email.trim();
    _clave = _clave.trim();

    if (_email.isEmpty || _clave.isEmpty) {
      _showErrorSnackbar(context, 'Por favor, complete todos los campos.');
      return;
    }

    if (!_esCorreoValido(_email)) {
      _showErrorSnackbar(
          context, 'El correo electrónico no tiene un formato válido.');
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email, password: _clave);

      User? user = userCredential.user;

      if (user != null) {
        QuerySnapshot querySnapshot = await db
            .collection("duenos")
            .where("email", isEqualTo: _email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          QueryDocumentSnapshot userDocument = querySnapshot.docs.first;
          Map<String, dynamic> userData =
              userDocument.data() as Map<String, dynamic>;
          ref.read(usuarioProvider.notifier).setUsuario(
                userData['id'],
                userData['nombre'],
                userData['apellido'],
                userData['email'],
                userData['password'],
                userData['dni'],
                userData['telefono'],
                userData['token'],
                userData['esAdmin'],
              );
          context.push('/home-admin');
        } else {
          _showErrorSnackbar(
              context, 'Usuario no encontrado en la base de datos.');
        }
      }
    } on FirebaseAuthException catch (e) {
      // Manejamos las excepciones específicas
      print("Error: ${e.code}");

      if (e.code == 'invalid-credential') {
        // Error de credenciales mal formadas o incorrectas
        _showErrorSnackbar(context, 'Usuario o contraseña incorrecto');
      } else {
        switch (e.code) {
          case 'user-not-found':
            _showErrorSnackbar(context, 'Usuario no encontrado.');
            break;
          case 'wrong-password':
            _showErrorSnackbar(context, 'Contraseña incorrecta.');
            break;
          case 'invalid-email':
            _showErrorSnackbar(
                context, 'El correo electrónico tiene un formato incorrecto.');
            break;
          default:
            _showErrorSnackbar(context, 'Error: ${e.message}');
        }
      }
    } catch (e) {
      // En caso de un error inesperado
      _showErrorSnackbar(context, 'Error inesperado: $e');
    }
  }

  // Método para validar el formato del correo electrónico
  bool _esCorreoValido(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  Future<void> _authenticateDuenoGarage(
      BuildContext context, WidgetRef ref) async {
    final FlutterSecureStorage storage = FlutterSecureStorage();
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: 'Autentícate para acceder',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Recuperar las credenciales almacenadas
        String? email = await storage.read(key: 'email');
        String? password = await storage.read(key: 'password');

        if (email != null && password != null) {
          // Validar usuario con las credenciales recuperadas en la colección `duenos`
          QuerySnapshot querySnapshot = await db
              .collection("duenos")
              .where("email", isEqualTo: email)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            Map<String, dynamic> duenoData =
                querySnapshot.docs.first.data() as Map<String, dynamic>;

            if (duenoData['email'] == email &&
                duenoData['password'] == password) {
              ref.read(usuarioProvider.notifier).setUsuario(
                    duenoData['id'],
                    duenoData['nombre'],
                    duenoData['apellido'],
                    duenoData['email'],
                    duenoData['password'],
                    duenoData['dni'],
                    duenoData['telefono'],
                    duenoData['token'],
                    duenoData['esAdmin'],
                  );

              if (duenoData['email'] == email &&
                  duenoData['password'] == password) {
                context.go('/home-admin');
              }
            } else {
              _showErrorSnackbar(context, 'Error de autenticación.');
            }
          } else {
            _showErrorSnackbar(context, 'Usuario no encontrado.');
          }
        } else {
          _showErrorSnackbar(
            context,
            'No se encontraron credenciales almacenadas.',
          );
        }
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Error de autenticación biométrica: $e');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
