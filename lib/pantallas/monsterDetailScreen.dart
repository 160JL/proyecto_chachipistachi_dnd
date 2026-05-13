import 'package:flutter/material.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import '../service/connection_service.dart';

class MonsterDetailScreen extends StatefulWidget {
  final String url;
  final String name;

  const MonsterDetailScreen({super.key, required this.url, required this.name});

  @override
  State<MonsterDetailScreen> createState() => _MonsterDetailScreenState();
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  late Future<Monster> futureMonster;

  @override
  void initState() {
    super.initState();
    futureMonster = ConnectionService().fetchMonster(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: FutureBuilder<Monster>(
        future: futureMonster,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            final monster = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (monster.image != null)
                    Center(
                      child: Image.network(
                        "https://www.dnd5eapi.co${monster.image}",
                        height: 200,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    monster.name ?? '',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    '${monster.size} ${monster.type}, ${monster.alignment}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const Divider(),
                  _buildStatRow('Armor Class', monster.armorClass?.first.value.toString() ?? 'N/A'),
                  _buildStatRow('Hit Points', '${monster.hitPoints} (${monster.hitPointsRoll})'),
                  _buildStatRow('Speed', monster.speed?.walk ?? 'N/A'),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAbility('STR', monster.strength),
                      _buildAbility('DEX', monster.dexterity),
                      _buildAbility('CON', monster.constitution),
                      _buildAbility('INT', monster.intelligence),
                      _buildAbility('WIS', monster.wisdom),
                      _buildAbility('CHA', monster.charisma),
                    ],
                  ),
                  const Divider(),
                  _buildSectionTitle('Senses'),
                  Text(monster.languages ?? 'None'),
                  const SizedBox(height: 10),
                  _buildSectionTitle('Challenge'),
                  Text('${monster.challengeRating} (${monster.xp} XP)'),
                  const Divider(),
                  if (monster.specialAbilities != null && monster.specialAbilities!.isNotEmpty) ...[
                    _buildSectionTitle('Special Abilities'),
                    ...monster.specialAbilities!.map((sa) => _buildActionItem(sa.name ?? '', sa.desc ?? '')),
                  ],
                  if (monster.actions != null && monster.actions!.isNotEmpty) ...[
                    _buildSectionTitle('Actions'),
                    ...monster.actions!.map((action) => _buildActionItem(action.name ?? '', action.desc ?? '')),
                  ],
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildAbility(String label, int? value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value?.toString() ?? '-'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionItem(String name, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 14),
          children: [
            TextSpan(text: '$name. ', style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            TextSpan(text: desc),
          ],
        ),
      ),
    );
  }
}
