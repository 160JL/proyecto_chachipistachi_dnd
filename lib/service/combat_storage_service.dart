import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/combat.dart';

/// Servicio encargado de la persistencia y recuperación de sesiones de combate.
/// Utiliza Firestore como repositorio principal en la nube para permitir la
/// continuidad entre dispositivos y SharedPreferences para acceso rápido local.
class CombatStorageService {
  static const String _storageKey = 'combat_sessions';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtiene el UID del usuario actual.
  String? get _uid => _auth.currentUser?.uid;

  /// Referencia a la colección 'combats' dentro del documento del usuario.
  CollectionReference? get _userCombats {
    if (_uid == null) return null;
    return _firestore.collection('users').doc(_uid).collection('combats');
  }

  /// Guarda o actualiza una sesión de combate íntegra.
  /// Se ejecuta automáticamente cada vez que cambia un HP, iniciativa o participante.
  Future<void> saveSession(CombatSession session) async {
    // 1. Persistencia en la nube (Firestore).
    if (_userCombats != null) {
      await _userCombats!.doc(session.id).set(session.toJson());
    }

    // 2. Persistencia local para modo offline y velocidad de carga inicial.
    final prefs = await SharedPreferences.getInstance();
    final List<CombatSession> sessions = await getSessionsLocal();

    int index = sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }

    final List<String> sessionsJson = sessions
        .map((s) => jsonEncode(s.toJson()))
        .toList();
    await prefs.setStringList(_storageKey, sessionsJson);
  }

  /// Recupera todas las sesiones de combate activas del usuario.
  /// Sincroniza desde la nube prioritariamente.
  Future<List<CombatSession>> getSessions() async {
    if (_userCombats != null) {
      try {
        final snapshot = await _userCombats!.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            return CombatSession.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();
        }
      } catch (e) {
        print("Error al sincronizar combates desde Firebase: $e");
      }
    }
    // Si falla la nube, retorna lo que tenga guardado en el dispositivo.
    return getSessionsLocal();
  }

  /// Lee exclusivamente del almacenamiento local (SharedPreferences).
  Future<List<CombatSession>> getSessionsLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> sessionsJson = prefs.getStringList(_storageKey) ?? [];
    return sessionsJson
        .map((s) => CombatSession.fromJson(jsonDecode(s)))
        .toList();
  }

  /// Elimina definitivamente una sesión de combate por su identificador.
  Future<void> deleteSession(String id) async {
    // 1. Borrado en la nube.
    if (_userCombats != null) {
      await _userCombats!.doc(id).delete();
    }

    // 2. Borrado local.
    final sessions = await getSessionsLocal();
    sessions.removeWhere((s) => s.id == id);

    final List<String> sessionsJson = sessions
        .map((s) => jsonEncode(s.toJson()))
        .toList();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, sessionsJson);
  }
}
