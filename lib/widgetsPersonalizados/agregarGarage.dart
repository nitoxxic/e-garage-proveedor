import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/input_text_login.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AgregarGarage extends ConsumerStatefulWidget {
  static final String name = "AgregarGarage";
  const AgregarGarage({super.key});

  @override
  _TestAgregarGarage createState() => _TestAgregarGarage();
}

class _TestAgregarGarage extends ConsumerState<AgregarGarage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _lugaresTotalesController = TextEditingController();
  final FocusNode _direccionFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  bool _isButtonEnabled = false;
  final db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nombreController.addListener(_validateForm);
    _direccionController.addListener(_validateForm);
    _lugaresTotalesController.addListener(_validateForm);

    _direccionFocusNode.addListener(() {
      if (!_direccionFocusNode.hasFocus) {
        //validaciones extra
      }
    });
  }

  void _validateForm() {
    setState(() {
      _isButtonEnabled = _nombreController.text.isNotEmpty &&
          _direccionController.text.isNotEmpty &&
          _lugaresTotalesController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _lugaresTotalesController.dispose();
    _direccionFocusNode.dispose();
    super.dispose();
  }

  Future<void> guardarGarage(bool statusFormulario) async {
    if (statusFormulario) {
      try {
        final nuevoGarage = Garage(
          id: '', // Firestore generará un id automáticamente
          nombre: _nombreController.text,
          direccion: _direccionController.text,
          lugaresTotales: int.parse(_lugaresTotalesController.text),
        );

        // Guardar el garage en Firestore
        await db.collection('garages').add(nuevoGarage.toFirestore());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Garage agregado'),
            duration: Duration(seconds: 3),
          ),
        );

        // Regresar a la pantalla de lista de garages
        context.goNamed('ListaGarages');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text('Complete los datos del garage'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                  const LogoWidget(size: 300, showText: false),
                  const SizedBox(height: 20),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputTextLogin(
                        hintText: 'Nombre',
                        icon: const Icon(Icons.location_city, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      InputTextLogin(
                        hintText: 'Dirección',
                        icon: const Icon(Icons.location_on, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      InputTextLogin(
                        hintText: 'Lugares Totales',
                        icon: const Icon(Icons.add_location_alt, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () => guardarGarage(_formKey.currentState!.validate())
                            : null,
                        child: const Center(
                          child: Text('Confirmar'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
       floatingActionButton: BackButtonWidget(
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
            floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}