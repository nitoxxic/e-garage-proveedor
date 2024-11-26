import 'package:cloud_firestore/cloud_firestore.dart';

class Comentarioreserva {
  String? id;
  String? idReserva;
  String? idGarage;
  String? idUsuario;
  String? comentario;
  double? puntuacion;

  Comentarioreserva({
    required this.id,
    required this.idGarage,
    required this.idReserva,
    required this.idUsuario,
    required this.comentario,
    required this.puntuacion,
  });

  // Método para convertir la clase a un Map<String, dynamic> para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) "id": id,
      if (idGarage != null) "idGarage": idGarage,
      if (idReserva != null) "idReserva": idReserva,
      if (idUsuario != null) "idUsuario": idUsuario,
      if (comentario != null) "comentario": comentario,
      if (puntuacion != null) "puntuacion": puntuacion,
    };
  }

  // Constructor para crear una instancia desde los datos de Firestore
  factory Comentarioreserva.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Comentarioreserva(
      id: data['id'] ?? '', // El id del documento de Firestore
      idGarage: data['idGarage'] ?? '',
      idReserva: data['idReserva'] ?? '',
      idUsuario: data['idUsuario'] ?? '',
      comentario: data['comentario'] ?? '',
      puntuacion: (data['puntuacion'] ?? 0).toDouble(),
    );
  }

  Comentarioreserva copywith(
      {String? id,
      String? idGarage,
      String? idReserva,
      String? idUsuario,
      String? comentario,
      double? puntuacion}) {
    return Comentarioreserva(
        id: id ?? this.id,
        idGarage: idGarage ?? this.idGarage,
        idReserva: idReserva ?? this.idReserva,
        idUsuario: idUsuario ?? this.idUsuario,
        comentario: comentario ?? this.comentario,
        puntuacion: puntuacion ?? this.puntuacion);
  }

  double get traerElPuntaje => puntuacion!;
}
