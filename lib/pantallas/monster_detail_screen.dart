import 'package:flutter/material.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/service/connection_service.dart';

/// Pantalla que muestra la ficha detallada de una criatura.
class MonsterDetailScreen extends StatefulWidget {
  final String monsterUrl; // URL para obtener los datos completos.
  final String monsterName; // Nombre de la criatura para el título.

  const MonsterDetailScreen({
    super.key,
    required this.monsterUrl,
    required this.monsterName,
  });

  @override
  State<MonsterDetailScreen> createState() => _MonsterDetailScreenState();
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  // Future que contendrá el objeto Monster con todos sus datos.
  late Future<Monster> futureMonster;

  @override
  void initState() {
    super.initState();
    // Iniciamos la descarga de detalles al entrar en la pantalla.
    futureMonster = ConnectionService().fetchMonsterDetail(widget.monsterUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.monsterName),
      ),
      body: FutureBuilder<Monster>(
        future: futureMonster,
        builder: (context, snapshot) {
          // Indicador de carga central mientras se obtienen los datos.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          // Manejo de errores en la obtención de detalles.
          else if (snapshot.hasError) {
            print('Error cargando detalles: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          // Si tenemos los datos del monstruo, construimos la interfaz.
          else if (snapshot.hasData) {
            final monster = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen principal de la criatura (si existe en la API).
                  if (monster.image != null)
                    Center(
                      child: Image.network(
                        "https://www.dnd5eapi.co${monster.image}",
                        height: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Encabezado: Nombre y Descripción básica (Tamaño, Tipo, Alineamiento).
                  Text(
                    monster.name ?? "Sin nombre",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.red[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${monster.size} ${monster.type}, ${monster.alignment}",
                    style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
                  ),
                  const Divider(thickness: 2, color: Colors.brown),

                  // Sección de Estadísticas Básicas.
                  _buildDetailRow("Clase de Armadura", _formatArmorClass(monster.armorClass)),
                  _buildDetailRow("Puntos de Vida", "${monster.hitPoints} (${monster.hitDice})"),
                  _buildDetailRow("Velocidad", _formatSpeed(monster.speed)),
                  const Divider(),

                  // Bloque de Atributos principales con sus modificadores calculados.
                  const Text("Atributos", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat("STR", monster.strength),
                      _buildStat("DEX", monster.dexterity),
                      _buildStat("CON", monster.constitution),
                      _buildStat("INT", monster.intelligence),
                      _buildStat("WIS", monster.wisdom),
                      _buildStat("CHA", monster.charisma),
                    ],
                  ),
                  const Divider(),

                  // Competencias (Saving Throws y Skills).
                  if (monster.proficiencies != null && monster.proficiencies!.isNotEmpty)
                    _buildSection("Competencias", _formatProficiencies(monster.proficiencies)),

                  // Listado de Resistencias, Vulnerabilidades e Inmunidades.
                  if (monster.damageVulnerabilities?.isNotEmpty ?? false)
                    _buildSection("Vulnerabilidades al Daño", monster.damageVulnerabilities!.join(", ")),
                  if (monster.damageResistances?.isNotEmpty ?? false)
                    _buildSection("Resistencias al Daño", monster.damageResistances!.join(", ")),
                  if (monster.damageImmunities?.isNotEmpty ?? false)
                    _buildSection("Inmunidades al Daño", monster.damageImmunities!.join(", ")),
                  if (monster.conditionImmunities?.isNotEmpty ?? false)
                    _buildSection("Inmunidades a Condición", monster.conditionImmunities!.map((e) => e.name).join(", ")),

                  // Otros datos de interés: Sentidos, Idiomas y Desafío (CR).
                  _buildSection("Sentidos", _formatSenses(monster.senses)),
                  _buildSection("Idiomas", monster.languages ?? "Ninguno"),
                  _buildSection("Desafío", "${monster.challengeRating} (${monster.xp} XP)"),
                  const Divider(thickness: 2, color: Colors.brown),

                  // Listado de Habilidades Especiales (Pasivas).
                  if (monster.specialAbilities != null && monster.specialAbilities!.isNotEmpty) ...[
                    const Text("Habilidades Especiales", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.brown)),
                    ...monster.specialAbilities!.map((ability) => _buildActionItem(ability.name, ability.desc)),
                  ],

                  // Listado de Acciones de combate.
                  if (monster.actions != null && monster.actions!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text("Acciones", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.brown)),
                    ...monster.actions!.map((action) => _buildActionItem(action.name, action.desc)),
                  ],

                  // Listado de Acciones Legendarias (si la criatura dispone de ellas).
                  if (monster.legendaryActions != null && monster.legendaryActions!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text("Acciones Legendarias", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.brown)),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text("La criatura puede realizar 3 acciones legendarias, eligiendo entre las opciones siguientes."),
                    ),
                    ...monster.legendaryActions!.map((action) => _buildActionItem(action.name, action.desc)),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
          // Caso por defecto: no hay datos.
          return const Center(child: Text('No hay datos disponibles'));
        },
      ),
    );
  }

  // --- Widgets Auxiliares de Construcción ---

  /// Construye una línea de texto con título en negrita.
  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 16),
          children: [
            TextSpan(text: "$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }

  /// Alias de buildSection para filas de detalle simples.
  Widget _buildDetailRow(String label, String value) {
    return _buildSection(label, value);
  }

  /// Construye el pequeño widget de cada atributo (ej: STR 20 (+5)).
  Widget _buildStat(String label, int? value) {
    // Cálculo estándar de D&D para el modificador de atributo.
    int mod = ((value ?? 10) - 10) ~/ 2;
    String modStr = mod >= 0 ? "+$mod" : "$mod";
    return Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text("${value ?? 10} ($modStr)", style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  /// Construye el bloque de texto para cada acción o habilidad.
  Widget _buildActionItem(String? name, String? desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, fontSize: 17)),
          Text(desc ?? "", style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  // --- Funciones de Formateo de Datos ---

  /// Formatea la lista de Clases de Armadura.
  String _formatArmorClass(List<ArmorClass>? ac) {
    if (ac == null || ac.isEmpty) return "N/A";
    return ac.map((e) => "${e.value} (${e.type ?? 'normal'})").join(", ");
  }

  /// Formatea las velocidades disponibles de la criatura.
  String _formatSpeed(Speed? speed) {
    if (speed == null) return "N/A";
    List<String> parts = [];
    if (speed.walk != null) parts.add("Caminar ${speed.walk}");
    if (speed.swim != null) parts.add("Nadar ${speed.swim}");
    if (speed.fly != null) parts.add("Volar ${speed.fly}");
    return parts.isEmpty ? "N/A" : parts.join(", ");
  }

  /// Formatea las tiradas de salvación y habilidades en las que es competente.
  String _formatProficiencies(List<ProficiencyElement>? profs) {
    if (profs == null || profs.isEmpty) return "N/A";
    return profs.map((e) => "${e.proficiency?.name} +${e.value}").join(", ");
  }

  /// Formatea los sentidos especiales de la criatura.
  String _formatSenses(Senses? senses) {
    if (senses == null) return "N/A";
    List<String> parts = [];
    if (senses.blindsight != null) parts.add("Vista ciega ${senses.blindsight}");
    if (senses.darkvision != null) parts.add("Visión en la oscuridad ${senses.darkvision}");
    if (senses.tremorsense != null) parts.add("Sentido de la vibración ${senses.tremorsense}");
    if (senses.truesight != null) parts.add("Visión verdadera ${senses.truesight}");
    if (senses.passivePerception != null) parts.add("Percepción pasiva ${senses.passivePerception}");
    return parts.isEmpty ? "N/A" : parts.join(", ");
  }
}
