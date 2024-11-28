import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/MenuAdministrador.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegistrarpagoEnefectivoEnElGarage extends StatefulWidget {
  static const String name = 'Registrarpagoefectivo';
  final Garage garage;

  const RegistrarpagoEnefectivoEnElGarage({Key? key, required this.garage});

  @override
  State<RegistrarpagoEnefectivoEnElGarage> createState() =>
      _RegistrarpagoefectivoState();
}

class _RegistrarpagoefectivoState
    extends State<RegistrarpagoEnefectivoEnElGarage> {
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

  Future<void> _registrarPago(String patenteBuscado, String idGarage) async {
    final db = FirebaseFirestore.instance;

    QuerySnapshot queryReserva = await db
        .collection('Reservas')
        .where('garajeId', isEqualTo: idGarage)
        .where('elvehiculo.patente', isEqualTo: patenteBuscado)
        .where('estaPago', isNotEqualTo: true)
        .limit(1)
        .get();

    if (queryReserva.docs.isEmpty) {
      showBox(
          'No se encontró ningún auto con esa patente que tenga una reserva');
    } else {
      DocumentSnapshot docReserva = queryReserva.docs.first;

      if (docReserva['estaPago'] == false) {
        await db.collection('Reservas').doc(docReserva.id).update({
          'estaPago': true,
        });
        showBox(
            'Pago de la reserva registrado para el vehiculo con patente ${docReserva['elvehiculo']['patente']}');
      } else {
        showBox(
            'La reserva ya se encontraba abonada para la patente: ${docReserva['elvehiculo']['patente']}');
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
    final garage = widget.garage;
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
                            'Ingrese la patente para registrar el pago',
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
                              labelStyle: TextStyle(color: Colors.white),
                              labelText: 'Patente',
                              border: OutlineInputBorder(),
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
                                        await _registrarPago(
                                            _patenteController.text, garage.id);
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
                                'Registrar',
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
                    context.push('/listaDeGarageParaPagar');
                  },
                ),
              )),
        ],
      ),
    );
  }
}
