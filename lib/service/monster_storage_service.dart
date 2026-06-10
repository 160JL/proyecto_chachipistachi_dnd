import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/monster.dart';

/// Servicio encargado de la persistencia de datos de criaturas creadas por el usuario.
/// Implementa un sistema de almacenamiento híbrido:
/// 1. Firestore (Nube): Para sincronización entre dispositivos y repositorio público.
/// 2. SharedPreferences (Local): Como respaldo y para funcionamiento offline.
class MonsterStorageService {
  static const String _storageKey = 'local_monsters';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Obtiene el Identificador Único del usuario autenticado.
  String? get _uid => _auth.currentUser?.uid;

  /// Referencia a la colección personal de monstruos del usuario en Firestore.
  CollectionReference? get _userMonsters {
    if (_uid == null) return null;
    return _firestore.collection('users').doc(_uid).collection('monsters');
  }

  /// Guarda una nueva criatura tanto en la nube (Firestore) como en local (SP).
  Future<void> saveMonster(Monster monster) async {
    // 1. Aseguramos que la criatura tenga un identificador local único.
    monster.localId ??= DateTime.now().millisecondsSinceEpoch.toString();

    // 2. Persistencia en la nube si el usuario está autenticado.
    if (_userMonsters != null) {
      await _userMonsters!.doc(monster.localId).set(monster.toJson());
    }

    // 3. Persistencia local (JSON en SharedPreferences).
    final prefs = await SharedPreferences.getInstance();
    final List<String> monstersJson = prefs.getStringList(_storageKey) ?? [];
    monstersJson.add(jsonEncode(monster.toJson()));
    await prefs.setStringList(_storageKey, monstersJson);
  }

  /// Comparte una criatura en el repositorio público de la comunidad.
  /// Añade metadatos del autor y fecha de publicación.
  /// Si la imagen es una ruta local, se elimina antes de subir para evitar enlaces rotos.
  Future<void> shareMonsterPublicly(Monster monster) async {
    final publicCollection = _firestore.collection('public_monsters');
    
    final data = monster.toJson();

    // Lógica para filtrar imágenes locales
    String? imagePath = data['image'];
    if (imagePath != null && imagePath.isNotEmpty) {
      bool isWebImage = imagePath.startsWith('http') || imagePath.startsWith('/api');
      if (!isWebImage) {
        data['image'] = null; // Eliminamos ruta local
      }
    }

    data['sharedBy'] = _auth.currentUser?.displayName ?? "Anónimo";
    data['sharedByUid'] = _uid;
    data['sharedAt'] = FieldValue.serverTimestamp(); // Sello de tiempo del servidor.

    // Usamos el ID local para evitar duplicados si el usuario pulsa varias veces.
    await publicCollection.doc(monster.localId).set(data);
  }

  /// Recupera todas las criaturas compartidas por la comunidad, ordenadas por fecha.
  Future<List<Monster>> getPublicMonsters() async {
    final snapshot = await _firestore.collection('public_monsters')
        .orderBy('sharedAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      return Monster.fromJson(doc.data());
    }).toList();
  }

  /// Actualiza los datos de una criatura existente en ambos almacenamientos.
  Future<void> updateMonster(int index, Monster monster) async {
    monster.localId ??= DateTime.now().millisecondsSinceEpoch.toString();

    // 1. Actualización en SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    final List<String> monstersJson = prefs.getStringList(_storageKey) ?? [];
    if (index >= 0 && index < monstersJson.length) {
      monstersJson[index] = jsonEncode(monster.toJson());
      await prefs.setStringList(_storageKey, monstersJson);
    }

    // 2. Actualización en Firestore.
    if (_userMonsters != null) {
      await _userMonsters!.doc(monster.localId).set(monster.toJson());
    }
  }

  /// Recupera la lista completa de criaturas del usuario.
  /// Prioriza Firestore (si hay conexión) y usa SharedPreferences como fallback.
  Future<List<Monster>> getMonsters() async {
    if (_userMonsters != null) {
      try {
        final snapshot = await _userMonsters!.get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs.map((doc) {
            return Monster.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();
        }
      } catch (e) {
        debugPrint("Aviso: No se pudo recuperar de Firestore (offline?). Usando local.");
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String> monstersJson = prefs.getStringList(_storageKey) ?? [];
    return monstersJson.map((m) => Monster.fromJson(jsonDecode(m))).toList();
  }

  /// Elimina una criatura de ambos almacenamientos.
  Future<void> deleteMonster(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> monstersJson = prefs.getStringList(_storageKey) ?? [];

    if (index >= 0 && index < monstersJson.length) {
      final monsterToDelete = Monster.fromJson(jsonDecode(monstersJson[index]));
      
      // 1. Eliminación en Firestore.
      if (_userMonsters != null && monsterToDelete.localId != null) {
        await _userMonsters!.doc(monsterToDelete.localId).delete();
      }

      // 2. Eliminación en SharedPreferences.
      monstersJson.removeAt(index);
      await prefs.setStringList(_storageKey, monstersJson);
    }
  }

  /// Registra un reporte de una criatura pública en Firestore.
  /// También crea un documento en la colección 'mail' para disparar una notificación por correo.
  Future<void> reportMonster(Monster monster, String reason) async {
    final reportId = DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = FieldValue.serverTimestamp();

    // 1. Guardar el reporte detallado
    await _firestore.collection('reports').doc(reportId).set({
      'monsterId': monster.localId,
      'monsterName': monster.name,
      'reporterUid': _uid ?? 'guest',
      'reason': reason,
      'timestamp': timestamp,
    });

    // 2. Crear documento de correo para la extensión 'Trigger Email'
    await _firestore.collection('mail').add({
      'to': 'admin@chachipistachi.dnd', // Reemplazar con el correo del admin real
      'message': {
        'subject': 'NUEVO REPORTE DE CRIATURA: ${monster.name}',
        'text': 'Se ha reportado la criatura "${monster.name}" (ID: ${monster.localId}).\n\nMotivo del reporte:\n$reason\n\nReportado por: ${_uid ?? "Invitado"}',
      },
    });
  }
}
