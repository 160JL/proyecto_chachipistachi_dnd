import 'dart:math';
import '../models/monster.dart';
import '../models/monster_ability_registry.dart';

/// Servicio encargado de encapsular toda la lógica matemática y de negocio
/// para generar una criatura de D&D 5e completamente aleatoria y equilibrada.
class MonsterRandomizerService {
  /// Genera una criatura aleatoria basada en un CR y parámetros de usuario.
  ///
  /// Utiliza un sistema de puntos (budget) para los atributos, fórmulas
  /// para calcular dados de golpe, y extrae habilidades aleatorias del registro.
  static Monster generateRandomMonster({
    required num targetCr,
    required int numSpecialAbilities,
    required int numActions,
    required int numLegendaryActions,
    required int numReactions,
    required List<AbilityRegistryEntry> registryEntries,
  }) {
    final random = Random();

    // 1. Obtener stats base sugeridas para el CR
    final stats = _crStatsTable.firstWhere(
      (s) => s.cr == targetCr,
      orElse: () => _crStatsTable.last,
    );

    // 2. Aleatorizar Tamaño y Tipo
    final sizes = ["Tiny", "Small", "Medium", "Large", "Huge", "Gargantuan"];
    final types = [
      "Aberration",
      "Beast",
      "Celestial",
      "Construct",
      "Dragon",
      "Elemental",
      "Fey",
      "Fiend",
      "Giant",
      "Humanoid",
      "Monstrosity",
      "Ooze",
      "Plant",
      "Undead",
    ];
    final size = sizes[random.nextInt(sizes.length)];
    final type = types[random.nextInt(types.length)];

    // 3. Aleatorizar Alineamiento
    final alignPart1 = ["unaligned", "lawful", "neutral", "chaotic"];
    final alignPart2 = ["good", "neutral", "evil"];
    final align1 = alignPart1[random.nextInt(alignPart1.length)];
    final align2 = align1 == "unaligned"
        ? "neutral"
        : alignPart2[random.nextInt(alignPart2.length)];
    final alignment = align1 == "unaligned" ? "unaligned" : "$align1 $align2";

    // 4. Aleatorizar Atributos usando un sistema de reserva (budget)
    int totalPoints = 24 + (targetCr * 3.5).floor();
    List<int> attrs = [6, 6, 6, 6, 6, 6]; // Mínimo 6 en todo

    while (totalPoints > 0) {
      List<int> validIndices = [];
      for (int i = 0; i < 6; i++) {
        if (attrs[i] < 30) validIndices.add(i);
      }
      if (validIndices.isEmpty) break; // Todos alcanzaron el tope de 30

      int indexToIncrease = validIndices[random.nextInt(validIndices.length)];
      int pointsToAdd = random.nextInt(3) + 1; // Añadir de 1 a 3 a la vez

      if (pointsToAdd > totalPoints) pointsToAdd = totalPoints;
      if (attrs[indexToIncrease] + pointsToAdd > 30) {
        pointsToAdd = 30 - attrs[indexToIncrease];
      }

      attrs[indexToIncrease] += pointsToAdd;
      totalPoints -= pointsToAdd;
    }
    final str = attrs[0],
        dex = attrs[1],
        con = attrs[2],
        intelligence = attrs[3],
        wis = attrs[4],
        cha = attrs[5];

    // 5. Velocidad de movimiento
    int sizeIndex = sizes.indexOf(size);
    int walkSpeed = 30; // Base 30
    if (sizeIndex > 2) {
      // Si es mayor a Medium, es más lento (o se podría hacer más rápido según se vea, pero sigo la petición)
      walkSpeed -= (sizeIndex - 2) * 5;
    }
    final speed = Speed(
      walk: "$walkSpeed ft.",
      fly: random.nextDouble() < 0.3 ? "$walkSpeed ft." : "",
      swim: random.nextDouble() < 0.2 ? "$walkSpeed ft." : "",
    );

    // 6. Dados de Golpe (Hit Dice) y Puntos de Vida (HP)
    String hitDie = "d8";
    double avgHpPerDie = 4.5;
    switch (size) {
      case "Tiny":
        hitDie = "d4";
        avgHpPerDie = 2.5;
        break;
      case "Small":
        hitDie = "d6";
        avgHpPerDie = 3.5;
        break;
      case "Medium":
        hitDie = "d8";
        avgHpPerDie = 4.5;
        break;
      case "Large":
        hitDie = "d10";
        avgHpPerDie = 5.5;
        break;
      case "Huge":
        hitDie = "d12";
        avgHpPerDie = 6.5;
        break;
      case "Gargantuan":
        hitDie = "d20";
        avgHpPerDie = 10.5;
        break;
    }

    int generatedHp =
        stats.hpMin + random.nextInt(stats.hpMax - stats.hpMin + 1);
    int conMod = (con - 10) ~/ 2;
    int numDice = (generatedHp / (avgHpPerDie + conMod)).round();
    if (numDice < 1) numDice = 1;

    int hpBonus = numDice * conMod;
    String hpRoll = hpBonus == 0
        ? "$numDice$hitDie"
        : (hpBonus > 0
              ? "$numDice$hitDie + $hpBonus"
              : "$numDice$hitDie - ${hpBonus.abs()}");

    // 7. Sentidos
    int wisMod = (wis - 10) ~/ 2;
    final senses = Senses(
      passivePerception: 10 + wisMod,
      blindsight: random.nextDouble() < 0.1 ? "25 ft." : "",
      darkvision: random.nextDouble() < 0.4 ? "25 ft." : "",
      tremorsense: random.nextDouble() < 0.05 ? "25 ft." : "",
      truesight: random.nextDouble() < 0.05 ? "25 ft." : "",
    );

    // 8. Habilidades, Acciones y Reacciones
    // Busca en CRs descendentes hasta conseguir la cantidad
    List<AbilityRegistryEntry> getAvailable(String category, int count) {
      if (count == 0) return [];
      final List<AbilityRegistryEntry> result = [];
      final Set<String> selectedNames = {};

      final crList = [0, 0.125, 0.25, 0.5, ...List.generate(30, (i) => i + 1)];
      crList.sort((a, b) => b.compareTo(a));

      int startIndex = crList.indexOf(targetCr);
      if (startIndex == -1) startIndex = 0;

      for (
        int i = startIndex;
        i < crList.length && result.length < count;
        i++
      ) {
        final currentCr = crList[i];
        final availableInCr = registryEntries
            .where(
              (e) => e.category == category && e.challengeRating == currentCr,
            )
            .toList();
        availableInCr.shuffle(random);

        for (final entry in availableInCr) {
          if (result.length < count) {
            if (!selectedNames.contains(entry.name)) {
              result.add(entry);
              selectedNames.add(entry.name);
            }
          } else {
            break;
          }
        }
      }
      return result;
    }

    final selectedSpecial = getAvailable(
      'special_ability',
      numSpecialAbilities,
    );
    final selectedAct = getAvailable('action', numActions);
    final selectedLeg = getAvailable('legendary_action', numLegendaryActions);
    final selectedReac = getAvailable('reaction', numReactions);

    // 9. Construir y devolver el objeto Monster final
    return Monster(
      name: "Criatura Aleatoria CR $targetCr",
      size: size,
      type: type,
      alignment: alignment,
      hitPoints: generatedHp,
      hitDice: "$numDice$hitDie",
      hitPointsRoll: hpRoll,
      armorClass: [ArmorClass(value: stats.ac, type: "natural")],
      strength: str,
      dexterity: dex,
      constitution: con,
      intelligence: intelligence,
      wisdom: wis,
      charisma: cha,
      speed: speed,
      challengeRating: targetCr,
      xp: stats.xp,
      proficiencyBonus: stats.profBonus,
      senses: senses,
      specialAbilities: selectedSpecial
          .map((e) => SpecialAbility(name: e.name, desc: e.desc))
          .toList(),
      actions: selectedAct
          .map((e) => MonsterAction(name: e.name, desc: e.desc))
          .toList(),
      legendaryActions: selectedLeg
          .map((e) => LegendaryAction(name: e.name, desc: e.desc))
          .toList(),
      reactions: selectedReac
          .map((e) => MonsterReaction(name: e.name, desc: e.desc))
          .toList(),
    );
  }
}

/// Clase que representa las estadísticas base sugeridas para una criatura
/// dependiendo de su Challenge Rating (CR), según las reglas de creación
/// de monstruos de D&D 5e (Dungeon Master's Guide).
class CRStats {
  final num cr; // Nivel de desafío
  final int profBonus; // Bono de competencia
  final int ac; // Clase de armadura típica
  final int hpMin; // Puntos de vida mínimos sugeridos
  final int hpMax; // Puntos de vida máximos sugeridos
  final int atkBonus; // Bono de ataque típico
  final int dmgMin; // Daño mínimo por ronda sugerido
  final int dmgMax; // Daño máximo por ronda sugerido
  final int saveDc; // Dificultad (DC) de salvación típica
  final int xp; // Experiencia otorgada

  const CRStats(
    this.cr,
    this.profBonus,
    this.ac,
    this.hpMin,
    this.hpMax,
    this.atkBonus,
    this.dmgMin,
    this.dmgMax,
    this.saveDc,
    this.xp,
  );
}

/// Tabla constante de estadísticas de monstruos por Challenge Rating (CR).
/// Se utiliza como referencia base para la generación aleatoria de criaturas.
/// Contiene los valores desde CR 0 hasta 30, incluyendo la experiencia base.
const List<CRStats> _crStatsTable = [
  CRStats(0, 2, 13, 1, 6, 3, 0, 1, 13, 10),
  CRStats(0.125, 2, 13, 7, 35, 3, 2, 3, 13, 25),
  CRStats(0.25, 2, 13, 36, 49, 3, 4, 5, 13, 50),
  CRStats(0.5, 2, 13, 50, 70, 3, 6, 8, 13, 100),
  CRStats(1, 2, 13, 71, 85, 3, 9, 14, 13, 200),
  CRStats(2, 2, 13, 86, 100, 3, 15, 20, 13, 450),
  CRStats(3, 2, 13, 101, 115, 4, 21, 26, 13, 700),
  CRStats(4, 2, 14, 116, 130, 5, 27, 32, 14, 1100),
  CRStats(5, 3, 15, 131, 145, 6, 33, 38, 15, 1800),
  CRStats(6, 3, 15, 146, 160, 6, 39, 44, 15, 2300),
  CRStats(7, 3, 15, 161, 175, 6, 45, 50, 15, 2900),
  CRStats(8, 3, 16, 176, 190, 7, 51, 56, 16, 3900),
  CRStats(9, 4, 16, 191, 205, 7, 57, 62, 16, 5000),
  CRStats(10, 4, 17, 206, 220, 7, 63, 68, 16, 5900),
  CRStats(11, 4, 17, 221, 235, 8, 69, 74, 17, 7200),
  CRStats(12, 4, 17, 236, 250, 8, 75, 80, 17, 8400),
  CRStats(13, 5, 18, 251, 265, 8, 81, 86, 18, 10000),
  CRStats(14, 5, 18, 266, 280, 8, 87, 92, 18, 11500),
  CRStats(15, 5, 18, 281, 295, 8, 93, 98, 18, 13000),
  CRStats(16, 5, 18, 296, 310, 9, 99, 104, 18, 15000),
  CRStats(17, 6, 19, 311, 325, 10, 105, 110, 19, 18000),
  CRStats(18, 6, 19, 326, 340, 10, 111, 116, 19, 20000),
  CRStats(19, 6, 19, 341, 355, 10, 117, 122, 19, 22000),
  CRStats(20, 6, 19, 356, 400, 10, 123, 140, 19, 25000),
  CRStats(21, 7, 19, 401, 445, 11, 141, 158, 20, 33000),
  CRStats(22, 7, 19, 446, 490, 11, 159, 176, 20, 41000),
  CRStats(23, 7, 19, 491, 535, 11, 177, 194, 20, 50000),
  CRStats(24, 7, 19, 536, 580, 12, 195, 212, 21, 62000),
  CRStats(25, 8, 19, 581, 625, 12, 213, 230, 21, 75000),
  CRStats(26, 8, 19, 626, 670, 12, 231, 248, 21, 90000),
  CRStats(27, 8, 19, 671, 715, 13, 249, 266, 22, 105000),
  CRStats(28, 8, 19, 716, 760, 13, 267, 284, 22, 120000),
  CRStats(29, 9, 19, 761, 805, 13, 285, 302, 22, 135000),
  CRStats(30, 9, 19, 806, 850, 14, 303, 320, 23, 155000),
];
