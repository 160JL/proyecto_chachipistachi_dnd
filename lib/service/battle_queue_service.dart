import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/monster.dart';

/// Servicio para gestionar una lista temporal de criaturas preparadas para el combate.
/// Permite pre-seleccionar monstruos desde la API o el repositorio para añadirlos rápidamente al tablero.
class BattleQueueService {
  static const String _storageKey = 'battle_queue_monsters';

  /// Añade una criatura a la cola de batalla.
  Future<void> addToQueue(Monster monster) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> queueJson = prefs.getStringList(_storageKey) ?? [];

    // Evitamos duplicados exactos comparando el nombre o index si existe
    bool exists = queueJson.any((mJson) {
      final m = Monster.fromJson(jsonDecode(mJson));
      return m.name == monster.name && m.index == monster.index;
    });

    if (!exists) {
      queueJson.add(jsonEncode(monster.toJson()));
      await prefs.setStringList(_storageKey, queueJson);
    }
  }

  /// Recupera todas las criaturas en la cola de batalla.
  Future<List<Monster>> getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> queueJson = prefs.getStringList(_storageKey) ?? [];
    return queueJson.map((m) => Monster.fromJson(jsonDecode(m))).toList();
  }

  /// Elimina una criatura de la cola por su índice.
  Future<void> removeFromQueue(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> queueJson = prefs.getStringList(_storageKey) ?? [];
    if (index >= 0 && index < queueJson.length) {
      queueJson.removeAt(index);
      await prefs.setStringList(_storageKey, queueJson);
    }
  }

  /// Limpia toda la cola de batalla.
  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
