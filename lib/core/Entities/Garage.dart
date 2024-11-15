import 'package:cloud_firestore/cloud_firestore.dart';

class Garage {
  String id;
  String nombre;
  String direccion;
  int lugaresTotales;
  int lugaresDisponibles;

  Garage({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.lugaresTotales,
  }) : lugaresDisponibles = lugaresTotales; // Inicialmente todos los lugares están disponibles.

  
  Map<String, dynamic> toFirestore() {
    return {
      "id": id,
      "nombre": nombre,
      "direccion": direccion,
      "lugaresTotales": lugaresTotales,
      "lugaresDisponibles": lugaresDisponibles,
    };
  }

  
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
    )..lugaresDisponibles = data?['lugaresDisponibles'] ?? data?['lugaresTotales'];
  }

  
  Garage copyWith({
    String? id,
    String? nombre,
    String? direccion,
    int? lugaresTotales,
    int? lugaresDisponibles,
  }) {
    return Garage(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      lugaresTotales: lugaresTotales ?? this.lugaresTotales,
    )..lugaresDisponibles = lugaresDisponibles ?? this.lugaresDisponibles;
  }

  String get garageId => id;
}
