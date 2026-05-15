/// Clase que representa la respuesta de listado simplificado de la API (index, name, url).
class MonsterList {
  final int count; // Total de resultados disponibles.
  final List<Map<String, dynamic>>?
  results; // Lista de mapas con información básica.

  MonsterList({required this.count, this.results});

  /// Crea una instancia de MonsterList a partir de la respuesta JSON de la API.
  factory MonsterList.fromJson(Map<String, dynamic> json) {
    return MonsterList(
      count: json["count"] ?? 0,
      results: json['results'] != null
          ? List<Map<String, dynamic>>.from(json['results'])
          : [],
    );
  }

  /// Convierte la lista a JSON para almacenamiento persistente en caché.
  Map<String, dynamic> toJson() {
    return {'count': count, 'results': results};
  }
}

/// Modelo de datos exhaustivo para una criatura de D&D.
/// Diseñado para ser compatible tanto con la API oficial como con la creación local del usuario.
class Monster {
  String? index; // Identificador único (slug).
  String? name; // Nombre de la criatura.
  String? size; // Tamaño (Tiny, Large, etc.).
  String? type; // Tipo (Beast, Dragon, etc.).
  String? alignment; // Alineamiento moral (Lawful Good, etc.).
  List<ArmorClass>? armorClass; // Lista de configuraciones de armadura.
  int? hitPoints; // Puntos de vida base.
  String? hitDice; // Dados de vida (ej: 2d10).
  String? hitPointsRoll; // Fórmula de tirada de vida completa.
  Speed? speed; // Velocidades de desplazamiento.
  int? strength,
      dexterity,
      constitution,
      intelligence,
      wisdom,
      charisma; // Atributos base.
  List<ProficiencyElement>?
  proficiencies; // Competencias en habilidades y salvaciones.
  List<String>? damageVulnerabilities; // Debilidades al daño.
  List<String>? damageResistances; // Resistencias al daño.
  List<String>? damageImmunities; // Inmunidades totales al daño.
  List<ApiReference>?
  conditionImmunities; // Inmunidades a estados (Charm, Poison, etc.).
  Senses? senses; // Sentidos especiales (Vision nocturna, etc.).
  String? languages; // Idiomas conocidos.
  num? challengeRating; // Valor de desafío (CR).
  int? proficiencyBonus; // Bono de competencia.
  int? xp; // Experiencia otorgada.
  List<SpecialAbility>? specialAbilities; // Habilidades pasivas.
  List<MonsterAction>? actions; // Acciones de combate estándar.
  List<LegendaryAction>? legendaryActions; // Acciones legendarias especiales.
  List<MonsterReaction>? reactions; // Reacciones de combate.
  String?
  image; // Ruta relativa de la API o URL externa o ruta de archivo local.
  String? url; // URL de referencia en la API.

  Monster({
    this.index,
    this.name,
    this.size,
    this.type,
    this.alignment,
    this.armorClass,
    this.hitPoints,
    this.hitDice,
    this.hitPointsRoll,
    this.speed,
    this.strength,
    this.dexterity,
    this.constitution,
    this.intelligence,
    this.wisdom,
    this.charisma,
    this.proficiencies,
    this.damageVulnerabilities,
    this.damageResistances,
    this.damageImmunities,
    this.conditionImmunities,
    this.senses,
    this.languages,
    this.challengeRating,
    this.proficiencyBonus,
    this.xp,
    this.specialAbilities,
    this.actions,
    this.legendaryActions,
    this.reactions,
    this.image,
    this.url,
  });

  /// Mapeo desde JSON a objeto Monster. Maneja campos nulos y conversiones de tipo.
  factory Monster.fromJson(Map<String, dynamic> json) {
    return Monster(
      index: json['index'],
      name: json['name'],
      size: json['size'],
      type: json['type'],
      alignment: json['alignment'],
      armorClass: parseList(json['armor_class'], ArmorClass.fromJson),
      hitPoints: json['hit_points'],
      hitDice: json['hit_dice'],
      hitPointsRoll: json['hit_points_roll'],
      speed: json['speed'] != null ? Speed.fromJson(json['speed']) : null,
      strength: json['strength'],
      dexterity: json['dexterity'],
      constitution: json['constitution'],
      intelligence: json['intelligence'],
      wisdom: json['wisdom'],
      charisma: json['charisma'],
      proficiencies: parseList(
        json['proficiencies'],
        ProficiencyElement.fromJson,
      ),
      damageVulnerabilities: List<String>.from(
        json['damage_vulnerabilities'] ?? [],
      ),
      damageResistances: List<String>.from(json['damage_resistances'] ?? []),
      damageImmunities: List<String>.from(json['damage_immunities'] ?? []),
      conditionImmunities: parseList(
        json['condition_immunities'],
        ApiReference.fromJson,
      ),
      senses: json['senses'] != null ? Senses.fromJson(json['senses']) : null,
      languages: json['languages'],
      challengeRating: json['challenge_rating'],
      proficiencyBonus: json['proficiency_bonus'],
      xp: json['xp'],
      specialAbilities: parseList(
        json['special_abilities'],
        SpecialAbility.fromJson,
      ),
      actions: parseList(json['actions'], MonsterAction.fromJson),
      legendaryActions: parseList(
        json['legendary_actions'],
        LegendaryAction.fromJson,
      ),
      reactions: parseList(json['reactions'], MonsterReaction.fromJson),
      image: json['image'],
      url: json['url'],
    );
  }

  /// Serialización a mapa JSON para almacenamiento en SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'index': index,
      'name': name,
      'size': size,
      'type': type,
      'alignment': alignment,
      'armor_class': armorClass?.map((e) => e.toJson()).toList(),
      'hit_points': hitPoints,
      'hit_dice': hitDice,
      'hit_points_roll': hitPointsRoll,
      'speed': speed?.toJson(),
      'strength': strength,
      'dexterity': dexterity,
      'constitution': constitution,
      'intelligence': intelligence,
      'wisdom': wisdom,
      'charisma': charisma,
      'proficiencies': proficiencies?.map((e) => e.toJson()).toList(),
      'damage_vulnerabilities': damageVulnerabilities,
      'damage_resistances': damageResistances,
      'damage_immunities': damageImmunities,
      'condition_immunities': conditionImmunities
          ?.map((e) => e.toJson())
          .toList(),
      'senses': senses?.toJson(),
      'languages': languages,
      'challenge_rating': challengeRating,
      'proficiency_bonus': proficiencyBonus,
      'xp': xp,
      'special_abilities': specialAbilities?.map((e) => e.toJson()).toList(),
      'actions': actions?.map((e) => e.toJson()).toList(),
      'legendary_actions': legendaryActions?.map((e) => e.toJson()).toList(),
      'reactions': reactions?.map((e) => e.toJson()).toList(),
      'image': image,
      'url': url,
    };
  }
}

/// Representa una acción de combate de la criatura.
class MonsterAction {
  String? name; // Nombre de la acción.
  String? desc; // Descripción del efecto.
  List<Damage>? damage; // Lista de tipos y dados de daño si aplica.
  Dc? dc; // Salvación requerida si aplica.

  MonsterAction({this.name, this.desc, this.damage, this.dc});

  factory MonsterAction.fromJson(Map<String, dynamic> json) {
    return MonsterAction(
      name: json['name'],
      desc: json['desc'],
      damage: (json['damage'] as List?)
          ?.map((e) => Damage.fromJson(e))
          .toList(),
      dc: json['dc'] != null ? Dc.fromJson(json['dc']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'desc': desc,
    'damage': damage?.map((e) => e.toJson()).toList(),
    'dc': dc?.toJson(),
  };
}

/// Representa el daño causado (dados y tipo).
class Damage {
  final ApiReference? damageType;
  final String? damageDice;

  Damage({this.damageType, this.damageDice});

  factory Damage.fromJson(Map<String, dynamic> json) {
    return Damage(
      damageType: json['damage_type'] != null
          ? ApiReference.fromJson(json['damage_type'])
          : null,
      damageDice: json['damage_dice'],
    );
  }

  Map<String, dynamic> toJson() => {
    'damage_type': damageType?.toJson(),
    'damage_dice': damageDice,
  };
}

/// Objeto genérico para referencias internas de la API (Nombre y URL).
class ApiReference {
  final String? index, name, url;

  ApiReference({this.index, this.name, this.url});

  factory ApiReference.fromJson(Map<String, dynamic> json) {
    return ApiReference(
      index: json['index'],
      name: json['name'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() => {'index': index, 'name': name, 'url': url};
}

/// Clase de Dificultad (DC) para pruebas o salvaciones.
class Dc {
  final ApiReference? dcType;
  final int? dcValue;
  final String? successType;

  Dc({this.dcType, this.dcValue, this.successType});

  factory Dc.fromJson(Map<String, dynamic> json) {
    return Dc(
      dcType: json['dc_type'] != null
          ? ApiReference.fromJson(json['dc_type'])
          : null,
      dcValue: json['dc_value'],
      successType: json['success_type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'dc_type': dcType?.toJson(),
    'dc_value': dcValue,
    'success_type': successType,
  };
}

/// Estructura para la Clase de Armadura.
class ArmorClass {
  String? type;
  int? value;

  ArmorClass({this.type, this.value});

  factory ArmorClass.fromJson(Map<String, dynamic> json) =>
      ArmorClass(type: json['type'], value: json['value']);

  Map<String, dynamic> toJson() => {'type': type, 'value': value};
}

/// Acción legendaria (se ejecuta al final del turno de otro).
class LegendaryAction {
  String? name, desc;

  LegendaryAction({this.name, this.desc});

  factory LegendaryAction.fromJson(Map<String, dynamic> json) =>
      LegendaryAction(name: json['name'], desc: json['desc']);

  Map<String, dynamic> toJson() => {'name': name, 'desc': desc};
}

/// Elemento de competencia (Habilidad o Salvación).
class ProficiencyElement {
  final int? value;
  final ApiReference? proficiency;

  ProficiencyElement({this.value, this.proficiency});

  factory ProficiencyElement.fromJson(Map<String, dynamic> json) {
    return ProficiencyElement(
      value: json['value'],
      proficiency: json['proficiency'] != null
          ? ApiReference.fromJson(json['proficiency'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'proficiency': proficiency?.toJson(),
  };
}

/// Definición de sentidos de la criatura.
class Senses {
  String? blindsight, darkvision, tremorsense, truesight;
  int? passivePerception;

  Senses({
    this.blindsight,
    this.darkvision,
    this.tremorsense,
    this.truesight,
    this.passivePerception,
  });

  factory Senses.fromJson(Map<String, dynamic> json) => Senses(
    blindsight: json['blindsight'],
    darkvision: json['darkvision'],
    tremorsense: json['tremorsense'],
    truesight: json['truesight'],
    passivePerception: json['passive_perception'],
  );

  Map<String, dynamic> toJson() => {
    'blindsight': blindsight,
    'darkvision': darkvision,
    'tremorsense': tremorsense,
    'truesight': truesight,
    'passive_perception': passivePerception,
  };
}

/// Habilidad especial o rasgo pasivo.
class SpecialAbility {
  String? name, desc;

  SpecialAbility({this.name, this.desc});

  factory SpecialAbility.fromJson(Map<String, dynamic> json) =>
      SpecialAbility(name: json['name'], desc: json['desc']);

  Map<String, dynamic> toJson() => {'name': name, 'desc': desc};
}

/// Configuración de velocidades de movimiento.
class Speed {
  String? walk, fly, swim;

  Speed({this.walk, this.fly, this.swim});

  factory Speed.fromJson(Map<String, dynamic> json) =>
      Speed(walk: json['walk'], fly: json['fly'], swim: json['swim']);

  Map<String, dynamic> toJson() => {'walk': walk, 'fly': fly, 'swim': swim};
}

/// Representa una reacción de combate.
class MonsterReaction {
  String? name, desc;

  MonsterReaction({this.name, this.desc});

  factory MonsterReaction.fromJson(Map<String, dynamic> json) =>
      MonsterReaction(name: json['name'], desc: json['desc']);

  Map<String, dynamic> toJson() => {'name': name, 'desc': desc};
}

/// Helper para parsear listas dinámicas en el JSON.
List<T> parseList<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
  if (json is List) {
    return json.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}
