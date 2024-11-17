import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/core/Entities/Usuario.dart';

class DuenoGarage extends Usuario {
  List<Garage> garages;
  String razonSocial;
  String CUIT;

  DuenoGarage({
    required super.id,
    required super.email,
    required super.password,
    required super.nombre,
    required super.apellido,
    required super.dni,
    required super.telefono,
    required this.garages,
    required this.razonSocial,
    required this.CUIT,
    bool biometriaHabilitada = false,
  }) : super(
          esAdmin: true,
          biometriaHabilitada: biometriaHabilitada,
        );
}
