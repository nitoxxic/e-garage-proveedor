import 'package:cloud_firestore/cloud_firestore.dart';

class Garage {
  String id;
  String nombre;
  String direccion;
  int lugaresTotales;
  int lugaresDisponibles;
  double latitude;
  double longitude;
  String imageUrl; // Nueva propiedad para la URL de la imagen

  Garage({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.lugaresTotales,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
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
      "imageUrl": imageUrl, // Incluir la imagen si está presente
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
      imageUrl: data?['imageUrl'] ?? 'imagen no disponible', // Asignar la URL de la imagen si existe
    )..lugaresDisponibles = data?['lugaresDisponibles'] ?? data?['lugaresTotales'];
  }

  // Método para copiar la instancia
  Garage copyWith({
    String? id,
    String? nombre,
    String? direccion,
    int? lugaresTotales,
    int? lugaresDisponibles,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) {
    return Garage(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      lugaresTotales: lugaresTotales ?? this.lugaresTotales,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
    )..lugaresDisponibles = lugaresDisponibles ?? this.lugaresDisponibles;
  }

  String get garageId => id;
}