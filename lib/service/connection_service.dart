import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio encargado de gestionar las peticiones de red a la API de D&D 5e y la caché local.
class ConnectionService {
  // URL base para todas las llamadas a la API de D&D 5e.
  static const String baseUrl = "https://www.dnd5eapi.co";

  // Clave base utilizada para guardar la lista de monstruos en Shared Preferences (Caché persistente).
  static const String monsterListKey = "monster_list_cache";

  // Cache en memoria para evitar peticiones repetidas de detalles de monstruos durante la sesión.
  static final Map<String, Monster> _monsterCache = {};

  /// Obtiene la lista de monstruos con soporte para filtros avanzados.
  ///
  /// [forceRefresh]: Si es true, ignora la caché local y descarga los datos de nuevo.
  /// [name], [type], [size], [alignment], [vulnerability], [resistance], [immunity]:
  /// Parámetros utilizados para filtrar la búsqueda.
  Future<MonsterList> fetchEventos({
    bool forceRefresh = false,
    String? name,
    String? type,
    String? size,
    String? alignment,
    String? vulnerability,
    String? resistance,
    String? immunity,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Se genera una clave de caché única basada en la búsqueda por nombre.
    final String cacheKey = "${monsterListKey}_${name ?? ""}";

    MonsterList monsterList;
    // Lógica de recuperación de caché persistente.
    if (!forceRefresh) {
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        monsterList = MonsterList.fromJson(jsonDecode(cachedData));
      } else {
        monsterList = await _fetchBaseMonsterList(name);
        await prefs.setString(cacheKey, jsonEncode(monsterList.toJson()));
      }
    } else {
      monsterList = await _fetchBaseMonsterList(name);
      await prefs.setString(cacheKey, jsonEncode(monsterList.toJson()));
    }

    // Comprueba si se han aplicado filtros que requieren inspeccionar los detalles del monstruo.
    bool hasAdvancedFilters =
        (type != null && type != "Todos") ||
        (size != null && size != "Todos") ||
        (alignment != null && alignment != "Todos") ||
        (vulnerability != null && vulnerability != "Todos") ||
        (resistance != null && resistance != "Todos") ||
        (immunity != null && immunity != "Todos");

    if (hasAdvancedFilters) {
      print('Aplicando filtrado local avanzado sobre resultados de la API');
      final results = monsterList.results ?? [];

      // Descarga los detalles de todos los monstruos de la lista para poder filtrar por sus atributos internos.
      final List<Monster> detailedMonsters = await Future.wait(
        results.map((m) => fetchMonsterDetail(m['url'].toString())),
      );

      final List<Map<String, dynamic>> filteredResults = [];
      for (int i = 0; i < results.length; i++) {
        final detail = detailedMonsters[i];

        // Comprobaciones de coincidencia para cada filtro activo.
        bool matchType =
            (type == null || type == "Todos") ||
            (detail.type?.toLowerCase() == type.toLowerCase());
        bool matchSize =
            (size == null || size == "Todos") || (detail.size == size);
        bool matchAlign =
            (alignment == null || alignment == "Todos") ||
            (detail.alignment?.toLowerCase().contains(
                  alignment.toLowerCase(),
                ) ??
                false);

        // Función auxiliar para comprobar múltiples valores en una lista (ej: varias inmunidades).
        bool _matchMulti(String? filterValue, List<String>? monsterValues) {
          if (filterValue == null || filterValue == "Todos") return true;
          List<String> required = filterValue
              .split(',')
              .map((e) => e.trim().toLowerCase())
              .toList();
          if (monsterValues == null || monsterValues.isEmpty) return false;
          List<String> available = monsterValues
              .map((e) => e.toLowerCase())
              .toList();
          // Lógica AND: la criatura debe poseer TODAS las propiedades seleccionadas en el filtro.
          return required.every(
            (req) => available.any((avail) => avail.contains(req)),
          );
        }

        bool matchVuln = _matchMulti(
          vulnerability,
          detail.damageVulnerabilities,
        );
        bool matchRes = _matchMulti(resistance, detail.damageResistances);
        bool matchImm = _matchMulti(immunity, detail.damageImmunities);

        if (matchType &&
            matchSize &&
            matchAlign &&
            matchVuln &&
            matchRes &&
            matchImm) {
          filteredResults.add(results[i]);
        }
      }

      return MonsterList(
        count: filteredResults.length,
        results: filteredResults,
      );
    }

    return monsterList;
  }

  /// Realiza la petición HTTP básica a la API para obtener la lista (nombre y URL) de monstruos.
  Future<MonsterList> _fetchBaseMonsterList(String? name) async {
    var queryParams = <String, String>{};
    if (name != null && name.isNotEmpty) queryParams['name'] = name;

    var uri = Uri.parse(
      "$baseUrl/api/monsters",
    ).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return MonsterList.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error de servidor: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene los detalles completos de una criatura por su URL relativa. Implementa caché en memoria.
  Future<Monster> fetchMonsterDetail(String relativeUrl) async {
    if (_monsterCache.containsKey(relativeUrl)) {
      return _monsterCache[relativeUrl]!;
    }

    try {
      final response = await http.get(Uri.parse("$baseUrl$relativeUrl"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final monster = Monster.fromJson(data);
        _monsterCache[relativeUrl] =
            monster; // Guardamos en caché para evitar descargas duplicadas.
        return monster;
      } else {
        throw Exception('Error al cargar el detalle del monstruo');
      }
    } catch (e) {
      rethrow;
    }
  }
}
