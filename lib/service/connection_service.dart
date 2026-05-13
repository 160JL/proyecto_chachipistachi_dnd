import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio encargado de gestionar las peticiones de red y la persistencia local.
class ConnectionService {
  // URL base para todas las llamadas a la API de D&D 5e.
  static const String baseUrl = "https://www.dnd5eapi.co";
  
  // Clave utilizada para guardar la lista de monstruos en Shared Preferences.
  static const String monsterListKey = "monster_list_cache";

  /// Obtiene la lista de monstruos. 
  /// 
  /// Si [forceRefresh] es true, ignora la caché local y descarga desde la API.
  /// Si es false (por defecto), intenta cargar primero desde el almacenamiento local.
  Future<MonsterList> fetchEventos({bool forceRefresh = false}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Si no forzamos actualización, intentamos recuperar los datos del dispositivo.
    if (!forceRefresh) {
      final String? cachedData = prefs.getString(monsterListKey);
      if (cachedData != null) {
        print('Cargando lista de monstruos desde caché local');
        // Decodificamos el JSON guardado y lo devolvemos como objeto MonsterList.
        return MonsterList.fromJson(jsonDecode(cachedData));
      }
    }

    // Si no hay datos guardados o queremos actualizar, hacemos la petición HTTP.
    try {
      print('Consultando API para obtener lista de monstruos');
      final response = await http.get(
        Uri.parse("$baseUrl/api/monsters"),
      );

      // Comprobamos si la respuesta del servidor es correcta.
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        // Almacenamos el JSON crudo en el almacenamiento local para la próxima vez.
        await prefs.setString(monsterListKey, response.body);
        
        return MonsterList.fromJson(data);
      } else {
        // Log de error en servidor (ej: 404, 500).
        print('Error de servidor: ${response.statusCode}');
        throw Exception('Error al cargar los Eventos: ${response.statusCode}');
      }
    } catch (e) {
      // Log de error en la conexión (ej: sin internet).
      print('Error en la conexión: $e');
      rethrow; // Propagamos el error para que la UI pueda manejarlo.
    }
  }

  /// Obtiene los detalles completos de un monstruo específico.
  /// 
  /// Recibe la [relativeUrl] proporcionada por la lista de monstruos
  /// (ejemplo: '/api/monsters/aboleth').
  Future<Monster> fetchMonsterDetail(String relativeUrl) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl$relativeUrl"),
      );

      // Comprobamos si la respuesta es exitosa.
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Retornamos el modelo completo de la criatura.
        return Monster.fromJson(data);
      } else {
        print('Error de servidor al obtener detalle: ${response.statusCode}');
        throw Exception('Error al cargar el detalle del monstruo: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la conexión de detalle: $e');
      rethrow;
    }
  }
}
