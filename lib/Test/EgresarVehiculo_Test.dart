import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/screens/LoginAdministrador.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
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
    _patenteController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isButtonEnabled = _patenteController.text.isNotEmpty &&
          _validatePatente(_patenteController.text) == null;
    });
  }

  String? _validatePatente(String? value) {
    final regex1 = RegExp(r'^[A-Za-z]{3}\d{3}$');
    final regex2 = RegExp(r'^[A-Za-z]{2}\d{3}[A-Za-z]{2}$');

    if (value == null || value.isEmpty) {
      return 'La patente no puede estar vacía';
    } else if (!regex1.hasMatch(value) && !regex2.hasMatch(value)) {
      return 'Patente no válida. Debe ser 3 letras y 3 \nnúmeros o 2 letras, 3 números y 2 letras.';
    }
    return null;
  }

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

  void onCancel() {
    Navigator.of(context).pop();
  }

  Future<void> _egresarVehiculo(String patenteBuscado) async {
    final db = FirebaseFirestore.instance;

    QuerySnapshot queryReserva = await db
        .collection('Reservas')
        .where('elvehiculo.patente', isEqualTo: patenteBuscado)
        .limit(1)
        .get();

    if (queryReserva.docs.isEmpty) {
      showBox('No se encontró ningún auto con esa patente');
    } else {
      DocumentSnapshot docReserva = queryReserva.docs.first;

      if (docReserva['fueAlGarage'] == true &&
          docReserva['seRetiro'] == false) {
        await db.collection('Reservas').doc(docReserva.id).update({
          'seRetiro': true,
        });

        String garageId = docReserva['garajeId'];
        DocumentReference garageRef = db.collection('garages').doc(garageId);

        await db.runTransaction((transaction) async {
          DocumentSnapshot garageSnapshot = await transaction.get(garageRef);

          if (!garageSnapshot.exists) {
            showBox('Error: El garage no existe');
            return;
          }

          int lugaresDisponibles = garageSnapshot['lugaresDisponibles'];
          transaction.update(
              garageRef, {'lugaresDisponibles': lugaresDisponibles + 1});
        });

        showBox(
            'Se ha retirado el vehiculo con patente ${docReserva['elvehiculo']['patente']}');
      } else {
        showBox(
            'El vehiculo con patente: ${docReserva['elvehiculo']['patente']} no ha ingresado previamente');
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
                            'Retirar Vehiculo',
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
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            validator: _validatePatente,
                          ),
                          const SizedBox(height: 50),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isButtonEnabled
                                  ? () async {
                                      if (_formKey.currentState!.validate()) {
                                        await _egresarVehiculo(
                                            _patenteController.text);
                                      }
                                    }
                                  : () {
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
          const BackButtonWidget(),
        ],
      ),
    );
  }
}
