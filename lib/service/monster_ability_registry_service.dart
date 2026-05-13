import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/monster.dart';
import '../models/monster_ability_registry.dart';
import 'connection_service.dart';

/// Servicio encargado de construir, almacenar y consultar el registro
/// persistente de habilidades de criaturas de D&D 5e.
///
/// El registro se construye una sola vez descargando los detalles de todas
/// las criaturas de la API y extrayendo sus acciones, reacciones, acciones
/// legendarias y habilidades especiales. Se almacena en SharedPreferences
/// como una lista JSON para consultas rápidas posteriores.
class MonsterAbilityRegistryService {
  /// Clave booleana que indica si el registro ya fue construido y almacenado.
  static const String _registryBuiltKey = 'ability_registry_built';

  /// Clave donde se almacena el registro completo como cadena JSON.
  static const String _registryDataKey = 'ability_registry_data';

  /// Comprueba si el registro de habilidades ya fue construido previamente.
  ///
  /// Retorna `true` si el registro existe en SharedPreferences, `false` en caso contrario.
  Future<bool> isRegistryBuilt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_registryBuiltKey) ?? false;
  }

  /// Construye el registro de habilidades descargando los detalles de todas
  /// las criaturas disponibles en la API.
  ///
  /// [monsterUrls] — Lista de mapas con la información básica de cada criatura
  ///   (debe contener la clave `url` con la URL relativa del detalle).
  /// [onProgress] — Callback opcional que se invoca con (progreso_actual, total)
  ///   para permitir actualizar una barra de progreso en el UI.
  ///
  /// El proceso extrae de cada criatura sus acciones, reacciones, acciones
  /// legendarias y habilidades especiales, asociándolas con el CR de la criatura
  /// de origen. Finalmente, guarda todo el registro en SharedPreferences.
  Future<void> buildRegistry(
    List<Map<String, dynamic>> monsterUrls, {
    Function(int current, int total)? onProgress,
  }) async {
    final ConnectionService connectionService = ConnectionService();
    final List<AbilityRegistryEntry> registry = [];

    // Número total de criaturas a procesar para el cálculo de progreso.
    final int total = monsterUrls.length;

    for (int i = 0; i < total; i++) {
      final String url = monsterUrls[i]['url'] ?? '';
      if (url.isEmpty) continue;

      try {
        // Descarga los detalles completos de la criatura desde la API.
        final Monster monster = await connectionService.fetchMonsterDetail(url);

        // CR de la criatura actual, usado para etiquetar cada entrada del registro.
        final num cr = monster.challengeRating ?? 0;
        // Nombre de la criatura para trazabilidad de la entrada.
        final String monsterName = monster.name ?? 'Desconocido';

        // Extrae y registra todas las acciones de combate estándar.
        if (monster.actions != null) {
          for (final action in monster.actions!) {
            registry.add(AbilityRegistryEntry(
              name: action.name ?? '',
              desc: action.desc ?? '',
              category: 'action',
              challengeRating: cr,
              monsterName: monsterName,
            ));
          }
        }

        // Extrae y registra todas las reacciones de combate.
        if (monster.reactions != null) {
          for (final reaction in monster.reactions!) {
            registry.add(AbilityRegistryEntry(
              name: reaction.name ?? '',
              desc: reaction.desc ?? '',
              category: 'reaction',
              challengeRating: cr,
              monsterName: monsterName,
            ));
          }
        }

        // Extrae y registra todas las acciones legendarias.
        if (monster.legendaryActions != null) {
          for (final legendaryAction in monster.legendaryActions!) {
            registry.add(AbilityRegistryEntry(
              name: legendaryAction.name ?? '',
              desc: legendaryAction.desc ?? '',
              category: 'legendary_action',
              challengeRating: cr,
              monsterName: monsterName,
            ));
          }
        }

        // Extrae y registra todas las habilidades especiales / rasgos pasivos.
        if (monster.specialAbilities != null) {
          for (final ability in monster.specialAbilities!) {
            registry.add(AbilityRegistryEntry(
              name: ability.name ?? '',
              desc: ability.desc ?? '',
              category: 'special_ability',
              challengeRating: cr,
              monsterName: monsterName,
            ));
          }
        }
      } catch (e) {
        // Si falla la descarga de una criatura específica, la omitimos
        // y continuamos con las demás para no interrumpir el proceso completo.
        print('Error al procesar criatura en $url: $e');
      }

      // Notifica el progreso al callback (si fue proporcionado) para actualizar el UI.
      if (onProgress != null) {
        onProgress(i + 1, total);
      }
    }

    // Persiste el registro completo en SharedPreferences como cadena JSON.
    await _saveRegistry(registry);
  }

  /// Guarda la lista de entradas del registro en SharedPreferences y marca
  /// el flag de construcción como completado.
  Future<void> _saveRegistry(List<AbilityRegistryEntry> registry) async {
    final prefs = await SharedPreferences.getInstance();

    // Serializa todas las entradas a JSON.
    final String jsonData = jsonEncode(
      registry.map((entry) => entry.toJson()).toList(),
    );

    // Almacena el registro y marca el flag de completado.
    await prefs.setString(_registryDataKey, jsonData);
    await prefs.setBool(_registryBuiltKey, true);

    print('Registro de habilidades construido: ${registry.length} entradas.');
  }

  /// Recupera todas las entradas del registro desde SharedPreferences.
  ///
  /// Retorna una lista vacía si el registro aún no ha sido construido.
  Future<List<AbilityRegistryEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(_registryDataKey);

    if (jsonData == null) return [];

    // Deserializa la cadena JSON a una lista de objetos AbilityRegistryEntry.
    final List<dynamic> decoded = jsonDecode(jsonData);
    return decoded
        .map((e) => AbilityRegistryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Filtra las entradas del registro por categoría.
  ///
  /// [category] — Categoría a filtrar: `action`, `reaction`,
  ///   `legendary_action` o `special_ability`.
  ///
  /// Retorna solo las entradas que coincidan con la categoría indicada.
  Future<List<AbilityRegistryEntry>> getAbilitiesByCategory(
    String category,
  ) async {
    final List<AbilityRegistryEntry> all = await getAllEntries();
    return all.where((entry) => entry.category == category).toList();
  }

  /// Filtra las entradas del registro por un rango de Challenge Rating.
  ///
  /// [minCR] — CR mínimo (inclusive).
  /// [maxCR] — CR máximo (inclusive).
  ///
  /// Retorna las entradas cuyo CR esté dentro del rango especificado.
  Future<List<AbilityRegistryEntry>> getAbilitiesByCR(
    num minCR,
    num maxCR,
  ) async {
    final List<AbilityRegistryEntry> all = await getAllEntries();
    return all
        .where(
          (entry) =>
              entry.challengeRating >= minCR && entry.challengeRating <= maxCR,
        )
        .toList();
  }

  /// Filtra las entradas por categoría Y rango de CR simultáneamente.
  ///
  /// [category] — Categoría a filtrar.
  /// [minCR] — CR mínimo (inclusive).
  /// [maxCR] — CR máximo (inclusive).
  ///
  /// Combina ambos filtros para obtener habilidades relevantes al nivel
  /// de desafío deseado dentro de una categoría específica.
  Future<List<AbilityRegistryEntry>> getAbilitiesByCategoryAndCR(
    String category,
    num minCR,
    num maxCR,
  ) async {
    final List<AbilityRegistryEntry> all = await getAllEntries();
    return all
        .where(
          (entry) =>
              entry.category == category &&
              entry.challengeRating >= minCR &&
              entry.challengeRating <= maxCR,
        )
        .toList();
  }
}
