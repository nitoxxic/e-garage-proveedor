import 'package:cloud_firestore/cloud_firestore.dart';

class usuarioVehiculo {
  String? idUsuario;
  String? idVehiculo;

  usuarioVehiculo({required this.idUsuario, required this.idVehiculo});

  Map<String, dynamic> toFirestore() {
    return {
      if (idUsuario != null) "idUsuario": idUsuario,
      if (idVehiculo != null) "idVehiculo": idVehiculo,
    };
  }

  factory usuarioVehiculo.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return usuarioVehiculo(
      idUsuario: data?['idUsuario'],
      idVehiculo: data?['idVehiculo'],
    );
  }
}
