import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/monster.dart';

/// Servicio encargado de la persistencia de datos de criaturas creadas por el usuario.
/// Utiliza SharedPreferences para almacenar objetos Monster en formato JSON.
class MonsterStorageService {
  // Clave única para el almacenamiento de la lista de monstruos locales.
  static const String _storageKey = 'local_monsters';

  /// Guarda una nueva criatura en la lista local persistente.
  ///
  /// Convierte el objeto [Monster] a JSON antes de añadirlo a la lista.
  Future<void> saveMonster(Monster monster) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> monstersJson = prefs.getStringList(_storageKey) ?? [];

    // Convertimos el monstruo a cadena JSON mediante su método toJson.
    final monsterJson = jsonEncode(monster.toJson());
    monstersJson.add(monsterJson);

    // Guardamos la lista actualizada en SharedPreferences.
    await prefs.setStringList(_storageKey, monstersJson);
  }

  /// Actualiza una criatura existente en una posición específica de la lista.
  Future<void> updateMonster(int index, Monster monster) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> monstersJson = prefs.getStringList(_storageKey) ?? [];

    if (index >= 0 && index < monstersJson.length) {
      monstersJson[index] = jsonEncode(monster.toJson());
      await prefs.setStringList(_storageKey, monstersJson);
    }
  }

  /// Recupera todas las criaturas guardadas en el repositorio local.
  ///
  /// Retorna una lista de objetos [Monster] reconstruidos desde el JSON almacenado.
  Future<List<Monster>> getMonsters() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> monstersJson = prefs.getStringList(_storageKey) ?? [];

    return monstersJson.map((m) => Monster.fromJson(jsonDecode(m))).toList();
  }

  /// Elimina una criatura de la lista local basándose en su posición (index).
  Future<void> deleteMonster(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> monstersJson = prefs.getStringList(_storageKey) ?? [];

    if (index >= 0 && index < monstersJson.length) {
      monstersJson.removeAt(index);
      await prefs.setStringList(_storageKey, monstersJson);
    }
  }
}
