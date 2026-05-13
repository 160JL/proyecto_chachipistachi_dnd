/// Modelo que representa una entrada individual en el registro de habilidades.
///
/// Almacena una acción, reacción, acción legendaria o habilidad especial
/// extraída de una criatura de la API, junto con el CR y nombre de la criatura
/// de la que procede. Permite la generación aleatoria de criaturas seleccionando
/// habilidades apropiadas para un rango de CR determinado.
class AbilityRegistryEntry {
  /// Nombre de la habilidad o acción (ej: "Multiattack", "Amphibious").
  final String name;

  /// Descripción completa del efecto de la habilidad/acción.
  final String desc;

  /// Categoría de la entrada. Valores posibles:
  /// - `action`: Acción de combate estándar.
  /// - `reaction`: Reacción de combate.
  /// - `legendary_action`: Acción legendaria.
  /// - `special_ability`: Habilidad especial o rasgo pasivo.
  final String category;

  /// Challenge Rating (CR) de la criatura de la que se extrajo esta entrada.
  /// Se usa para filtrar habilidades apropiadas según el nivel de desafío deseado.
  final num challengeRating;

  /// Nombre de la criatura original de la que procede esta entrada.
  /// Útil para trazabilidad y referencia.
  final String monsterName;

  AbilityRegistryEntry({
    required this.name,
    required this.desc,
    required this.category,
    required this.challengeRating,
    required this.monsterName,
  });

  /// Crea una instancia de [AbilityRegistryEntry] a partir de un mapa JSON.
  factory AbilityRegistryEntry.fromJson(Map<String, dynamic> json) {
    return AbilityRegistryEntry(
      name: json['name'] ?? '',
      desc: json['desc'] ?? '',
      category: json['category'] ?? '',
      challengeRating: json['challenge_rating'] ?? 0,
      monsterName: json['monster_name'] ?? '',
    );
  }

  /// Serializa la entrada a un mapa JSON para almacenamiento persistente.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': desc,
      'category': category,
      'challenge_rating': challengeRating,
      'monster_name': monsterName,
    };
  }
}
