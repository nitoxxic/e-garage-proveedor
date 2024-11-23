import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';

class BiometriaService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registrarHuellaDuenoGarage(
      BuildContext context, String duenoId, Map<String, String> duenoCredentials) async {
    try {
      // Verificar soporte y autenticar para registrar huella
      bool authenticated = await _auth.authenticate(
        localizedReason: 'Registra tu huella para acceder con ella',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        // Guardar credenciales en almacenamiento seguro
        await _storage.write(key: 'email', value: duenoCredentials['email']);
        await _storage.write(key: 'password', value: duenoCredentials['password']);

        // Actualizar el estado de biometría en la colección `duenos`
        await _db.collection('duenos').doc(duenoId).update({
          'biometriaHabilitada': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Huella digital registrada y credenciales almacenadas.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar huella: $e')),
      );
    }
  }

  Future<void> validarCredencialesDuenoGarage(
      BuildContext context, Function onDuenoAuthenticated) async {
    try {
      // Recuperar credenciales almacenadas
      final email = await _storage.read(key: 'email');
      final password = await _storage.read(key: 'password');

      if (email == null || password == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron credenciales asociadas a la huella.')),
        );
        return;
      }

      // Buscar en la colección `duenos`
      final query = await _db.collection('duenos').where('email', isEqualTo: email).get();
      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no encontrado.')),
        );
        return;
      }

      final duenoDoc = query.docs.first;
      final duenoData = duenoDoc.data();

      // Validar contraseña
      if (duenoData['password'] == password) {
        // Invocar el callback al autenticar al usuario
        onDuenoAuthenticated(duenoDoc.id, duenoData);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña incorrecta.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al validar credenciales: $e')),
      );
    }
  }
}

