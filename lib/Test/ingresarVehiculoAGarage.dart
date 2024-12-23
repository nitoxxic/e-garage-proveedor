import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/MenuAdministrador.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IngresarvehiculoAlGarage extends StatefulWidget {
  static const String name = 'IngresarvehiculoAlGarage';
  final Garage garage;

  const IngresarvehiculoAlGarage({Key? key, required this.garage})
      : super(key: key);

  @override
  State<IngresarvehiculoAlGarage> createState() => _IngresarvehiculoState();
}

class _IngresarvehiculoState extends State<IngresarvehiculoAlGarage> {
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
      return 'Patente no válida. Debe ser 3 letras y 3 \n números o 2 letras, 3 números y 2 letras.';
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
  Future<void> _ingresarVehiculo(String patenteBuscado, String idGarage) async {
    final db = FirebaseFirestore.instance;
    print('*************************************');
    print(idGarage);

    QuerySnapshot queryReserva = await db
        .collection('Reservas')
        .where('garajeId', isEqualTo: idGarage)
        .where('elvehiculo.patente', isEqualTo: patenteBuscado)
        .where('seRetiro', isNotEqualTo: true)
        .limit(1)
        .get();

    if (queryReserva.docs.isEmpty) {
      showBox(
          'No se encontró ningún auto con esa patente que tenga una reserva');
    } else {
      DocumentSnapshot docReserva = queryReserva.docs.first;
      if (docReserva['estaPago'] == true &&
          docReserva['fueAlGarage'] == false) {
        String garageId = docReserva['garajeId'];
        DocumentSnapshot garageSnapshot =
            await db.collection('garages').doc(garageId).get();
        if (garageSnapshot.exists) {
          int lugaresDisponibles = garageSnapshot['lugaresDisponibles'];
          await db.collection('Reservas').doc(docReserva.id).update({
            'fueAlGarage': true,
          });
          await db.collection('garages').doc(garageId).update({
            'lugaresDisponibles': lugaresDisponibles - 1,
          });
        }
        showBox(
            'Se ha ingresado el vehiculo con patente ${docReserva['elvehiculo']['patente']}');
      } else if (docReserva['estaPago'] == true &&
          docReserva['fueAlGarage'] == true) {
        showBox(
            'Advertencia: El vehiculo con patente ${docReserva['elvehiculo']['patente']} ya habia sido ingresado');
      } else {
        showBox(
            'Reserva no abonada para la patente: ${docReserva['elvehiculo']['patente']}');
      }
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
    final garage = widget.garage; // Accede al Garage desde widget.garage
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
          LayoutBuilder(
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
                          const Text(
                            'Ingresar Vehiculo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: _patenteController,
                            focusNode: _patenteFocusNode,
                            decoration: const InputDecoration(
                                labelText: 'Patente',
                                border: OutlineInputBorder(),
                                labelStyle: TextStyle(color: Colors.white)),
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
                                            _patenteController.text, garage.id);
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
                                'Ingresar',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    context.push('/listaDeGarageParaIngresarVehiculos');
                  },
                ),
              )),
        ],
      ),
    );
  }
}
