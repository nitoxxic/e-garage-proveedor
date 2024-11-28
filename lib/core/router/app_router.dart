import 'package:e_garage_proveedor/Test/EgresarVehiculo_Test.dart';
import 'package:e_garage_proveedor/Test/IngresarVehiculo_Test.dart';
import 'package:e_garage_proveedor/Test/RegistrarPagoEfectivo.dart';
import 'package:e_garage_proveedor/Test/ingresarVehiculoAGarage.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/screens/comentariosGarage.dart';
import 'package:e_garage_proveedor/screens/recuperacionPassword.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/agregarGarage.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/detalleGarage.dart';
import 'package:go_router/go_router.dart';
import 'package:e_garage_proveedor/screens/EditarDatosAdmin.dart';
import 'package:e_garage_proveedor/screens/EditarGarage.dart';
import 'package:e_garage_proveedor/screens/ListaGarages.dart';
import 'package:e_garage_proveedor/screens/LoginAdministrador.dart';
import 'package:e_garage_proveedor/screens/PantallaLogin.dart';
import 'package:e_garage_proveedor/screens/SelectionScreen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/selectionScreen',
  routes: [
    GoRoute(
      path: '/selectionScreen',
      name: 'SelectionScreen',
      builder: (context, state) => const SelectionScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'LoginScreen',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/home-admin',
      name: 'AdminHomePage',
      builder: (context, state) => const AdminHomePage(),
    ),
    GoRoute(
      path: '/editar-datos',
      name: 'EditarDatosAdmin',
      builder: (context, state) => const EditarDatosAdmin(),
    ),
    GoRoute(
        path: '/Detalle-Garage',
        name: 'DetalleGarage',
        builder: (context, state) {
          final garage = state.extra as Garage;
          return DetalleGarage(garage: garage);
        }),
    GoRoute(
      path: '/lista-garages',
      name: 'ListaGarages',
      builder: (context, state) => const ListaGarages(),
    ),
    GoRoute(
      path: '/editar-garage',
      name: 'EditarGarage',
      builder: (context, state) {
        final garage = state.extra as Garage;
        return EditarGarage(garage: garage);
      },
    ),
    GoRoute(
        path: '/comentario-garage',
        name: 'ComentarioGarage',
        builder: (context, state) {
          final garage = state.extra as Garage;
          return ComentariosGarage(garage: garage);
        }),
    GoRoute(
        path: '/IngresarVehiculoAlGarage',
        name: 'IngresarVehiculoAlGarage',
        builder: (context, state) {
          final garage = state.extra as Garage;
          return IngresarvehiculoAlGarage(garage: garage);
        }),
    GoRoute(
      path: '/Ingresarvehiculo',
      builder: (context, state) => const Ingresarvehiculo(),
      name: Ingresarvehiculo.name,
    ),
    GoRoute(
      path: '/Retirarvehiculo',
      builder: (context, state) => const Retirarvehiculo(),
      name: Retirarvehiculo.name,
    ),
    GoRoute(
      path: '/Registrarpagoefectivo',
      builder: (context, state) => const Registrarpagoefectivo(),
      name: Registrarpagoefectivo.name,
    ),
    GoRoute(
      path: '/LoginAdministrador',
      builder: (context, state) => const AdminHomePage(),
      name: AdminHomePage.name,
    ),
    GoRoute(
      path: '/recuperarContrasenia',
      builder: (context, state) => PasswordResetPage(),
      name: 'PasswordResetPage',
    ),
    GoRoute(
      path: '/agregar-garage',
      builder: (context, state) => const AgregarGarage(),
      name: 'AgregarGarage',
    ),
  ],
);
