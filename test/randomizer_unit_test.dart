import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/service/monster_randomizer_service.dart';

void main() {
  group('MonsterRandomizerService Unit Tests', () {
    test('Genera una criatura con estadisticas dentro del rango (6-30)', () {
      final monster = MonsterRandomizerService.generateRandomMonster(
        targetCr: 1,
        numSpecialAbilities: 0,
        numActions: 0,
        numLegendaryActions: 0,
        numReactions: 0,
        registryEntries: [],
      );


      expect(monster.strength, inInclusiveRange(6, 30));
      expect(monster.dexterity, inInclusiveRange(6, 30));
      expect(monster.constitution, inInclusiveRange(6, 30));
      expect(monster.intelligence, inInclusiveRange(6, 30));
      expect(monster.wisdom, inInclusiveRange(6, 30));
      expect(monster.charisma, inInclusiveRange(6, 30));
    });


    test('HP de la Criatura debe ser consistente con el rango para el CR', () {
      // CR 1, HP 71-85 (_crStatsTable)
      final monster = MonsterRandomizerService.generateRandomMonster(
        targetCr: 1,
        numSpecialAbilities: 0,
        numActions: 0,
        numLegendaryActions: 0,
        numReactions: 0,
        registryEntries: [],
      );


      expect(monster.hitPoints, inInclusiveRange(71, 85));
    });


    test('Bono de competencia de la Criatura debe ser consistente con lareferencia para el CR', () {
      // CR 5, Prof Bonus 3
      final monster = MonsterRandomizerService.generateRandomMonster(
        targetCr: 5,
        numSpecialAbilities: 0,
        numActions: 0,
        numLegendaryActions: 0,
        numReactions: 0,
        registryEntries: [],
      );


      expect(monster.proficiencyBonus, equals(3));
    });

    test('Tamaño de la criatura debe afectar la velocidad de movimiento y los dados de golpe', () {
      final monster = MonsterRandomizerService.generateRandomMonster(
        targetCr: 20,
        numSpecialAbilities: 0,
        numActions: 0,
        numLegendaryActions: 0,
        numReactions: 0,
        registryEntries: [],
      );

      if (monster.size == 'Gargantuan') {
        expect(monster.hitDice, contains('d20'));
        expect(monster.speed?.walk, equals('15 ft.'));
      } else if (monster.size == 'Tiny') {
        expect(monster.hitDice, contains('d4'));
        expect(monster.speed?.walk, equals('30 ft.'));
      }
    });
  });
}
