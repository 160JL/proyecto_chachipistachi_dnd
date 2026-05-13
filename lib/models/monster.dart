/// Clase que representa la respuesta simplificada de la lista de monstruos de la API.
class MonsterList {
  final int count; // Número total de monstruos disponibles.
  final List<Map<String, dynamic>>? results; // Lista de objetos con 'index', 'name' y 'url'.

  MonsterList({required this.count, this.results});

  /// Crea una instancia de MonsterList a partir de un JSON.
  factory MonsterList.fromJson(Map<String, dynamic> json) {
    return MonsterList(
      count: json["count"],
      results: List<Map<String, dynamic>>.from(json['results']),
    );
  }

  /// Convierte la instancia a un mapa JSON para almacenamiento local.
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'results': results,
    };
  }
}

/// Clase principal que contiene todos los detalles de una criatura.
class Monster {
  String? index;
  String? name;
  String? size;
  String? type;
  String? alignment;
  List<ArmorClass>? armorClass;
  int? hitPoints;
  String? hitDice;
  String? hitPointsRoll;
  Speed? speed;
  int? strength;
  int? dexterity;
  int? constitution;
  int? intelligence;
  int? wisdom;
  int? charisma;
  List<ProficiencyElement>? proficiencies;
  List<String>? damageVulnerabilities;
  List<String>? damageResistances;
  List<String>? damageImmunities;
  List<ApiReference>? conditionImmunities;
  Senses? senses;
  String? languages;
  num? challengeRating; // num para soportar CR fraccionales como 0.25
  int? proficiencyBonus;
  int? xp;
  List<SpecialAbility>? specialAbilities;
  List<MonsterAction>? actions;
  List<LegendaryAction>? legendaryActions;
  String? image;
  String? url;

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
    this.image,
    this.url,
  });

  /// Mapea el JSON completo de la API al modelo de datos de la aplicación.
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
      damageVulnerabilities: List<String>.from(json['damage_vulnerabilities'] ?? []),
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
      image: json['image'],
      url: json['url'],
    );
  }
}

/// Representa una acción que el monstruo puede realizar.
class MonsterAction {
  String? name;
  String? multiattackType;
  String? desc;
  List<ActionAction>? actions;
  int? attackBonus;
  List<Damage>? damage;
  Dc? dc;
  ActionUsage? usage;

  MonsterAction({
    this.name,
    this.multiattackType,
    this.desc,
    this.actions,
    this.attackBonus,
    this.damage,
    this.dc,
    this.usage,
  });

  factory MonsterAction.fromJson(Map<String, dynamic> json) {
    return MonsterAction(
      name: json['name'],
      multiattackType: json['multiattack_type'],
      desc: json['desc'],
      actions: (json['actions'] as List?)
          ?.map((e) => ActionAction.fromJson(e))
          .toList(),
      attackBonus: json['attack_bonus'],
      damage: (json['damage'] as List?)
          ?.map((e) => Damage.fromJson(e))
          .toList(),
      dc: json['dc'] != null ? Dc.fromJson(json['dc']) : null,
      usage: json['usage'] != null ? ActionUsage.fromJson(json['usage']) : null,
    );
  }
}

/// Detalles específicos de una acción dentro de un multiataque.
class ActionAction {
  String? actionName;
  int? count;
  String? type;

  ActionAction({this.actionName, this.count, this.type});

  factory ActionAction.fromJson(Map<String, dynamic> json) {
    return ActionAction(
      actionName: json['action_name'],
      // Se usa tryParse porque a veces la API envía el número como String.
      count: int.tryParse(json['count'].toString()),
      type: json['type'],
    );
  }
}

/// Representa el daño causado por un ataque.
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
}

/// Clase genérica para referencias a otros elementos de la API (index, name, url).
class ApiReference {
  final String? index;
  final String? name;
  final String? url;
  final String? updatedAt;

  ApiReference({this.index, this.name, this.url, this.updatedAt});

  factory ApiReference.fromJson(Map<String, dynamic> json) {
    return ApiReference(
      index: json['index'],
      name: json['name'],
      url: json['url'],
      updatedAt: json['updated_at'],
    );
  }
}

/// Clase para representar la Clase de Dificultad (DC) de una habilidad.
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
}

/// Representa las limitaciones de uso de una acción (ej: 3 veces al día).
class ActionUsage {
  String? type;
  String? dice;
  int? minValue;
  int? times;

  ActionUsage({this.type, this.dice, this.minValue, this.times});

  factory ActionUsage.fromJson(Map<String, dynamic> json) {
    return ActionUsage(
      type: json['type'],
      dice: json['dice'],
      minValue: json['min_value'],
      times: json['times'],
    );
  }
}

/// Representa la Clase de Armadura de la criatura.
class ArmorClass {
  String? type;
  int? value;

  ArmorClass({this.type, this.value});

  factory ArmorClass.fromJson(Map<String, dynamic> json) {
    return ArmorClass(type: json['type'], value: json['value']);
  }
}

/// Representa una acción legendaria que se puede realizar fuera del turno.
class LegendaryAction {
  String? name;
  String? desc;
  Dc? dc;
  List<Damage>? damage;

  LegendaryAction({this.name, this.desc, this.dc, this.damage});

  factory LegendaryAction.fromJson(Map<String, dynamic> json) {
    return LegendaryAction(
      name: json['name'],
      desc: json['desc'],
      dc: json['dc'] != null ? Dc.fromJson(json['dc']) : null,
      damage: (json['damage'] as List?)
          ?.map((e) => Damage.fromJson(e))
          .toList(),
    );
  }
}

/// Representa una competencia (Habilidad o Tirada de salvación) con su bono.
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
}

/// Contenedor de los sentidos especiales de la criatura.
class Senses {
  String? blindsight;
  String? darkvision;
  String? tremorsense;
  String? truesight;
  int? passivePerception;

  Senses({
    this.blindsight,
    this.darkvision,
    this.tremorsense,
    this.truesight,
    this.passivePerception,
  });

  factory Senses.fromJson(Map<String, dynamic> json) {
    return Senses(
      blindsight: json['blindsight'],
      darkvision: json['darkvision'],
      tremorsense: json['tremorsense'],
      truesight: json['truesight'],
      passivePerception: json['passive_perception'],
    );
  }
}

/// Habilidades pasivas o especiales de la criatura.
class SpecialAbility {
  String? name;
  String? desc;
  SpecialAbilityUsage? usage;

  SpecialAbility({this.name, this.desc, this.usage});

  factory SpecialAbility.fromJson(Map<String, dynamic> json) {
    return SpecialAbility(
      name: json['name'],
      desc: json['desc'],
      usage: json['usage'] != null
          ? SpecialAbilityUsage.fromJson(json['usage'])
          : null,
    );
  }
}

/// Reglas de uso para habilidades especiales.
class SpecialAbilityUsage {
  String? type;
  int? times;
  List<dynamic>? restTypes;

  SpecialAbilityUsage({this.type, this.times, this.restTypes});

  factory SpecialAbilityUsage.fromJson(Map<String, dynamic> json) {
    return SpecialAbilityUsage(
      type: json['type'],
      times: json['times'],
      restTypes: json['rest_types'] ?? [],
    );
  }
}

/// Velocidades de movimiento de la criatura.
class Speed {
  String? walk;
  String? fly;
  String? swim;

  Speed({this.walk, this.fly, this.swim});

  factory Speed.fromJson(Map<String, dynamic> json) {
    return Speed(walk: json['walk'], fly: json['fly'], swim: json['swim']);
  }
}

/// Función auxiliar para parsear listas de objetos genéricos en el JSON.
List<T> parseList<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
  if (json is List) {
    return json.map((e) => fromJson(e)).toList();
  }
  return [];
}
