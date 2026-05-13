import 'package:flutter/material.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monsterDetailScreen.dart';

import '../service/connection_service.dart';

class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  State<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  late Future<MonsterList> futureMonsterSmall;

  @override
  void initState() {
    super.initState();
    futureMonsterSmall = ConnectionService().fetchEventos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monstruos D&D'),
      ),
      body: FutureBuilder<MonsterList>(
        future: futureMonsterSmall,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData) {
            MonsterList monstros = snapshot.data!;
            final results = monstros.results ?? [];

            if (results.isEmpty) {
              return const Center(child: Text('No se encontraron monstruos'));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total de monstruos: ${monstros.count}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final monster = results[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(monster["name"][0]),
                          ),
                          title: Text(
                            monster["name"] ?? 'Sin nombre',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(monster["index"] ?? ''),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MonsterDetailScreen(
                                  url: monster["url"],
                                  name: monster["name"],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
