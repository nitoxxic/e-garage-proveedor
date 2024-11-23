import 'package:cloud_firestore/cloud_firestore.dart';

class Garage {
  String id;
  String nombre;
  String direccion;
  int lugaresTotales;
  int lugaresDisponibles;
  double latitude;
  double longitude;
  double valorHora;
  double valorFraccion;
  String idAdmin;

  Garage({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.lugaresTotales,
    required this.latitude,
    required this.longitude,
    required this.valorHora,
    required this.valorFraccion,
    required this.idAdmin,
  }) : lugaresDisponibles = lugaresTotales;

  // Método para convertir a Firestore
  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "nombre": nombre,
      "direccion": direccion,
      "lugaresTotales": lugaresTotales,
      "lugaresDisponibles": lugaresDisponibles,
      "latitude": latitude,
      "longitude": longitude,
      "valorHora": valorHora,
      "valorFraccion": valorFraccion,
      "idAdmin": idAdmin,
    };
  }

  // Método para crear una instancia desde Firestore
  factory Garage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Garage(
        id: data?['id'],
        nombre: data?['nombre'],
        direccion: data?['direccion'],
        lugaresTotales: data?['lugaresTotales'],
        latitude: data?['latitude'] ?? 0.0,
        longitude: data?['longitude'] ?? 0.0,
        valorHora: data?['valorHora'] ?? 0.0,
        valorFraccion: data?['valorFraccion'] ?? 0.0,
        idAdmin: data?['idAdmin'])
      ..lugaresDisponibles =
          data?['lugaresDisponibles'] ?? data?['lugaresTotales'];
  }

  // Método para copiar la instancia
  Garage copyWith(
      {String? id,
      String? nombre,
      String? direccion,
      int? lugaresTotales,
      int? lugaresDisponibles,
      double? valorHora,
      double? valorFraccion,
      double? latitude,
      double? longitude,
      String? idAdmin}) {
    return Garage(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      lugaresTotales: lugaresTotales ?? this.lugaresTotales,
      valorHora: valorHora ?? this.valorHora,
      valorFraccion: valorFraccion ?? this.valorFraccion,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      idAdmin: idAdmin ?? this.idAdmin,
    )..lugaresDisponibles = lugaresDisponibles ?? this.lugaresDisponibles;
  }

  String get garageId => id;
}
