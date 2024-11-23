import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Providers/user_provider.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BiometriaService.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/MenuAdministrador.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EditarDatosAdmin extends ConsumerWidget {
  static final String name = "editarDatos";
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
        QuerySnapshot vehiculosSnapshot = await db
            .collection('Vehiculos')
            .where('userId', isEqualTo: usuario.id)
            .get();

        for (DocumentSnapshot vehiculoDoc in vehiculosSnapshot.docs) {
          await vehiculoDoc.reference.delete();
        }

        await db.collection('users').doc(usuario.id).delete();

        ref.read(usuarioProvider.notifier).clearUsuario();

        context.goNamed('SelectionScreen');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar cuenta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuario = ref.watch(usuarioProvider);
    final BiometriaService biometriaService = BiometriaService();

    final TextEditingController nombreController =
        TextEditingController(text: usuario.nombre);
    final TextEditingController apellidoController =
        TextEditingController(text: usuario.apellido);
    final TextEditingController emailController =
        TextEditingController(text: usuario.email);
    final TextEditingController passwordController =
        TextEditingController(text: usuario.password);
    final TextEditingController confirmPasswordController =
        TextEditingController();

    bool isPasswordValid = false;

    bool validatePassword(String password) {
      final hasUppercase = password.contains(RegExp(r'[A-Z]'));
      final hasLowercase = password.contains(RegExp(r'[a-z]'));
      final hasDigit = password.contains(RegExp(r'\d'));
      final hasMinLength = password.length >= 8;
      return hasUppercase && hasLowercase && hasDigit && hasMinLength;
    }

    bool validateEmail(String email) {
      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
      return emailRegex.hasMatch(email);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
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
                  _buildPasswordField(
                      'Confirmar Contraseña', confirmPasswordController, null),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      if (isPasswordValid &&
                          passwordController.text ==
                              confirmPasswordController.text) {
                        final db = FirebaseFirestore.instance;
                        final usuario = ref.read(usuarioProvider);
                        try {
                          await db.collection('duenos').doc(usuario.id).update({
                            'nombre': nombreController.text,
                            'apellido': apellidoController.text,
                            'email': emailController.text,
                            'password': passwordController.text,
                          });
                          ref.read(usuarioProvider.notifier).setUsuario(
                                usuario.id,
                                nombreController.text,
                                apellidoController.text,
                                emailController.text,
                                passwordController.text,
                                usuario.dni,
                                usuario.telefono,
                                usuario.token!,
                                usuario.esAdmin,
                              );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Datos guardados exitosamente.')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error al guardar cambios: $e')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                              'Verifique la contraseña y su confirmación.'),
                        ));
                      }
                    },
                    child: const Text("Guardar Cambios"),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      biometriaService.registrarHuellaDuenoGarage(
                        context,
                        usuario.id,
                        {
                          'email': emailController.text,
                          'password': passwordController.text,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      "Habilitar Huella Digital",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _eliminarCuenta(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(191, 152, 12, 2),
                    ),
                    child: const Text(
                      "Eliminar cuenta",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: BackButtonWidget(
              onPressed: () {
                context.push('/LoginAdministrador');
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

  Widget _buildPasswordField(String label, TextEditingController controller,
      ValueChanged<String>? onChanged) {
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
}