import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/monster.dart';
import '../models/monster_ability_registry.dart';
import 'connection_service.dart';

/// Servicio encargado de construir, almacenar y consultar el registro
/// persistente de habilidades de criaturas de D&D 5e.
class MonsterAbilityRegistryService {
  /// Clave booleana que indica si el registro ya fue construido.
  static const String _registryBuiltKey = 'ability_registry_built';

  /// Clave donde se almacena el registro completo como cadena JSON.
  static const String _registryDataKey = 'ability_registry_data';

  /// Clave que almacena el UID del usuario que generó el registro por última vez.
  static const String _registryUidKey = 'ability_registry_uid';

  /// Comprueba si el registro de habilidades ya fue construido previamente.
  Future<bool> isRegistryBuilt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_registryBuiltKey) ?? false;
  }

  /// Retorna el UID asociado al registro actual.
  Future<String?> getRegistryUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_registryUidKey);
  }

  /// Verifica si el registro actual pertenece al usuario identificado.
  /// Retorna true si el UID coincide, false si es de otro usuario.
  Future<bool> isRegistryConsistentWithUser(String? uid) async {
    final String? storedUid = await getRegistryUid();
    // Si no hay UID guardado pero el registro existe (v0.8.0), asumimos inconsistente por seguridad.
    if (storedUid == null) return false;
    return storedUid == (uid ?? "guest");
  }

  /// Construye el registro de habilidades procesando la API y el repositorio local.
  Future<void> buildRegistry(
    List<Map<String, dynamic>> monsterUrls, {
    List<Monster>? localMonsters,
    Function(int current, int total)? onProgress,
  }) async {
    final ConnectionService connectionService = ConnectionService();
    final List<AbilityRegistryEntry> registry = [];

    // Marcar como NO construido mientras se procesa
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_registryBuiltKey, false);

    final int apiCount = monsterUrls.length;
    final int localCount = localMonsters?.length ?? 0;
    final int total = apiCount + localCount;

    // 1. Procesar API
    for (int i = 0; i < apiCount; i++) {
      final String url = monsterUrls[i]['url'] ?? '';
      if (url.isEmpty) continue;

      try {
        final Monster monster = await connectionService.fetchMonsterDetail(url);
        _extractAbilities(monster, registry, isLocal: false);
      } catch (e) {
        debugPrint('Error al procesar criatura API en $url: $e');
      }

      if (onProgress != null) onProgress(i + 1, total);
    }

    // 2. Procesar Locales
    if (localMonsters != null) {
      for (int i = 0; i < localCount; i++) {
        _extractAbilities(localMonsters[i], registry, isLocal: true);
        if (onProgress != null) onProgress(apiCount + i + 1, total);
      }
    }

    // Persiste el registro completo
    await _saveRegistry(registry);
  }

  /// Helper privado para extraer habilidades de un objeto Monster e insertarlas en la lista.
  void _extractAbilities(Monster monster, List<AbilityRegistryEntry> targetList, {required bool isLocal}) {
    final num cr = monster.challengeRating ?? 0;
    final String monsterName = monster.name ?? 'Desconocido';

    if (monster.actions != null) {
      for (final action in monster.actions!) {
        targetList.add(AbilityRegistryEntry(
          name: action.name ?? '',
          desc: action.desc ?? '',
          category: 'action',
          challengeRating: cr,
          monsterName: monsterName,
          isLocal: isLocal,
        ));
      }
    }

    if (monster.reactions != null) {
      for (final reaction in monster.reactions!) {
        targetList.add(AbilityRegistryEntry(
          name: reaction.name ?? '',
          desc: reaction.desc ?? '',
          category: 'reaction',
          challengeRating: cr,
          monsterName: monsterName,
          isLocal: isLocal,
        ));
      }
    }

    if (monster.legendaryActions != null) {
      for (final legendaryAction in monster.legendaryActions!) {
        targetList.add(AbilityRegistryEntry(
          name: legendaryAction.name ?? '',
          desc: legendaryAction.desc ?? '',
          category: 'legendary_action',
          challengeRating: cr,
          monsterName: monsterName,
          isLocal: isLocal,
        ));
      }
    }

    if (monster.specialAbilities != null) {
      for (final ability in monster.specialAbilities!) {
        targetList.add(AbilityRegistryEntry(
          name: ability.name ?? '',
          desc: ability.desc ?? '',
          category: 'special_ability',
          challengeRating: cr,
          monsterName: monsterName,
          isLocal: isLocal,
        ));
      }
    }
  }

  /// Guarda la lista de entradas y marca el flag como completado, asociando el UID actual.
  Future<void> _saveRegistry(List<AbilityRegistryEntry> registry) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(registry.map((entry) => entry.toJson()).toList());

    final String? currentUid = FirebaseAuth.instance.currentUser?.uid ?? "guest";

    await prefs.setString(_registryDataKey, jsonData);
    await prefs.setString(_registryUidKey, currentUid!);
    await prefs.setBool(_registryBuiltKey, true);

    debugPrint('Registro de habilidades completado: ${registry.length} entradas para el usuario $currentUid.');
  }

  /// Borra el registro actual de habilidades.
  Future<void> clearRegistry() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_registryDataKey);
    await prefs.remove(_registryUidKey);
    await prefs.setBool(_registryBuiltKey, false);
  }

  /// Añade habilidades de una sola criatura al registro existente (marcada como local).
  Future<void> addMonsterToRegistry(Monster monster) async {
    final List<AbilityRegistryEntry> newEntries = [];
    _extractAbilities(monster, newEntries, isLocal: true);
    if (newEntries.isNotEmpty) {
      await addEntriesFromMonster(newEntries);
    }
  }

  /// Añade nuevas entradas al registro existente, evitando duplicados.
  Future<void> addEntriesFromMonster(List<AbilityRegistryEntry> newEntries) async {
    final List<AbilityRegistryEntry> existing = await getAllEntries();
    int addedCount = 0;

    for (final entry in newEntries) {
      if (entry.name.isEmpty) continue;

      final bool isDuplicate = existing.any(
        (e) => e.name == entry.name && e.challengeRating == entry.challengeRating,
      );

      if (!isDuplicate) {
        existing.add(entry);
        addedCount++;
      }
    }

    if (addedCount > 0) {
      await _saveRegistry(existing);
    }
  }

  /// Actualiza SOLAMENTE las entradas locales. Útil al cambiar de usuario sin borrar la API.
  Future<void> updateLocalEntriesOnly(List<Monster> localMonsters) async {
    // 1. Obtener todas las entradas actuales
    final List<AbilityRegistryEntry> allEntries = await getAllEntries();
    
    // 2. Filtrar y mantener solo las que NO son locales (las de la API oficial)
    final List<AbilityRegistryEntry> apiOnlyEntries = allEntries.where((e) => !e.isLocal).toList();
    
    // 3. Procesar las nuevas criaturas locales
    for (final monster in localMonsters) {
      _extractAbilities(monster, apiOnlyEntries, isLocal: true);
    }
    
    // 4. Guardar el nuevo registro mixto
    await _saveRegistry(apiOnlyEntries);
    debugPrint('Actualización parcial completada: se han regenerado las habilidades de las criaturas locales del nuevo usuario.');
  }

  /// Recupera todas las entradas del registro.
  Future<List<AbilityRegistryEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(_registryDataKey);
    if (jsonData == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonData);
    return decoded.map((e) => AbilityRegistryEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Filtra las entradas del registro por categoría.
  Future<List<AbilityRegistryEntry>> getAbilitiesByCategory(String category) async {
    final List<AbilityRegistryEntry> all = await getAllEntries();
    return all.where((entry) => entry.category == category).toList();
  }

  /// Filtra las entradas del registro por un rango de CR.
  Future<List<AbilityRegistryEntry>> getAbilitiesByCR(num minCR, num maxCR) async {
    final List<AbilityRegistryEntry> all = await getAllEntries();
    return all.where((entry) => entry.challengeRating >= minCR && entry.challengeRating <= maxCR).toList();
  }

  /// Filtra las entradas por categoría Y rango de CR.
  Future<List<AbilityRegistryEntry>> getAbilitiesByCategoryAndCR(String category, num minCR, num maxCR) async {
    final List<AbilityRegistryEntry> all = await getAllEntries();
    return all.where((entry) => entry.category == category && entry.challengeRating >= minCR && entry.challengeRating <= maxCR).toList();
  }
}
