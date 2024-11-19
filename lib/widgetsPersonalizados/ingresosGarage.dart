// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/core/Entities/Reserva.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/detalleReserva.dart';
import 'package:flutter/material.dart';

class IngresosGarage extends StatefulWidget {
  final Garage garage;

  const IngresosGarage({super.key, required this.garage});

  @override
  _IngresosGarageState createState() => _IngresosGarageState();
}

class _IngresosGarageState extends State<IngresosGarage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late Stream<List<Reserva>> _reservasStream;
  double ingresosMensuales = 0.0;
  int totalReservas = 0;

  @override
  void initState() {
    super.initState();
    _reservasStream = _getReservasMensuales(widget.garage.id);
  }

  Stream<List<Reserva>> _getReservasMensuales(String garageId) {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth =
        DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));

    return _db
        .collection('Reservas')
        .where('garajeId', isEqualTo: garageId)
        .where('fechaHoraInicio', isGreaterThanOrEqualTo: startOfMonth)
        .where('fechaHoraInicio', isLessThanOrEqualTo: endOfMonth)
        .snapshots()
        .map((querySnapshot) {
      List<Reserva> reservas =
          querySnapshot.docs.map((doc) => Reserva.fromFirestore(doc)).toList();

      setState(() {
        ingresosMensuales =
            reservas.fold(0.0, (total, reserva) => total + reserva.monto);
        totalReservas = reservas.length;
      });

      return reservas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.garage.nombre,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen del Mes',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total de Reservas: $totalReservas',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Text(
                  'Ingresos Totales: \$${ingresosMensuales.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white70),
          Expanded(
            child: StreamBuilder<List<Reserva>>(
              stream: _reservasStream,
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
                      'No hay reservas para este mes.',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                List<Reserva> reservas = snapshot.data!;

                return ListView.builder(
                  itemCount: reservas.length,
                  itemBuilder: (context, index) {
                    Reserva reserva = reservas[index];
                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          'Reserva ${index + 1}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Monto: \$${reserva.monto.toStringAsFixed(2)}\n'
                          'Pago: ${reserva.estaPago ? 'Si' : 'No'}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetalleReserva(reserva: reserva),
                            ),
                          );
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
    );
  }
}
