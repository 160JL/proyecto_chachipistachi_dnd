import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';

/// Servicio encargado de la conexión con la API de D&D 5e utilizando GraphQL.
class ConnectionService {
  // Configuración del enlace HTTP a la API
  static final HttpLink _httpLink = HttpLink("https://www.dnd5eapi.co/graphql");

  // Cliente de GraphQL configurado con caché básica
  static final GraphQLClient _client = GraphQLClient(
    cache: GraphQLCache(),
    link: _httpLink,
  );

  /// Obtiene la lista simplificada de todos los monstruos disponibles.
  Future<MonsterList> fetchEventos() async {
    const String query = r'''
      query Monsters {
        monsters {
          index
          name
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        debugPrint('ERROR GraphQL (fetchEventos): ${result.exception.toString()}');
        throw Exception('Error al cargar los Eventos');
      }

      final List<dynamic> monstersData = result.data?['monsters'] ?? [];
      
      return MonsterList(
        count: monstersData.length,
        results: monstersData.map((m) => {
          "index": m["index"],
          "name": m["name"],
          "url": "/api/monsters/${m["index"]}" 
        }).toList(),
      );
    } catch (e) {
      debugPrint('ERROR FATAL (fetchEventos): $e');
      rethrow;
    }
  }

  /// Obtiene los detalles completos de un monstruo.
  /// Se han añadido fragmentos inline para manejar tipos complejos como ArmorClass y Damage.
  Future<Monster> fetchMonster(String indexOrUrl) async {
    String index = indexOrUrl.contains('/') 
        ? indexOrUrl.split('/').last 
        : indexOrUrl;

    const String query = r'''
      query Monster($index: String!) {
        monster(index: $index) {
          index
          name
          size
          type
          alignment
          armor_class {
            ... on ArmorClassArmor { value type }
            ... on ArmorClassCondition { value type }
            ... on ArmorClassDex { value type }
            ... on ArmorClassNatural { value type }
            ... on ArmorClassSpell { value type }
          }
          hit_points
          hit_dice
          hit_points_roll
          speed {
            walk
            fly
            swim
          }
          strength
          dexterity
          constitution
          intelligence
          wisdom
          charisma
          proficiencies {
            value
            proficiency {
              index
              name
            }
          }
          damage_vulnerabilities
          damage_resistances
          damage_immunities
          condition_immunities {
             index
             name
          }
          senses {
            darkvision
            passive_perception
          }
          languages
          challenge_rating
          xp
          special_abilities {
            name
            desc
            dc {
              dc_type {
                index
                name
              }
              dc_value
              success_type
            }
          }
          actions {
            name
            desc
            attack_bonus
            damage {
              ... on Damage {
                damage_type {
                  index
                  name
                }
                damage_dice
              }
            }
            dc {
              dc_type {
                index
                name
              }
              dc_value
              success_type
            }
          }
          legendary_actions {
            name
            desc
            damage {
              ... on Damage {
                damage_type {
                  index
                  name
                }
                damage_dice
              }
            }
            dc {
              dc_type {
                index
                name
              }
              dc_value
              success_type
            }
          }
          image
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {'index': index},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        debugPrint('ERROR GraphQL (fetchMonster - $index): ${result.exception.toString()}');
        throw Exception('Error al cargar el monstruo');
      }

      final Map<String, dynamic>? data = result.data?['monster'];
      if (data == null) {
        throw Exception('Monstruo no encontrado');
      }

      return Monster.fromJson(data);
    } catch (e) {
      debugPrint('ERROR FATAL (fetchMonster - $index): $e');
      rethrow;
    }
  }
}
