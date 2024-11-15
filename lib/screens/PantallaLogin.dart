import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Providers/user_provider.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({super.key});

  String _email = '';
  String _clave = '';
  final db = FirebaseFirestore.instance;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _verificarBiometria(context, ref);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
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
            _buildTextField('Password', (value) => _clave = value, obscureText: true),
            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BackButtonWidget(
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.fingerprint, color: Colors.white, size: 40),
              onPressed: () async {
                bool isBiometricSupported = await auth.isDeviceSupported();
                if (isBiometricSupported) {
                  await _authenticate(context, ref);
                } else {
                  _showErrorSnackbar(context, 'El dispositivo no admite autenticación biométrica.');
                }
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

  Future<void> _verificarBiometria(BuildContext context, WidgetRef ref) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('authToken');

      if (email != null) {
        QuerySnapshot querySnapshot = await db.collection("users").where("email", isEqualTo: email).get();

        if (querySnapshot.docs.isNotEmpty) {
          Map<String, dynamic>? userData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
          bool biometriaHabilitada = userData?['biometriaHabilitada'] ?? false;

          if (biometriaHabilitada) {
            await _authenticate(context, ref);
          }
        }
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Error al verificar biometría: $e');
    }
  }

  Widget _buildTextField(String label, ValueChanged<String> onChanged, {bool obscureText = false}) {
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

  Future<void> validarCredenciales(BuildContext context, WidgetRef ref) async {
    try {
      QuerySnapshot querySnapshot = await db.collection("users").where("email", isEqualTo: _email).get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic>? userData = querySnapshot.docs.first.data() as Map<String, dynamic>?;
        bool biometriaHabilitada = userData?['biometriaHabilitada'] ?? false;

        if (biometriaHabilitada) {
          await _authenticate(context, ref);
          return;
        }

        if (userData?['email'] == _email && userData?['password'] == _clave) {
          ref.read(usuarioProvider.notifier).setUsuario(
            userData?['id'],
            userData?['nombre'],
            userData?['apellido'],
            userData?['email'],
            userData?['password'],
            userData?['dni'],
            userData?['telefono'],
            userData?['esAdmin'],
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', userData?['email']);
          context.push('/home-admin');
        } else {
          _showErrorSnackbar(context, 'Contraseña incorrecta.');
        }
      } else {
        _showErrorSnackbar(context, 'Usuario no encontrado.');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Error: $e');
    }
  }

  Future<void> _authenticate(BuildContext context, WidgetRef ref) async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isBiometricSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isBiometricSupported) {
        _showErrorSnackbar(context, 'El dispositivo no admite autenticación biométrica.');
        return;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Autentícate para acceder',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        validarCredenciales(context, ref);
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
