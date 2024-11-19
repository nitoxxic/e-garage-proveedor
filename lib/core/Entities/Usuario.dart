import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  String id;
  String email;
  String password;
  String nombre;
  String apellido;
  String dni;
  String telefono;
  String? token;
  bool esAdmin;
  bool biometriaHabilitada;

  Usuario({
    required this.id,
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellido,
    required this.dni,
    required this.telefono,
    this.token,
    this.esAdmin = false,
    required this.biometriaHabilitada,
  });

  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "email": email,
      "password": password,
      "nombre": nombre,
      "apellido": apellido,
      "dni": dni,
      "telefono": telefono,
      "token": token,
      'esAdmin':
          esAdmin ?? false, // Asegúrate de asignar false si esAdmin es null
    };
  }

  factory Usuario.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Usuario(
        id: data?['id'],
        email: data?['email'],
        password: data?['password'],
        nombre: data?['nombre'],
        apellido: data?['apellido'],
        dni: data?['dni'],
        telefono: data?['telefono'],
        token: data?['token'],
        esAdmin: data?['esAdmin'] ?? false,
        biometriaHabilitada:
            data?['biometriaHabilitada']); // Si esAdmin es null, asigna false
  }

  Usuario copywith({
    String? id,
    String? email,
    String? password,
    String? nombre,
    String? apellido,
    String? dni,
    String? telefono,
    String? token,
    bool? esAdmin,
    bool? biometriaHabilitada,
  }) {
    return Usuario(
        id: id ?? this.id,
        email: email ?? this.email,
        password: password ?? this.password,
        nombre: nombre ?? this.nombre,
        apellido: apellido ?? this.apellido,
        dni: dni ?? this.dni,
        telefono: telefono ?? this.telefono,
        token: token ?? this.token,
        esAdmin: esAdmin ?? this.esAdmin ?? false,
        biometriaHabilitada: biometriaHabilitada ??
            this.biometriaHabilitada); // Usa false si esAdmin es null
  }
}
