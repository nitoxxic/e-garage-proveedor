import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Providers/user_provider.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/MenuAdministrador.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

class EditarDatosAdmin extends ConsumerWidget {
  const EditarDatosAdmin({super.key});

  Future<void> _eliminarCuenta(BuildContext context, WidgetRef ref) async {
    final usuario = ref.read(usuarioProvider);
    final db = FirebaseFirestore.instance;

    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Quieres eliminar tu cuenta?'),
          content: const Text('Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Sí'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        );
      },
    );

    if (confirmacion == true) {
      try {
        await db.collection('users').doc(usuario.id).delete();
        ref.read(usuarioProvider.notifier).clearUsuario();
        context.go('/selection');
      } catch (e) {
        _showErrorSnackbar(context, 'Error al eliminar cuenta: $e');
      }
    }
  }

  Future<void> _habilitarBiometria(BuildContext context, WidgetRef ref) async {
    final usuario = ref.read(usuarioProvider);
    final db = FirebaseFirestore.instance;
    final LocalAuthentication auth = LocalAuthentication();

    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isBiometricSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isBiometricSupported) {
        _showErrorSnackbar(context, 'El dispositivo no admite autenticación biométrica.');
        return;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Autentícate para habilitar el desbloqueo biométrico',
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        await db.collection('users').doc(usuario.id).update({
          'biometriaHabilitada': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Desbloqueo biométrico habilitado.')),
        );
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Error al habilitar la biometría: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioProvider);

    final nombreController = TextEditingController(text: usuario.nombre);
    final apellidoController = TextEditingController(text: usuario.apellido);
    final emailController = TextEditingController(text: usuario.email);
    final passwordController = TextEditingController(text: usuario.password);
    final confirmPasswordController = TextEditingController();

    bool isPasswordValid = false;

    bool validatePassword(String password) {
      final hasUppercase = password.contains(RegExp(r'[A-Z]'));
      final hasLowercase = password.contains(RegExp(r'[a-z]'));
      final hasDigit = password.contains(RegExp(r'\d'));
      final hasMinLength = password.length >= 8;
      return hasUppercase && hasLowercase && hasDigit && hasMinLength;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      drawer: const MenuAdministrador(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const LogoWidget(size: 300, showText: false),
                  const SizedBox(height: 20),
                  const Text(
                    'EDITAR DATOS',
                    style: TextStyle(fontSize: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  _buildEditableField('Nombre Completo', nombreController),
                  const SizedBox(height: 20),
                  _buildEditableField('Apellido', apellidoController),
                  const SizedBox(height: 20),
                  _buildEditableField('Correo Electrónico', emailController),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    'Contraseña',
                    passwordController,
                    (value) => isPasswordValid = validatePassword(value),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'La contraseña debe tener al menos 8 caracteres, incluyendo letras mayúsculas, minúsculas y números.',
                    style: TextStyle(
                      color: isPasswordValid ? Colors.green : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField('Confirmar Contraseña', confirmPasswordController, null),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      if (isPasswordValid && passwordController.text == confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Datos guardados exitosamente.')),
                        );
                      } else {
                        _showErrorSnackbar(context, 'Verifique la contraseña y su confirmación.');
                      }
                    },
                    child: const Text("Guardar Cambios"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _eliminarCuenta(context, ref),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Eliminar cuenta"),
                  ),
                  ElevatedButton(
                    onPressed: () => _habilitarBiometria(context, ref),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 250, 252, 253)),
                    child: const Text("Habilitar desbloqueo biométrico"),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: BackButtonWidget(
              onPressed: () {
                context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
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
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, ValueChanged<String>? onChanged) {
    return TextField(
      controller: controller,
      obscureText: true,
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

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
