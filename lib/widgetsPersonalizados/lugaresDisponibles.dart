import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/core/Providers/user_provider.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/MenuAdministrador.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/detalleGarage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LugaresDisponibles extends ConsumerWidget {
  const LugaresDisponibles({super.key});

  // Método para obtener los garages de Firestore
  Stream<List<Garage>> _getGarages(String userId) {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

    return _db
        .collection('garages')
        .where('idAdmin', isEqualTo: userId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Garage.fromFirestore(doc, null);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProvider = ref.watch(usuarioProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Lugares Disponibles',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      drawer: const MenuAdministrador(), // Agregando el menú lateral.
      body: Stack(
        children: [
          StreamBuilder<List<Garage>>(
            stream: _getGarages(userProvider.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.white));
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
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        garages[index].nombre,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Lugares disponibles: ${garages[index].lugaresDisponibles}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetalleGarage(garage: garages[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          BackButtonWidget(), // Agregando el botón atrás.
        ],
      ),
    );
  }
}