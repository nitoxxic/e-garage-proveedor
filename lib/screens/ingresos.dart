import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/ingresosGarage.dart';
import 'package:flutter/material.dart';

class Ingresos extends StatefulWidget {
  const Ingresos({super.key});

  @override
  _IngresosState createState() => _IngresosState();
}

class _IngresosState extends State<Ingresos> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Método para obtener los garages
 Stream<List<Garage>> _getGarages() {
  return _db.collection('garages').snapshots().map((querySnapshot) {
    return querySnapshot.docs.map((doc) {
      var data = doc.data();
      return Garage(
        id: doc.id,
        nombre: data['nombre'] ?? 'Garage sin nombre',
        direccion: data['direccion'] ?? 'Dirección desconocida',
        lugaresTotales: data['lugaresTotales'] ?? 0,
         latitude: data['latitude'] ?? 0.0,
         longitude: data['longitude'] ?? 0.0,
        imageUrl: data['imageUrl'] ?? 'imagen no disponible'
      );
    }).toList();
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Ingresos Mensuales',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: StreamBuilder<List<Garage>>(
        stream: _getGarages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No hay garajes disponibles.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          List<Garage> garages = snapshot.data!;

          return ListView.builder(
            itemCount: garages.length,
            itemBuilder: (context, index) {
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    garages[index].nombre,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IngresosGarage(garage: garages[index]),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}