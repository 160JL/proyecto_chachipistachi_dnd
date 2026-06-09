import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_chachipistachi_dnd/l10n/app_localizations.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/providers/battle_queue_provider.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/creature_search_delegate.dart';
import 'dart:io';

/// Muestra un diálogo unificado para añadir monstruos al combate.
/// Permite elegir desde la cola de batalla o buscar en el bestiario.
Future<void> showUnifiedAddMonsterDialog({
  required BuildContext context,
  required Function(Monster) onMonsterSelected,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final battleQueue = Provider.of<BattleQueueProvider>(context, listen: false);
  
  await showDialog(
    context: context,
    builder: (context) => _UnifiedAddMonsterDialog(
      l10n: l10n,
      battleQueue: battleQueue,
      onMonsterSelected: onMonsterSelected,
    ),
  );
}

class _UnifiedAddMonsterDialog extends StatefulWidget {
  final AppLocalizations l10n;
  final BattleQueueProvider battleQueue;
  final Function(Monster) onMonsterSelected;

  const _UnifiedAddMonsterDialog({
    required this.l10n,
    required this.battleQueue,
    required this.onMonsterSelected,
  });

  @override
  State<_UnifiedAddMonsterDialog> createState() => _UnifiedAddMonsterDialogState();
}

class _UnifiedAddMonsterDialogState extends State<_UnifiedAddMonsterDialog> {
  @override
  Widget build(BuildContext context) {
    final queuedMonsters = widget.battleQueue.queue;

    return AlertDialog(
      title: Text(widget.l10n.addToCombat),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECCIÓN: COLA DE BATALLA ---
              Text(
                widget.l10n.battleQueue,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (queuedMonsters.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    widget.l10n.emptyQueueMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                )
              else
                ...queuedMonsters.asMap().entries.map((entry) {
                  final m = entry.value;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: _getMonsterImage(m),
                    ),
                    title: Text(m.name ?? widget.l10n.noName),
                    subtitle: Text("${m.size} ${m.type}"),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        widget.battleQueue.removeFromQueue(entry.key);
                        setState(() {}); // Actualiza el diálogo
                      },
                    ),
                    onTap: () {
                      widget.onMonsterSelected(m);
                      Navigator.pop(context);
                    },
                  );
                }),
              const Divider(),
              // --- SECCIÓN: BÚSQUEDA ---
              ListTile(
                leading: const Icon(Icons.search, color: Colors.blue),
                title: const Text("Buscar en el Bestiario"),
                subtitle: const Text("API y Mis Criaturas"),
                onTap: () async {
                  Navigator.pop(context);
                  final Monster? selected = await showSearch<Monster?>(
                    context: context,
                    delegate: CreatureSearchDelegate(isBattleSimulator: true),
                  );
                  if (selected != null) {
                    widget.onMonsterSelected(selected);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (queuedMonsters.isNotEmpty)
          TextButton(
            onPressed: () {
              widget.battleQueue.clearQueue();
              setState(() {});
            },
            child: Text(
              widget.l10n.clearQueue,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.l10n.close),
        ),
      ],
    );
  }

  ImageProvider _getMonsterImage(Monster m) {
    if (m.image != null && m.image!.isNotEmpty) {
      if (m.image!.startsWith('http')) return NetworkImage(m.image!);
      if (m.image!.startsWith('/api')) {
        return NetworkImage("https://www.dnd5eapi.co${m.image}");
      }
      final file = File(m.image!);
      if (file.existsSync()) return FileImage(file);
    }
    return const AssetImage("assets/placeholder.png");
  }
}
