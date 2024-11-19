import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/core/Providers/user_provider.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/listaReservas.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class PantallaReservas extends ConsumerWidget {
  const PantallaReservas({super.key});

  Future<List<Garage>> fetchGarages(userId) async {
    final querySnapshot = await FirebaseFirestore.instance
    .collection('garages')
    .where('idAdmin', isEqualTo: userId)
    .get();
    return querySnapshot.docs.map((doc) => Garage.fromFirestore(doc, null)).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProvider = ref.watch(usuarioProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Mis Garages'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Garage>>(
        future: fetchGarages(userProvider.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tienes garages registrados.', style: TextStyle(color: Colors.white)));
          }

          final garages = snapshot.data!;
          return ListView.builder(
            itemCount: garages.length,
            itemBuilder: (context, index) {
              final garage = garages[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ListaReservas(garageId: garage.garageId),
                    ),
                  );
                },
                child: Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          garage.nombre,
                          style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dirección: ${garage.direccion}',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lugares Disponibles: ${garage.lugaresDisponibles} / ${garage.lugaresTotales}',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
