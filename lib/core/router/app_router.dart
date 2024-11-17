import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:go_router/go_router.dart';
import 'package:e_garage_proveedor/screens/EditarDatosAdmin.dart';
import 'package:e_garage_proveedor/screens/EditarGarage.dart';
import 'package:e_garage_proveedor/screens/ListaGarages.dart';
import 'package:e_garage_proveedor/screens/LoginAdministrador.dart';
import 'package:e_garage_proveedor/screens/PantallaLogin.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
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
    
  ],
);
