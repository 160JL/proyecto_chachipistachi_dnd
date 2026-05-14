import 'monster.dart';

/// Representa a un participante individual en un combate, ya sea un jugador o un monstruo.
class Participant {
  final String id; // Identificador único del participante
  String name; // Nombre mostrado
  String? image; // Ruta o URL de la imagen
  int currentHp; // Puntos de vida actuales
  int maxHp; // Puntos de vida máximos
  int temporaryHp; // Puntos de vida temporales
  int initiative; // Valor total de iniciativa (d20 + bono)
  int initiativeBonus; // Bono de iniciativa (normalmente mod. de Destreza)
  bool isPlayer; // Indica si es un jugador o un monstruo
  Monster? monster; // Datos base del monstruo (si aplica)

  Participant({
    required this.id,
    required this.name,
    this.image,
    this.currentHp = 0,
    this.maxHp = 0,
    this.temporaryHp = 0,
    this.initiative = 0,
    this.initiativeBonus = 0,
    this.isPlayer = false,
    this.monster,
  });

  /// Crea un participante desde un objeto JSON para persistencia.
  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      currentHp: json['currentHp'],
      maxHp: json['maxHp'],
      temporaryHp: json['temporaryHp'] ?? 0,
      initiative: json['initiative'],
      initiativeBonus: json['initiativeBonus'],
      isPlayer: json['isPlayer'],
      monster: json['monster'] != null ? Monster.fromJson(json['monster']) : null,
    );
  }

  /// Convierte el participante a JSON para guardarlo.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'currentHp': currentHp,
      'maxHp': maxHp,
      'temporaryHp': temporaryHp,
      'initiative': initiative,
      'initiativeBonus': initiativeBonus,
      'isPlayer': isPlayer,
      'monster': monster?.toJson(),
    };
  }
}

/// Representa una sesión completa de combate guardada.
class CombatSession {
  final String id; // ID único de la sesión
  String name; // Nombre descriptivo del combate
  List<Participant> participants; // Lista de combatientes involucrados
  int turnIndex; // Índice del participante que tiene el turno actual
  int round; // Número de ronda actual
  bool isStarted; // Indica si el combate está en curso o en preparación
  DateTime lastModified; // Fecha de la última vez que se guardó

  CombatSession({
    required this.id,
    required this.name,
    required this.participants,
    this.turnIndex = 0,
    this.round = 1,
    this.isStarted = false,
    required this.lastModified,
  });

  /// Crea una sesión desde JSON.
  factory CombatSession.fromJson(Map<String, dynamic> json) {
    return CombatSession(
      id: json['id'],
      name: json['name'],
      participants: (json['participants'] as List)
          .map((p) => Participant.fromJson(p))
          .toList(),
      turnIndex: json['turnIndex'],
      round: json['round'],
      isStarted: json['isStarted'],
      lastModified: DateTime.parse(json['lastModified']),
    );
  }

  /// Convierte la sesión a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'participants': participants.map((p) => p.toJson()).toList(),
      'turnIndex': turnIndex,
      'round': round,
      'isStarted': isStarted,
      'lastModified': lastModified.toIso8601String(),
    };
  }
}
