/// Modelo que representa una entrada individual en el registro de habilidades.
class AbilityRegistryEntry {
  /// Nombre de la habilidad o acción.
  final String name;

  /// Descripción completa del efecto de la habilidad/acción.
  final String desc;

  /// Categoría de la entrada (action, reaction, legendary_action, special_ability).
  final String category;

  /// Challenge Rating (CR) de la criatura de origen.
  final num challengeRating;

  /// Nombre de la criatura original.
  final String monsterName;

  /// Indica si procede de una criatura local del usuario (true) o de la API oficial (false).
  final bool isLocal;

  AbilityRegistryEntry({
    required this.name,
    required this.desc,
    required this.category,
    required this.challengeRating,
    required this.monsterName,
    this.isLocal = false,
  });

  /// Crea una instancia a partir de un mapa JSON.
  factory AbilityRegistryEntry.fromJson(Map<String, dynamic> json) {
    return AbilityRegistryEntry(
      name: json['name'] ?? '',
      desc: json['desc'] ?? '',
      category: json['category'] ?? '',
      challengeRating: json['challenge_rating'] ?? 0,
      monsterName: json['monster_name'] ?? '',
      isLocal: json['is_local'] ?? false,
    );
  }

  /// Serializa la entrada a un mapa JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'desc': desc,
      'category': category,
      'challenge_rating': challengeRating,
      'monster_name': monsterName,
      'is_local': isLocal,
    };
  }
}
