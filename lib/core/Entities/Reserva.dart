import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Vehiculo.dart';


class Reserva {
  String id;
  DateTime startTime;
  DateTime endTime;
  Vehiculo elvehiculo;
  String garajeId;
  String usuarioId;

  Reserva(
      {required this.id,
      required this.startTime,
      required this.endTime,
      required this.elvehiculo,
      required this.usuarioId,
      required this.garajeId});

  factory Reserva.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Reserva(
        id: data['id'],
        startTime: (data['fechaHoraInicio'] as Timestamp).toDate(),
        endTime: (data['fechaHoraFin'] as Timestamp).toDate(),
        elvehiculo:
            Vehiculo.fromMap(data['elvehiculo']), // Usar el nuevo método
        usuarioId: data['idUsuario'],
        garajeId: data['garajeId']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'fechaHoraInicio': startTime,
      'fechaHoraFin': endTime,
      'elvehiculo': {
        'modelo': elvehiculo.modelo,
        'marca': elvehiculo.marca,
        'patente': elvehiculo.patente,
        'idDuenio': elvehiculo.userId,
      },
      'idUsuario': usuarioId,
      'garajeId': garajeId
    };
  }

  Reserva copywith(
      {String? id,
      DateTime? startTime,
      DateTime? endTime,
      Vehiculo? elvehiculo,
      String? garajeId,
      String? usuarioId}) {
    return Reserva(
        id: id ?? this.id,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        elvehiculo: elvehiculo ?? this.elvehiculo,
        usuarioId: usuarioId ?? this.usuarioId,
        garajeId: garajeId ?? this.garajeId);
  }
}
