import 'package:e_garage_proveedor/core/Entities/Usuario.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final usuarioProvider = StateNotifierProvider<UsuarioNotifier, Usuario>((ref) {
  return UsuarioNotifier();
});

class UsuarioNotifier extends StateNotifier<Usuario> {
  UsuarioNotifier()
      : super(Usuario(
          id: '',
          email: '',
          password: '',
          nombre: '',
          apellido: '',
          dni: '',
          telefono: '',
          token: '',
          esAdmin: false,
          biometriaHabilitada: false,
        ));

  // Método para establecer los datos del usuario
  void setUsuario(String id, String nombre, String apellido, String email,
      String password, String dni, String telefono, String token, bool esAdmin,
      {bool biometriaHabilitada = false}) {
    state = state.copywith(
      id: id,
      nombre: nombre,
      apellido: apellido,
      password: password,
      email: email,
      dni: dni,
      telefono: telefono,
      token: token,
      esAdmin: esAdmin,
      biometriaHabilitada: biometriaHabilitada,
    );
  }

  // Método para limpiar los datos del usuario (cierre de sesión)
  void clearUsuario() {
    state = Usuario(
      id: '',
      email: '',
      password: '',
      nombre: '',
      apellido: '',
      dni: '',
      telefono: '',
      token: '',
      esAdmin: false,
      biometriaHabilitada: false,
    );
  }

  // Método para actualizar la preferencia de biometría
  void setBiometriaHabilitada(bool habilitada) {
    state = state.copywith(biometriaHabilitada: habilitada);
  }
}
