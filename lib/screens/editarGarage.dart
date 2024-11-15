import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/input_text_login.dart';
import 'package:flutter/material.dart';



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
    lugaresTotalesController = TextEditingController(text: widget.garage.lugaresTotales.toString());
    lugaresDisponiblesController = TextEditingController(text: widget.garage.lugaresDisponibles.toString());
  }

  @override
  void dispose() {
    nombreController.dispose();
    direccionController.dispose();
    lugaresTotalesController.dispose();
    lugaresDisponiblesController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final db = FirebaseFirestore.instance;

    try {
      // Actualizar los datos del garaje en Firestore
      await db.collection('garages').doc(widget.garage.id).update({
        'nombre': nombreController.text,
        'direccion': direccionController.text,
        'lugaresTotales': int.parse(lugaresTotalesController.text),
        'lugaresDisponibles': int.parse(lugaresDisponiblesController.text),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Datos guardados exitosamente.')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar cambios: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                Image.asset(
                  'assets/images/car_logo.png',
                  height: 100,
                ),
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
                  hintText: 'Nombre del Garage',
                  icon: const Icon(Icons.home),
                ),
                const SizedBox(height: 20),
                InputTextLogin(
                  hintText: 'Dirección',
                  icon: const Icon(Icons.location_on),
                ),
                const SizedBox(height: 20),
                InputTextLogin(
                  hintText: 'Lugares Totales',
                  icon: const Icon(Icons.event_seat),
                ),
                const SizedBox(height: 20),
                InputTextLogin(
                  hintText: 'Lugares Disponibles',
                  icon: const Icon(Icons.event_seat),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _guardarCambios,
                  child: const Text("Guardar Cambios"),
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