import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/combat.dart';

/// Servicio encargado de persistir y recuperar sesiones de combate usando SharedPreferences.
class CombatStorageService {
  // Clave para almacenar la lista de sesiones en formato JSON.
  static const String _storageKey = 'combat_sessions';

  /// Guarda o actualiza una sesión de combate en el almacenamiento local.
  ///
  /// Si la sesión ya existe (por ID), la reemplaza; si no, la añade a la lista.
  Future<void> saveSession(CombatSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final List<CombatSession> sessions = await getSessions();

    int index = sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }

    // Convertimos la lista de objetos a una lista de cadenas JSON.
    final List<String> sessionsJson = sessions
        .map((s) => jsonEncode(s.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, sessionsJson);
  }

  /// Recupera todas las sesiones de combate guardadas.
  ///
  /// Devuelve una lista de objetos [CombatSession].
  Future<List<CombatSession>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> sessionsJson = prefs.getStringList(_storageKey) ?? [];
    return sessionsJson
        .map((s) => CombatSession.fromJson(jsonDecode(s)))
        .toList();
  }

  /// Elimina una sesión de combate del almacenamiento por su identificador.
  Future<void> deleteSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<CombatSession> sessions = await getSessions();

    // Eliminamos la sesión que coincida con el ID proporcionado.
    sessions.removeWhere((s) => s.id == id);

    final List<String> sessionsJson = sessions
        .map((s) => jsonEncode(s.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, sessionsJson);
  }
}
