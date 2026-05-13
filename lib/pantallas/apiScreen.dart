import 'package:flutter/material.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_detail_screen.dart';

import '../service/connection_service.dart';

/// Pantalla principal que muestra el listado de monstruos obtenidos de la API.
class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  State<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  // Variable para almacenar el objeto Future que traerá la lista de monstruos.
  late Future<MonsterList> futureMonsterSmall;

  @override
  void initState() {
    super.initState();
    // Al iniciar, cargamos la lista (buscará en caché automáticamente).
    futureMonsterSmall = ConnectionService().fetchEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monstruos D&D'),
        actions: [
          // Botón para forzar la descarga de datos nuevos desde la API.
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar desde API',
            onPressed: () {
              setState(() {
                // Forzamos la recarga pasando true al servicio.
                futureMonsterSmall = ConnectionService().fetchEventos(forceRefresh: true);
              });
              // Feedback visual al usuario de que la carga ha comenzado.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Actualizando lista de monstruos...')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<MonsterList>(
          future: futureMonsterSmall,
          builder: (context, snapshot) {
            // Mientras la petición está en progreso, mostramos un círculo de carga.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // Si la petición finaliza con éxito y tiene datos válidos.
            if (snapshot.hasData) {
              MonsterList monstros = snapshot.data!;
              final results = monstros.results ?? [];

              // Construimos la lista scrolleable de elementos.
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final monster = results[index];
                  final String indexName = monster["index"] ?? "";

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      onTap: () {
                        // Al pulsar, navegamos a la pantalla de detalle de esta criatura.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MonsterDetailScreen(
                              monsterUrl: monster["url"].toString(),
                              monsterName: monster["name"].toString(),
                            ),
                          ),
                        );
                      },
                      // Miniatura de la criatura obtenida por URL dinámica.
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            "https://www.dnd5eapi.co/api/images/monsters/$indexName.png",
                            fit: BoxFit.cover,
                            // Si la imagen no existe en la API, mostramos un icono genérico.
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.pets, color: Colors.grey),
                          ),
                        ),
                      ),
                      title: Text(
                        monster["name"]?.toString() ?? "Sin nombre",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      // Subtítulo que carga el tamaño y tipo de forma asíncrona.
                      subtitle: _MonsterSubtitle(url: monster["url"].toString()),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              );
            } 
            // Si ocurre un error en la comunicación con la API o el almacenamiento.
            else if (snapshot.hasError) {
              // Registro del error en consola para depuración.
              print('Error en ApiScreen: ${snapshot.error}');
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 60),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Ocurrió un error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Permite al usuario intentar cargar de nuevo.
                      setState(() {
                        futureMonsterSmall = ConnectionService().fetchEventos();
                      });
                    },
                    child: const Text('Reintentar'),
                  )
                ],
              );
            }

            // Caso base por defecto (mientras se espera).
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

/// Widget interno para cargar y mostrar el Tamaño y Tipo en cada elemento de la lista.
/// Se usa un widget separado para no recargar toda la lista al obtener los detalles de uno.
class _MonsterSubtitle extends StatelessWidget {
  final String url;
  const _MonsterSubtitle({required this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Monster>(
      // Hacemos una petición rápida para obtener el 'size' y 'type' de este monstruo.
      future: ConnectionService().fetchMonsterDetail(url),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final m = snapshot.data!;
          // Mostramos la información formateada (ej: Medium - undead).
          return Text("${m.size} - ${m.type}", style: const TextStyle(fontSize: 12));
        } else if (snapshot.hasError) {
          // Si falla, mostramos un texto discreto de error.
          return const Text("Info no disponible", style: TextStyle(fontSize: 12, color: Colors.grey));
        }
        // Texto de carga mientras se obtienen los datos específicos.
        return const Text("Cargando...", style: TextStyle(fontSize: 12, color: Colors.grey));
      },
    );
  }
}
