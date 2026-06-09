import 'package:flutter/material.dart';
import 'package:proyecto_chachipistachi_dnd/l10n/app_localizations.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/service/monster_storage_service.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_detail_screen.dart';

/// Pantalla del Bestiario Público de la Comunidad.
/// Permite explorar criaturas creadas por otros usuarios, ver sus detalles
/// y descargarlas al repositorio personal del usuario actual.
class PublicBestiaryScreen extends StatefulWidget {
  const PublicBestiaryScreen({super.key});

  @override
  State<PublicBestiaryScreen> createState() => _PublicBestiaryScreenState();
}

class _PublicBestiaryScreenState extends State<PublicBestiaryScreen> {
  final MonsterStorageService _storageService = MonsterStorageService();
  
  /// Future que contiene la lista de criaturas compartidas en la nube.
  late Future<List<Monster>> _publicMonsters;

  @override
  void initState() {
    super.initState();
    // Cargamos los datos desde la colección 'public_monsters' de Firestore.
    _publicMonsters = _storageService.getPublicMonsters();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.publicBestiary),
        elevation: 10,
      ),
      body: FutureBuilder<List<Monster>>(
        future: _publicMonsters,
        builder: (context, snapshot) {
          // Estado de espera.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // Manejo de errores de conexión con Firebase.
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text("Error al conectar con el servidor: ${snapshot.error}"),
              ),
            );
          }
          
          final monsters = snapshot.data ?? [];
          
          // Lista vacía.
          if (monsters.isEmpty) {
            return Center(child: Text(l10n.noPublicCreatures));
          }

          // Listado de criaturas compartidas.
          return ListView.builder(
            itemCount: monsters.length,
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              final monster = monsters[index];
              return Card(
                child: ListTile(
                  title: Text(
                    monster.name ?? "Criatura sin nombre",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("CR ${monster.challengeRating} - ${monster.type}"),
                  // Botón lateral para descargar rápidamente la criatura.
                  trailing: IconButton(
                    icon: const Icon(Icons.download, color: Colors.blue),
                    onPressed: () async {
                      try {
                        await _storageService.saveMonster(monster);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.creatureSaved)),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error al descargar: $e")),
                          );
                        }
                      }
                    },
                    tooltip: l10n.download,
                  ),
                  onTap: () {
                    // Navega a la ficha técnica completa en modo lectura.
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MonsterDetailScreen(
                          monsterName: monster.name ?? "",
                          monster: monster,
                          showActions: false, // Desactiva edición/compartición desde el detalle público.
                          isPublicView: true,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
