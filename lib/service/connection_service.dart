import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';

class ConnectionService {
  Future<MonsterList> fetchEventos() async {
    final response = await http.get(
      Uri.parse("https://www.dnd5eapi.co/api/monsters"),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => MonsterList.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los Eventos');
    }
  }
}