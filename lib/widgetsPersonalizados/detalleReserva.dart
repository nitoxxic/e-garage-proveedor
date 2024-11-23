import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:flutter/material.dart';
import 'package:e_garage_proveedor/core/Entities/Reserva.dart';

class DetalleReserva extends StatelessWidget {
  final Reserva reserva;

  const DetalleReserva({Key? key, required this.reserva}) : super(key: key);

  String _formatDuracion(double duracion) {
    final int horas = duracion.floor();
    final int minutos = ((duracion - horas) * 60).round();
    return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: BackButtonWidget(),
        title: const Text(
          'Detalle de la Reserva',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                  'Fecha y hora de inicio', reserva.startTime.toString()),
              _buildDetailRow('Fecha y hora de fin', reserva.endTime.toString()),
              _buildDetailRow('Modelo del vehículo', reserva.elvehiculo.modelo!),
              _buildDetailRow('Marca del vehículo', reserva.elvehiculo.marca!),
              _buildDetailRow(
                  'Patente del vehículo', reserva.elvehiculo.patente!),
              _buildDetailRow('Medio de pago', reserva.medioDePago),
              _buildDetailRow(
                  'Monto total', '\$${reserva.monto.toStringAsFixed(2)}'),
              _buildDetailRow('Valor por hora al momento',
                  '\$${reserva.valorHoraAlMomentoDeReserva}'),
              _buildDetailRow('Valor por fracción al momento',
                  '\$${reserva.valorFraccionAlMomentoDeReserva}'),
              _buildDetailRow('Duración de estadía',
                  '${_formatDuracion(reserva.duracionEstadia)} horas'),
              _buildDetailRow('¿Está pago?', reserva.estaPago ? 'Sí' : 'No'),
              _buildDetailRow(
                  '¿Fue al garaje?', reserva.fueAlGarage == true ? 'Sí' : 'No'),
              _buildDetailRow(
                  '¿Se retiró?', reserva.seRetiro == true ? 'Sí' : 'No'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
