import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';

class BiometriaService {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> registrarHuella(BuildContext context, String userId, Map<String, String> userCredentials) async {
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
        // Guardar credenciales de usuario en almacenamiento seguro
        await _storage.write(key: 'email', value: userCredentials['email']);
        await _storage.write(key: 'password', value: userCredentials['password']);

        // Actualizar estado de biometría en Firestore
        await _db.collection('users').doc(userId).update({
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

  Future<void> validarCredenciales(BuildContext context, Function onUserAuthenticated) async {
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

      // Buscar usuario en Firestore
      final query = await _db.collection('users').where('email', isEqualTo: email).get();
      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no encontrado.')),
        );
        return;
      }

      final userDoc = query.docs.first;
      final userData = userDoc.data();

      // Validar contraseña
      if (userData['password'] == password) {
        // Invocar el callback al autenticar al usuario
        onUserAuthenticated(userDoc.id, userData);
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
