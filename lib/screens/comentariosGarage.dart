// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_garage_proveedor/core/Entities/ComentarioReserva.dart';
import 'package:e_garage_proveedor/core/Entities/Garage.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/BotonAtras.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/MenuAdministrador.dart';
import 'package:e_garage_proveedor/widgetsPersonalizados/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ComentariosGarage extends ConsumerStatefulWidget {
  final Garage garage;

  const ComentariosGarage({Key? key, required this.garage}) : super(key: key);

  @override
  _ComentariosGarageState createState() => _ComentariosGarageState();
}

class _ComentariosGarageState extends ConsumerState<ComentariosGarage> {
  Future<double> totalPuntaje(WidgetRef ref) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Obtén los documentos que coinciden con el idGarage
    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection('ComentarioReserva')
        .where('idGarage', isEqualTo: widget.garage.id)
        .get();

    // Convierte los documentos en una lista de objetos Comentarioreserva
    List<Comentarioreserva> listaComentarios = snapshot.docs
        .map((doc) => Comentarioreserva.fromFirestore(doc))
        .toList();

    // Calcula el puntaje total sumando los puntajes individuales
    double Puntaje = 0.0;
    double totalPuntaje;
    for (var comentario in listaComentarios) {
      Puntaje += comentario.traerElPuntaje ?? 0.0;
    }
    if (Puntaje > 0) {
      totalPuntaje = Puntaje / listaComentarios.length;
    } else {
      totalPuntaje = 0.0;
    }
    return totalPuntaje;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: const MenuAdministrador(),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const LogoWidget(size: 300, showText: false),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'RESEÑAS',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: FutureBuilder<double>(
                    future: totalPuntaje(
                        ref), // Llama al método que retorna el Future
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Mientras se espera el resultado del Future
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // Si ocurre un error
                        return Text(
                          'Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        );
                      } else if (snapshot.hasData) {
                        // Cuando el Future se resuelve correctamente
                        return Text(
                          snapshot.data! > 0
                              ? 'Puntaje promedio: ${snapshot.data}'
                              : '', // Muestra el valor del Future
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        );
                      } else {
                        // Caso por defecto
                        return const Text(
                          'No se pudo obtener el puntaje',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: _ListView(garage: widget.garage),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: BackButtonWidget(
              onPressed: () {
                context.push('/mapa');
              },
            ),
          )
        ],
      ),
    );
  }
}

class _ListView extends ConsumerWidget {
  final Garage garage;
  const _ListView({required this.garage});

  Future<List<Comentarioreserva>> _fetchReservas(WidgetRef ref) async {
    FirebaseFirestore firestore = await FirebaseFirestore.instance;

    QuerySnapshot<Map<String, dynamic>> snapshot = await firestore
        .collection('ComentarioReserva')
        .where('idGarage', isEqualTo: garage.id)
        .get();

    return snapshot.docs.map((doc) {
      return Comentarioreserva.fromFirestore(doc);
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Comentarioreserva>>(
      future: _fetchReservas(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text('No hay Comentarios.',
                  style: TextStyle(color: Colors.white)));
        } else {
          List<Comentarioreserva> listaComentarios = snapshot.data!;
          return ListView.builder(
            itemCount: listaComentarios.length,
            itemBuilder: (context, index) {
              Comentarioreserva elComentarioreserva = listaComentarios[index];
              return Card(
                color: Colors.grey[800],
                child: ListTile(
                  title: Text(
                    'Puntaje: ${elComentarioreserva.puntuacion}\n',
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${elComentarioreserva.comentario}',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
