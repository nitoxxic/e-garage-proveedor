import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Reserva.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/detalleReserva.dart';
import 'package:flutter/material.dart';

class ListaReservas extends StatefulWidget {
  final String garageId;

  const ListaReservas({Key? key, required this.garageId}) : super(key: key);

  @override
  _ListaReservasState createState() => _ListaReservasState();
}

class _ListaReservasState extends State<ListaReservas> {
  List<Reserva> reservas = [];
  List<Reserva> reservasFiltradas = [];
  bool ordenarCronologicamente = true;
  String filtroActual = 'Todas';

  @override
  void initState() {
    super.initState();
    _cargarReservas();
  }

  Future<void> _cargarReservas() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Reservas')
        .where(
          'garajeId',
          isEqualTo: widget.garageId,
        )
        .get();

    setState(() {
      reservas =
          snapshot.docs.map((doc) => Reserva.fromFirestore(doc)).toList();
      _aplicarFiltro();
    });
  }

  void _aplicarFiltro() {
    setState(() {
      reservasFiltradas = reservas.where((reserva) {
        final ahora = DateTime.now();
        switch (filtroActual) {
          case 'Último mes':
            return reserva.startTime
                .isAfter(ahora.subtract(const Duration(days: 30)));
          case 'Activas':
            return reserva.endTime.isAfter(ahora);
          case 'Pasadas':
            return reserva.endTime.isBefore(ahora);
          default:
            return true;
        }
      }).toList();

      if (ordenarCronologicamente) {
        reservasFiltradas.sort((a, b) => a.startTime.compareTo(b.startTime));
      } else {
        reservasFiltradas.sort((a, b) => b.startTime.compareTo(a.startTime));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: AppBar(
        leading: Transform.scale(
          scale: 0.7,
          child: const BackButtonWidget(),
        ),
        backgroundColor: const Color(0xFF2E2E2E),
        title: const Text(
          'Lista de Reservas',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              ordenarCronologicamente ? Icons.arrow_upward : Icons.arrow_downward,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                ordenarCronologicamente = !ordenarCronologicamente;
                _aplicarFiltro();
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            onSelected: (String filtro) {
              setState(() {
                filtroActual = filtro;
                _aplicarFiltro();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Todas', child: Text('Todas')),
              const PopupMenuItem(
                  value: 'Último mes', child: Text('Último mes')),
              const PopupMenuItem(value: 'Activas', child: Text('Activas')),
              const PopupMenuItem(value: 'Pasadas', child: Text('Pasadas')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: reservasFiltradas.length,
        itemBuilder: (context, index) {
          final reserva = reservasFiltradas[index];
          return Card(
            color: const Color(0xFF2E2E2E), // Fondo de la tarjeta oscuro
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                '${reserva.elvehiculo.marca} ${reserva.elvehiculo.modelo}\n'
                '${reserva.elvehiculo.patente}',
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                'Inicio: ${reserva.startTime} \n'
                'Fin: ${reserva.endTime}',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleReserva(reserva: reserva,),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
