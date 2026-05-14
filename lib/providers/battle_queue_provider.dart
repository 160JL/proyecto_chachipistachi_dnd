import 'package:flutter/material.dart';
import '../models/monster.dart';

/// Provider para gestionar una lista temporal de criaturas preparadas para el combate.
/// La lista se mantiene en memoria y se borra al cerrar la aplicación.
class BattleQueueProvider with ChangeNotifier {
  final List<Monster> _queue = [];

  List<Monster> get queue => List.unmodifiable(_queue);

  /// Añade una criatura a la cola de batalla.
  void addToQueue(Monster monster) {
    // Evitamos duplicados exactos comparando el nombre e index
    bool exists = _queue.any((m) => m.name == monster.name && m.index == monster.index);

    if (!exists) {
      _queue.add(monster);
      notifyListeners();
    }
  }

  /// Elimina una criatura de la cola por su índice.
  void removeFromQueue(int index) {
    if (index >= 0 && index < _queue.length) {
      _queue.removeAt(index);
      notifyListeners();
    }
  }

  /// Limpia toda la cola de batalla.
  void clearQueue() {
    _queue.clear();
    notifyListeners();
  }
}
