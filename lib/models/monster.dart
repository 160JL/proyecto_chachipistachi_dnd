import 'dart:ffi';

class MonsterList {
  Int? count;
  List<Map<String,String>>? results;

  MonsterList({this.count,this.results});

  factory MonsterList.fromJson(Map<String, dynamic> json) {
    return MonsterList(
      count: json["count"],
      results: json["results"],
    );
  }
}

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
  List<dynamic>? damageVulnerabilities;
  List<dynamic>? damageResistances;
  List<String>? damageImmunities;
  List<dynamic>? conditionImmunities;
  Senses? senses;
  String? languages;
  int? challengeRating;
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
      damageVulnerabilities: json['damage_vulnerabilities'] ?? [],
      damageResistances: json['damage_resistances'] ?? [],
      damageImmunities: json["damages_inmunities"],
      conditionImmunities: json['condition_immunities'] ?? [],
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

class ActionAction {
  String? actionName;
  int? count;
  String? type;

  ActionAction({this.actionName, this.count, this.type});

  factory ActionAction.fromJson(Map<String, dynamic> json) {
    return ActionAction(
      actionName: json['action_name'],
      count: json['count'],
      type: json['type'],
    );
  }
}

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

class ActionUsage {
  String? type;
  String? dice;
  int? minValue;

  ActionUsage({this.type, this.dice, this.minValue});

  factory ActionUsage.fromJson(Map<String, dynamic> json) {
    return ActionUsage(
      type: json['type'],
      dice: json['dice'],
      minValue: json['min_value'],
    );
  }
}

class ArmorClass {
  String? type;
  int? value;

  ArmorClass({this.type, this.value});

  factory ArmorClass.fromJson(Map<String, dynamic> json) {
    return ArmorClass(type: json['type'], value: json['value']);
  }
}

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

class Senses {
  String? blindsight;
  String? darkvision;
  int? passivePerception;

  Senses({this.blindsight, this.darkvision, this.passivePerception});

  factory Senses.fromJson(Map<String, dynamic> json) {
    return Senses(
      blindsight: json['blindsight'],
      darkvision: json['darkvision'],
      passivePerception: json['passive_perception'],
    );
  }
}

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

class Speed {
  String? walk;
  String? fly;
  String? swim;

  Speed({this.walk, this.fly, this.swim});

  factory Speed.fromJson(Map<String, dynamic> json) {
    return Speed(walk: json['walk'], fly: json['fly'], swim: json['swim']);
  }
}

List<T> parseList<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
  if (json is List) {
    return json.map((e) => fromJson(e)).toList();
  }
  return [];
}
