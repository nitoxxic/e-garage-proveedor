import 'package:e_garage_proveedor/Test/IngresarVehiculo_Test.dart';
import 'package:e_garage_proveedor/Test/EgresarVehiculo_Test.dart';
import 'package:e_garage_proveedor/Test/RegistrarPagoEfectivo.dart';
import 'package:e_garage_proveedor/core/Providers/user_provider.dart';
import 'package:e_garage_proveedor/screens/ingresos.dart';
import 'package:e_garage_proveedor/screens/pantallaReservas.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/lugaresDisponibles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuAdministrador extends ConsumerWidget {
  const MenuAdministrador({super.key});

  Future<void> _logOut(BuildContext context, WidgetRef ref) async {
    ref.read(usuarioProvider.notifier).clearUsuario();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    context.push('/selectionScreen');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userActivo = ref.watch(usuarioProvider);
    return Drawer(
      child: Container(
        color: Colors.grey[200],
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.white),
              child: Text(
                  'Menú \n'
                  '\n'
                  '¡Hola ${userActivo.nombre}!',
                  style: TextStyle(fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.person, size: 40, color: Colors.black),
              title: const Text('Editar Datos', style: TextStyle(fontSize: 18)),
              onTap: () {
                context.push('/editar-datos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today,
                  size: 40, color: Colors.black),
              title: const Text('Reservas', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PantallaReservas()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.check_box, size: 40, color: Colors.black),
              title: const Text('Lugares Disponibles',
                  style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LugaresDisponibles()),
                );
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.attach_money, size: 40, color: Colors.black),
              title: const Text('Ingresos', style: TextStyle(fontSize: 18)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Ingresos()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.wallet, size: 40, color: Colors.black),
              title:
                  const Text('Registrar pago', style: TextStyle(fontSize: 18)),
              onTap: () {
                context.goNamed(Registrarpagoefectivo.name);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.car_rental, size: 40, color: Colors.black),
              title: const Text('Ingresar Vehiculo',
                  style: TextStyle(fontSize: 18)),
              onTap: () {
                context.goNamed(Ingresarvehiculo.name);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.car_repair, size: 40, color: Colors.black),
              title: const Text('Egresar Vehiculo',
                  style: TextStyle(fontSize: 18)),
              onTap: () {
                context.goNamed(Retirarvehiculo.name);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.exit_to_app, size: 40, color: Colors.black),
              title: const Text('Salir', style: TextStyle(fontSize: 18)),
              onTap: () {
                // Confirmación antes de cerrar sesión
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('¿Quieres salir?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Sí'),
                          onPressed: () {
                            Navigator.pop(context); // Cierra el diálogo
                            _logOut(context,
                                ref); // Cierra sesión y navega al login
                          },
                        ),
                        TextButton(
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.pop(context); // Cierra el diálogo
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
