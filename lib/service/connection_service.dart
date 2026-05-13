import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio encargado de gestionar las peticiones de red y la persistencia local.
class ConnectionService {
  // URL base para todas las llamadas a la API de D&D 5e.
  static const String baseUrl = "https://www.dnd5eapi.co";
  
  // Clave base utilizada para guardar la lista de monstruos en Shared Preferences.
  static const String monsterListKey = "monster_list_cache";

  // Cache en memoria para evitar peticiones repetidas de detalles de monstruos.
  // Es estático para que persista entre diferentes instancias del servicio.
  static final Map<String, Monster> _monsterCache = {};

  /// Obtiene la lista de monstruos con soporte para filtros.
  ///
  /// [forceRefresh]: Si es true, ignora la caché y descarga de nuevo.
  /// [name], [type], [size]: Parámetros para filtrar la búsqueda.
  Future<MonsterList> fetchEventos({
    bool forceRefresh = false,
    String? name,
    String? type,
    String? size,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Cacheamos la lista base filtrada solo por nombre (o sin filtros) para eficiencia.
    // El filtrado por tipo y tamaño se hará localmente como se solicitó.
    final String cacheKey = "${monsterListKey}_${name ?? ""}";

    MonsterList monsterList;
    if (!forceRefresh) {
      final String? cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        print('Cargando lista base desde caché local');
        monsterList = MonsterList.fromJson(jsonDecode(cachedData));
      } else {
        monsterList = await _fetchBaseMonsterList(name);
        await prefs.setString(cacheKey, jsonEncode(monsterList.toJson()));
      }
    } else {
      monsterList = await _fetchBaseMonsterList(name);
      await prefs.setString(cacheKey, jsonEncode(monsterList.toJson()));
    }

    // Filtrado local por tipo y tamaño.
    // Se realiza localmente porque el listado de la API solo trae nombre y URL,
    // y queremos aprovechar los detalles que ya estamos obteniendo.
    if ((type != null && type != "Todos") || (size != null && size != "Todos")) {
      print('Aplicando filtrado local: tipo=$type, tamaño=$size');
      final results = monsterList.results ?? [];
      
      // Obtenemos los detalles de todos los candidatos en paralelo para poder filtrar.
      // Esto aprovecha y puebla el caché que usan las tarjetas (ListTile).
      final List<Monster> detailedMonsters = await Future.wait(
        results.map((m) => fetchMonsterDetail(m['url'].toString()))
      );

      final List<Map<String, dynamic>> filteredResults = [];
      for (int i = 0; i < results.length; i++) {
        final detail = detailedMonsters[i];
        
        // Comprobación de tipo (la API suele devolverlo en minúsculas).
        bool matchType = (type == null || type == "Todos") || 
                         (detail.type?.toLowerCase() == type.toLowerCase());
        
        // Comprobación de tamaño.
        bool matchSize = (size == null || size == "Todos") || 
                         (detail.size == size);

        if (matchType && matchSize) {
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

  /// Obtiene la lista base de monstruos (index, name, url) desde la API.
  Future<MonsterList> _fetchBaseMonsterList(String? name) async {
    var queryParams = <String, String>{};
    if (name != null && name.isNotEmpty) queryParams['name'] = name;

    var uri = Uri.parse("$baseUrl/api/monsters").replace(queryParameters: queryParams);
    print('Consultando lista base API: $uri');
    
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return MonsterList.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Error de servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la conexión: $e');
      rethrow;
    }
  }

  /// Obtiene los detalles completos de un monstruo específico, con soporte de caché.
  Future<Monster> fetchMonsterDetail(String relativeUrl) async {
    if (_monsterCache.containsKey(relativeUrl)) {
      return _monsterCache[relativeUrl]!;
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl$relativeUrl"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final monster = Monster.fromJson(data);
        _monsterCache[relativeUrl] = monster; // Guardamos en caché para futuros usos.
        return monster;
      } else {
        print('Error de servidor al obtener detalle: ${response.statusCode}');
        throw Exception('Error al cargar el detalle del monstruo');
      }
    } catch (e) {
      print('Error en la conexión de detalle: $e');
      rethrow;
    }
  }
}
