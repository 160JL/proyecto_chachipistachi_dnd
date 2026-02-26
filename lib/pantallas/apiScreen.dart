import 'package:flutter/material.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';

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
      appBar: AppBar(),
      body: FutureBuilder(future: futureMonsterSmall, builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          MonsterList monstros = snapshot.data;

          return ListView.builder(itemBuilder: (context, index) {
            return Card(child: Text(monstros[index].name.toString()),);
          });
        }
        else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return Center(child: CircularProgressIndicator());
      }),
    );
  }
}
