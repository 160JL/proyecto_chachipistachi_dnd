import 'package:flutter/material.dart';
import 'package:proyecto_chachipistachi_dnd/l10n/app_localizations.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/service/connection_service.dart';
import 'package:proyecto_chachipistachi_dnd/service/monster_storage_service.dart';
import 'dart:io';

/// Delegado de búsqueda para encontrar criaturas tanto en el repositorio local (Firestore/SP)
/// como en la API externa de D&D 5e.
class CreatureSearchDelegate extends SearchDelegate<Monster?> {
  /// Indica si la búsqueda se invoca desde el simulador de batalla.
  final bool isBattleSimulator;

  CreatureSearchDelegate({this.isBattleSimulator = false});

  @override
  String get searchFieldLabel => ""; // Se establece dinámicamente

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
        tooltip: AppLocalizations.of(context)!.clearSearch,
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
      tooltip: AppLocalizations.of(context)!.back,
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  /// Construye la lista de resultados combinando datos locales y remotos.
  Widget _buildSearchResults(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (query.isEmpty) {
      return Center(
        child: Text(
          l10n.typeCreatureName,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return FutureBuilder<List<dynamic>>(
      // Ejecutamos ambas búsquedas en paralelo para optimizar tiempo.
      future: Future.wait([
        MonsterStorageService().getMonsters(),
        ConnectionService().fetchEventos(name: query).then((list) => list.results ?? []),
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("${l10n.loading}: ${snapshot.error}"));
        }

        // Procesamos resultados locales (Mis Criaturas).
        final localMonsters = (snapshot.data?[0] as List<Monster>).where(
          (m) => (m.name ?? "").toLowerCase().contains(query.toLowerCase()),
        ).toList();
        
        // Procesamos resultados de la API.
        final apiMonsters = snapshot.data?[1] as List<Map<String, dynamic>>;

        return ListView(
          children: [
            if (localMonsters.isNotEmpty) ...[
              _SectionHeader(title: l10n.myCreaturesHeader),
              ...localMonsters.map((m) => _buildMonsterTile(context, m)),
            ],
            if (apiMonsters.isNotEmpty) ...[
              _SectionHeader(title: l10n.apiBestiaryHeader),
              ...apiMonsters.map((item) => _buildApiTile(context, item)),
            ],
            if (localMonsters.isEmpty && apiMonsters.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text(l10n.noMatchingCreatures),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Construye el elemento visual para un monstruo del repositorio local.
  Widget _buildMonsterTile(BuildContext context, Monster m) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: _buildLocalImage(m.image),
      title: Text(m.name ?? l10n.noName, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("${m.size} ${m.type} - CR ${m.challengeRating}"),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => close(context, m),
    );
  }

  /// Construye el elemento visual para un monstruo de la API.
  /// Al tocarlo, descarga los detalles completos antes de cerrar la búsqueda.
  Widget _buildApiTile(BuildContext context, Map<String, dynamic> item) {
    final l10n = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.public, color: Colors.blueGrey),
      title: Text(item["name"] ?? "???"),
      subtitle: Text(l10n.tapToLoadDetails),
      onTap: () async {
        // Mostramos un indicador de carga mientras descargamos la ficha completa.
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );
        try {
          final monster = await ConnectionService().fetchMonsterDetail(item["url"]);
          if (context.mounted) {
            Navigator.pop(context); // Cerramos el diálogo de carga.
            close(context, monster);
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context); // Cerramos carga.
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.errorLoadingCreature(e.toString()))),
            );
          }
        }
      },
    );
  }

  /// Resuelve y construye la imagen previa de la criatura.
  Widget _buildLocalImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return const Icon(Icons.pets);
    
    // Si es una URL o ruta de la API.
    if (imagePath.startsWith('http') || imagePath.startsWith('/api')) {
      final url = imagePath.startsWith('http') ? imagePath : "https://www.dnd5eapi.co$imagePath";
      return CircleAvatar(backgroundImage: NetworkImage(url));
    }
    
    // Si es un archivo local del dispositivo.
    final file = File(imagePath);
    if (file.existsSync()) return CircleAvatar(backgroundImage: FileImage(file));
    
    return const Icon(Icons.pets);
  }
}

/// Widget interno para separar visualmente las secciones de resultados.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
