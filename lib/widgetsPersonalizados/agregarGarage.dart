// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/Usuario.dart';
import 'package:e_garage_proveedor/core/Entities/adminGarage.dart';
import 'package:e_garage_proveedor/core/Providers/user_provider.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/input_text_login.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class AgregarGarage extends ConsumerStatefulWidget {
  static const String name = "AgregarGarage";
  const AgregarGarage({super.key});

  @override
  _TestAgregarGarage createState() => _TestAgregarGarage();
}

class _TestAgregarGarage extends ConsumerState<AgregarGarage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _lugaresTotalesController =
      TextEditingController();
  final TextEditingController _valorHoraController = TextEditingController();
  final TextEditingController _valorFraccionController =
      TextEditingController();
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
    //_imageUrlController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isButtonEnabled = _nombreController.text.isNotEmpty &&
          _direccionController.text.isNotEmpty &&
          _lugaresTotalesController.text.isNotEmpty &&
          _valorHoraController.text.isNotEmpty &&
          _valorFraccionController.text.isNotEmpty;
      //  _imageUrlController.text.isNotEmpty;
    });
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

  /*Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _validateForm();
      });
    }
  }*/

  Future<void> guardarGarage(bool statusFormulario, Usuario usuario) async {
    if (statusFormulario) {
      try {
        String nombre = _nombreController.text;
        String direccion = _direccionController.text;
        double valorHora = double.tryParse(_valorHoraController.text) ?? 0.0;
        double valorFraccion =
            double.tryParse(_valorFraccionController.text) ?? 0.0;
        int lugaresTotales = int.tryParse(_lugaresTotalesController.text) ?? 0;
        String idAdmin = usuario.id;

        if (lugaresTotales <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('El número de lugares debe ser mayor a 0.')),
          );
          return;
        }

        if (valorHora <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('El valor de la hora debe ser mayor a 0.')),
          );
          return;
        }

        if (valorFraccion <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'El valor de la fraccion de hora debe ser mayor a 0.')),
          );
          return;
        }

        /* if (_selectedImage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor selecciona una imagen.')),
          );
          return;
        }*/

        // Subir la imagen y obtener la URL
        /* final uploadedImageUrl = await _uploadImage(_selectedImage!);
        if (uploadedImageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('No se pudo cargar la imagen. Intente de nuevo.')),
          );
          return; // No continuar si la carga falló
        }
        imageUrl = uploadedImageUrl;*/

        // Obtener coordenadas usando Nominatim
        LatLng? coordenadas = await obtenerCoordenadasDesdeDireccion(direccion);

        if (coordenadas == null) {
          return; // Si no se pudieron obtener las coordenadas, no continuar.
        }

        double latitude = coordenadas.latitude;
        double longitude = coordenadas.longitude;

        DocumentReference docRef = db.collection('garages').doc();
        String idParaGarage = docRef.id;

        // Crear un mapa para Firestore
        Map<String, dynamic> garageData = {
          'id': docRef.id,
          'nombre': nombre,
          'direccion': direccion,
          'lugaresTotales': lugaresTotales,
          'latitude': latitude,
          'longitude': longitude,
          'valorHora': valorHora,
          'valorFraccion': valorFraccion,
          'idAdmin': idAdmin
        };

        // Guardar el garage en Firestore y obtener su ID
        await db.collection('garages').doc(docRef.id).set(garageData);

        final relacionAdminGarage =
            adminGarage(idAdmin: idAdmin, idGarage: docRef.id);

        await db
            .collection('adminGarage')
            .doc()
            .set(relacionAdminGarage.toFirestore());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Garage agregado exitosamente.')),
        );

        // Regresar a la pantalla anterior
        context.goNamed('ListaGarages');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar garage: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userprovider = ref.read(usuarioProvider);
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
                const LogoWidget(size: 300, showText: false),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputTextLogin(
                        hintText: 'Nombre',
                        icon: const Icon(Icons.location_city,
                            color: Colors.white),
                        controller: _nombreController,
                      ),
                      const SizedBox(height: 20),
                      InputTextLogin(
                        hintText: 'Dirección',
                        icon:
                            const Icon(Icons.location_on, color: Colors.white),
                        controller: _direccionController,
                      ),
                      const SizedBox(height: 20),
                      InputTextLogin(
                        hintText: 'Valor Hora',
                        icon:
                            const Icon(Icons.access_time, color: Colors.white),
                        controller: _valorHoraController,
                      ),
                      const SizedBox(height: 20),
                      InputTextLogin(
                        hintText: 'Valor Fracción',
                        icon: const Icon(Icons.add_alarm_rounded,
                            color: Colors.white),
                        controller: _valorFraccionController,
                      ),
                      const SizedBox(height: 20),
                      InputTextLogin(
                        hintText: 'Lugares Totales',
                        icon: const Icon(Icons.add_location_alt,
                            color: Colors.white),
                        controller: _lugaresTotalesController,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () => guardarGarage(
                                _formKey.currentState!.validate(), userprovider)
                            : null,
                        child: const Center(child: Text('Agregar Garage')),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: BackButtonWidget(onPressed: () {
          Navigator.pop(context);
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}
