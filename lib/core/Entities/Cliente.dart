import 'package:e_garage_proveedor/core/Entities/Usuario.dart';


class Cliente extends Usuario {
  Cliente({
    required super.id,
    required super.email,
    required super.password,
    required super.nombre,
    required super.apellido,
    required super.dni,
    required super.telefono,
    bool biometriaHabilitada = false,
    
  }):super( biometriaHabilitada: biometriaHabilitada);
}