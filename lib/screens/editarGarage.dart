import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/detalleGarage.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/input_text_login.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/logo.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:latlong2/latlong.dart';

class EditarGarage extends StatefulWidget {
  final Garage garage;

  const EditarGarage({super.key, required this.garage});

  @override
  _EditarGarageState createState() => _EditarGarageState();
}

class _EditarGarageState extends State<EditarGarage> {
  late TextEditingController nombreController;
  late TextEditingController direccionController;
  late TextEditingController lugaresTotalesController;
  late TextEditingController lugaresDisponiblesController;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.garage.nombre);
    direccionController = TextEditingController(text: widget.garage.direccion);
    lugaresTotalesController =
        TextEditingController(text: widget.garage.lugaresTotales.toString());
    lugaresDisponiblesController = TextEditingController(
        text: widget.garage.lugaresDisponibles.toString());
  }

  @override
  void dispose() {
    nombreController.dispose();
    direccionController.dispose();
    lugaresTotalesController.dispose();
    lugaresDisponiblesController.dispose();
    super.dispose();
  }

  // Función para obtener coordenadas usando Nominatim
  Future<LatLng?> obtenerCoordenadasDesdeDireccion(String direccion) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$direccion&format=json&addressdetails=1&limit=1',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          return LatLng(lat, lon);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No se encontró la ubicación para la dirección proporcionada.')),
          );
          return null;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error al comunicarse con el servicio de geocodificación.')),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la ubicación: $e')),
      );
      return null;
    }
  }

  Future<void> _guardarCambios() async {
    final db = FirebaseFirestore.instance;
    try {
      // Validar lugares totales y disponibles
      int lugaresTotales = int.parse(lugaresTotalesController.text);
      int lugaresDisponibles = int.parse(lugaresDisponiblesController.text);

      if (lugaresTotales <= 0 || lugaresDisponibles < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Los lugares totales deben ser mayores a 0 y los disponibles no pueden ser negativos.'),
          ),
        );
        return;
      }

      // Obtener coordenadas actualizadas si la dirección cambia
      LatLng? coordenadas = await obtenerCoordenadasDesdeDireccion(direccionController.text);

      if (coordenadas == null) {
        return; // Si no se obtienen coordenadas, no continuar
      }

      // Actualizar los datos del garaje en Firestore
      print('*****************************************************');
      print(widget.garage.id);
      await db.collection('garages').doc(widget.garage.id).update({
        'nombre': nombreController.text,
        'direccion': direccionController.text,
        'lugaresTotales': lugaresTotales,
        'lugaresDisponibles': lugaresDisponibles,
        'latitude': coordenadas.latitude,
        'longitude': coordenadas.longitude,
      });

      // Crear un nuevo objeto Garage con los datos actualizados
      final updatedGarage = widget.garage.copyWith(
        nombre: nombreController.text,
        direccion: direccionController.text,
        lugaresTotales: lugaresTotales,
        lugaresDisponibles: lugaresDisponibles,
        latitude: coordenadas.latitude,
        longitude: coordenadas.longitude,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos guardados exitosamente.')),
      );

      // Reemplazar la pantalla con los datos actualizados
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetalleGarage(garage: updatedGarage),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar cambios: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Editar Garage'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const LogoWidget(size: 300, showText: false),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'EDITAR GARAGE',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InputTextLogin(
                  hintText: 'Nombre',
                  icon: const Icon(Icons.location_city, color: Colors.white),
                  controller: nombreController,
                ),
                const SizedBox(height: 20),
                InputTextLogin(
                  hintText: 'Dirección',
                  icon: const Icon(Icons.location_on, color: Colors.white),
                  controller: direccionController,
                ),
                const SizedBox(height: 20),
                InputTextLogin(
                  hintText: 'Lugares Totales',
                  icon: const Icon(Icons.add_location_alt, color: Colors.white),
                  controller: lugaresTotalesController,
                ),
                const SizedBox(height: 20),
                InputTextLogin(
                  hintText: 'Lugares Disponibles',
                  icon:
                      const Icon(Icons.add_circle_outline, color: Colors.white),
                  controller: lugaresDisponiblesController,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                 //   setState(() {
                  //   nombreController.text = nombreController.text;
                  //    direccionController.text = direccionController.text;
                  //    lugaresTotalesController.text = lugaresTotalesController.text;
                  //    lugaresDisponiblesController.text = lugaresDisponiblesController.text;
                  //  });
                    _guardarCambios();
                  },
                  child: const Center(child: Text('Guardar Cambios')),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: BackButtonWidget(
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
