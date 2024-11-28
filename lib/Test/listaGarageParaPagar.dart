import 'package:e_garage_proveedor/Test/RegistrarPagoEnElGarage.dart';
import 'package:e_garage_proveedor/Test/ingresarVehiculoAGarage.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/core/Providers/user_provider.dart';

class listaDeGarageParaPagar extends ConsumerWidget {
  static final String name = 'listaDeGarageParaPagar';

  const listaDeGarageParaPagar({super.key});

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
        elevation: 0,
        leading: Container(),
      ),
      body: Stack(
        children: [
          // Contenido principal
          StreamBuilder<List<Garage>>(
            stream: _getGarages(userProvider.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
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
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        garages[index].nombre,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        garages[index].direccion,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RegistrarpagoEnefectivoEnElGarage(
                                      garage: garages[index])

                              //DetalleGarage(garage: garages[index]),
                              ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),

          const BackButtonWidget(),
        ],
      ),
    );
  }
}
