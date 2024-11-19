import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/screens/LoginAdministrador.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/MenuAdministrador.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/dialog_box.dart';
import 'package:flutter/material.dart';

class Retirarvehiculo extends StatefulWidget {
  static const String name = 'Retirarvehiculo';
  const Retirarvehiculo({super.key});

  @override
  State<Retirarvehiculo> createState() => _RetirarVehiculovehiculoState();
}

class _RetirarVehiculovehiculoState extends State<Retirarvehiculo> {
  final TextEditingController _patenteController = TextEditingController();
  final FocusNode _patenteFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // Añade un listener al controlador para validar el formulario
    _patenteController.addListener(_validateForm);
  }

  // Valida si el formulario es válido y habilita o deshabilita el botón
  void _validateForm() {
    setState(() {
      _isButtonEnabled = _patenteController.text.isNotEmpty &&
          _validatePatente(_patenteController.text) == null;
    });
  }

  // Valida la patente según los formatos permitidos
  String? _validatePatente(String? value) {
    final regex1 = RegExp(r'^[A-Za-z]{3}\d{3}$'); // AAA123
    final regex2 = RegExp(r'^[A-Za-z]{2}\d{3}[A-Za-z]{2}$'); // AA123AA

    if (value == null || value.isEmpty) {
      return 'La patente no puede estar vacía';
    } else if (!regex1.hasMatch(value) && !regex2.hasMatch(value)) {
      return 'Patente no válida. Debe ser 3 letras y 3 números o 2 letras, 3 números y 2 letras.';
    }
    return null;
  }

  // Muestra un diálogo con el mensaje proporcionado
  void showBox(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return BoxDialog(
            message: message,
            onCancel: onCancel,
          );
        });
  }

  // Función de cancelación para cerrar el diálogo
  void onCancel() {
    Navigator.of(context).pop();
  }

  // Función para retirar el auto de la base de datos
  Future<void> _ingresarVehiculo(String patenteBuscado) async {
    final db = FirebaseFirestore.instance;

    // busca si existe una reserva con la patente ingresada
    QuerySnapshot queryReserva = await db
        .collection('Reservas')
        .where('elvehiculo.patente', isEqualTo: patenteBuscado)
        .limit(1)
        .get();

    // si no existe la reserva lo alerta
    if (queryReserva.docs.isEmpty) {
      showBox('No se encontró ningún auto con esa patente');
    } else {
      // Si existe le reserva se busca al vehiculo y los datos del usuario.
      // Para asi tambien eliminarlos de la DB.

      // Busca el vehículo por patente
      QuerySnapshot queryAuto = await db
          .collection('Vehiculos')
          .where('patente', isEqualTo: patenteBuscado)
          .limit(1)
          .get();

      DocumentSnapshot docReserva = queryReserva.docs.first;

      if (docReserva['fueAlGarage'] == true &&
          docReserva['seRetiro'] == false) {
        await db.collection('Reservas').doc(docReserva.id).update({
          'seRetiro': true,
        });

        showBox(
            'Se ha retirado el vehiculo con patente ${docReserva['elvehiculo']['patente']}');
      } else {
        showBox(
            'El vehiculo con patente: ${docReserva['elvehiculo']['patente']} no ha ingresado previamente');
      }

      /* DocumentSnapshot cantLugares =
          await db.collection('Lugares').doc('68PCmlqAUB3JJdDFBodl').get();

      int cantActualLugares = cantLugares['cantTotalLugares'];
      cantActualLugares++;
      //final Capacidad = CapacidadTotal(cantTotalLugares: cantActualLugares);

      await db
          .collection('Lugares')
          .doc('68PCmlqAUB3JJdDFBodl')
          .set(Capacidad.toFirestore());*/

      // Elimina documentos de la base de datos

      // Muestra un mensaje indicando que el puesto fue liberado
      //showBox('Se va a liberar el puesto $puesto');
    }
  }

  @override
  void dispose() {
    _patenteController.dispose();
    _patenteFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Retirar vehiculo'),
      ),
      drawer: const MenuAdministrador(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Input para la patente del vehículo
                      TextFormField(
                        controller: _patenteController,
                        focusNode: _patenteFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Patente',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validatePatente,
                      ),

                      const SizedBox(height: 50),

                      // Botón para retirar el vehículo
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isButtonEnabled
                                ? () async {
                                    // Si el formulario es válido, retira el vehículo
                                    if (_formKey.currentState!.validate()) {
                                      await _ingresarVehiculo(
                                          _patenteController.text);
                                    }
                                  }
                                : () {
                                    // Si el formulario no es válido, muestra un mensaje de error
                                    if (!_formKey.currentState!.validate()) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Por favor, corrige los errores antes de continuar.'),
                                          duration: Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  },
                            child: const Text(
                              'Egresar',
                              style: TextStyle(fontSize: 18),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        },
        child: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }
}