import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/core/Providers/user_provider.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/MenuAdministrador.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/ingresosGarage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Ingresos extends ConsumerWidget {
  Ingresos({super.key});

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Garage>> _getGarages(String id) {
    return _db
        .collection('garages')
        .where('idAdmin', isEqualTo: id)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        var data = doc.data();
        return Garage(
            id: data['id'],
            nombre: data['nombre'] ?? 'Garage sin nombre',
            direccion: data['direccion'] ?? 'Dirección desconocida',
            lugaresTotales: data['lugaresTotales'] ?? 0,
            latitude: data['latitude'] ?? 0.0,
            longitude: data['longitude'] ?? 0.0,
            idAdmin: data['idAmin'] ?? 'Garage sin relacion');
      }).toList();
    });
  }

  Future<Map<String, dynamic>> _calcularIngresosTotales(String adminId) async {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    double ingresosTotales = 0.0;
    int totalReservas = 0;

    QuerySnapshot garagesSnapshot = await _db
        .collection('garages')
        .where('idAdmin', isEqualTo: adminId)
        .get();

    for (var garageDoc in garagesSnapshot.docs) {
      String garageId = garageDoc['id'];

      QuerySnapshot reservasSnapshot = await _db
          .collection('Reservas')
          .where('garajeId', isEqualTo: garageId)
          .where('fechaHoraInicio', isGreaterThanOrEqualTo: startOfMonth)
          .where('fechaHoraInicio', isLessThanOrEqualTo: endOfMonth)
          .get();

      for (var reservaDoc in reservasSnapshot.docs) {
        ingresosTotales += reservaDoc['monto'] ?? 0.0;
        totalReservas++;
      }
    }

    return {'ingresosTotales': ingresosTotales, 'totalReservas': totalReservas};
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProvider = ref.watch(usuarioProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          );
        }),
      ),
      drawer: const MenuAdministrador(),
      body: Stack(
        children: [
          Column(
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: _calcularIngresosTotales(userProvider.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error al calcular ingresos: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  double ingresosTotales =
                      snapshot.data?['ingresosTotales'] ?? 0.0;
                  int totalReservas = snapshot.data?['totalReservas'] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ingresos Totales del Mes: \$${ingresosTotales.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total de Reservas del Mes: $totalReservas',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: StreamBuilder<List<Garage>>(
                  stream: _getGarages(userProvider.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            onTap: () {
                              Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  IngresosGarage(garage: garages[index])));
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: BackButtonWidget(),
          ),
        ],
      ),
    );
  }
}