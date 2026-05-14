import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/service/connection_service.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_create_screen.dart';

import 'package:proyecto_chachipistachi_dnd/providers/battle_queue_provider.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

/// Pantalla que muestra la ficha detallada de una criatura.
class MonsterDetailScreen extends StatefulWidget {
  final String?
  monsterUrl; // URL para obtener los datos completos (opcional si se pasa el objeto).
  final String monsterName; // Nombre de la criatura para el título.
  final Monster? monster; // Objeto Monster directo (opcional para local).
  final int?
  monsterIndex; // Índice en el almacenamiento local si es una criatura guardada.
  /// Indica si se deben mostrar los botones de acción (BATALLA, EDITAR).
  /// Útil para reutilizar la pantalla como modo lectura.
  final bool showActions;

  const MonsterDetailScreen({
    super.key,
    this.monsterUrl,
    required this.monsterName,
    this.monster,
    this.monsterIndex,
    this.showActions = true,
  });

  @override
  State<MonsterDetailScreen> createState() => _MonsterDetailScreenState();
}

class _MonsterDetailScreenState extends State<MonsterDetailScreen> {
  // Future que contendrá el objeto Monster con todos sus datos.
  late Future<Monster> futureMonster;
  Monster? _currentMonster;

  // Clave para capturar la ficha como imagen.
  final GlobalKey _boundaryKey = GlobalKey();

  // Clave para controlar el Scaffold (apertura del drawer).
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Si ya tenemos el monstruo (local), lo usamos en el Future.
    if (widget.monster != null) {
      futureMonster = Future.value(widget.monster!);
      _currentMonster = widget.monster;
    } else if (widget.monsterUrl != null) {
      // Iniciamos la descarga de detalles al entrar en la pantalla si tenemos URL.
      futureMonster = ConnectionService().fetchMonsterDetail(
        widget.monsterUrl!,
      );
    } else {
      futureMonster = Future.error(
        "No se proporcionó URL ni objeto de criatura",
      );
    }
  }

  /// Construye el widget de imagen de la criatura resolviendo la ruta (URL o local).
  Widget _buildMonsterImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return const SizedBox.shrink();

    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        height: 250,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 100),
      );
    } else if (imagePath.startsWith('/api/images/')) {
      return Image.network(
        "https://www.dnd5eapi.co$imagePath",
        height: 250,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 100),
      );
    } else {
      // Asumimos que es una ruta de archivo local
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          height: 250,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 100),
        );
      }
    }
    return const Icon(Icons.broken_image, size: 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.monsterName),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            tooltip: "Menú de acciones",
          ),
        ],
      ),
      endDrawer: _buildActionDrawer(),
      body: SafeArea(
        child: FutureBuilder<Monster>(
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
              // Actualizamos el monstruo actual para el botón de la AppBar.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _currentMonster == null) {
                  setState(() {
                    _currentMonster = monster;
                  });
                }
              });
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: Card(
                    elevation: 8,
                    margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surface, // Pergamino auténtico (o modo oscuro)
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(
                              Theme.of(context).brightness == Brightness.dark
                                  ? 120
                                  : 50,
                            ),
                            blurRadius: 4,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Borde decorativo superior
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Imagen principal de la criatura.
                                if (monster.image != null)
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: _buildMonsterImage(monster.image),
                                    ),
                                  ),

                                // Encabezado: Nombre y Descripción básica (Tamaño, Tipo, Alineamiento).
                                Text(
                                  monster.name?.toUpperCase() ?? "SIN NOMBRE",
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'serif',
                                  ),
                                ),
                                Text(
                                  "${monster.size} ${monster.type}, ${monster.alignment}",
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                    fontFamily: 'serif',
                                  ),
                                ),
                                const _DndDivider(),

                                // Sección de Estadísticas Básicas.
                                _buildStatBlockRow(
                                  "Armor Class",
                                  _formatArmorClass(monster.armorClass),
                                ),
                                _buildStatBlockRow(
                                  "Hit Points",
                                  "${monster.hitPoints} (${monster.hitDice})",
                                ),
                                _buildStatBlockRow(
                                  "Speed",
                                  _formatSpeed(monster.speed),
                                ),
                                const _DndDivider(),

                                // Bloque de Atributos principales.
                                _buildAbilityTable(monster),
                                const _DndDivider(),

                                // Competencias y otros rasgos.
                                if (monster.proficiencies != null &&
                                    monster.proficiencies!.any(
                                      (p) =>
                                          p.proficiency?.name?.contains(
                                            'Saving Throw',
                                          ) ??
                                          false,
                                    ))
                                  _buildStatBlockRow(
                                    "Saving Throws",
                                    _formatProficiencies(
                                      monster.proficiencies!
                                          .where(
                                            (p) =>
                                                p.proficiency?.name?.contains(
                                                  'Saving Throw',
                                                ) ??
                                                false,
                                          )
                                          .toList(),
                                    ),
                                  ),
                                if (monster.proficiencies != null &&
                                    monster.proficiencies!.any(
                                      (p) =>
                                          p.proficiency?.name?.contains(
                                            'Skill',
                                          ) ??
                                          false,
                                    ))
                                  _buildStatBlockRow(
                                    "Skills",
                                    _formatProficiencies(
                                      monster.proficiencies!
                                          .where(
                                            (p) =>
                                                p.proficiency?.name?.contains(
                                                  'Skill',
                                                ) ??
                                                false,
                                          )
                                          .toList(),
                                    ),
                                  ),
                                if (monster.damageVulnerabilities?.isNotEmpty ??
                                    false)
                                  _buildStatBlockRow(
                                    "Damage Vulnerabilities",
                                    monster.damageVulnerabilities!.join(", "),
                                  ),
                                if (monster.damageResistances?.isNotEmpty ??
                                    false)
                                  _buildStatBlockRow(
                                    "Damage Resistances",
                                    monster.damageResistances!.join(", "),
                                  ),
                                if (monster.damageImmunities?.isNotEmpty ??
                                    false)
                                  _buildStatBlockRow(
                                    "Damage Immunities",
                                    monster.damageImmunities!.join(", "),
                                  ),
                                if (monster.conditionImmunities?.isNotEmpty ??
                                    false)
                                  _buildStatBlockRow(
                                    "Condition Immunities",
                                    monster.conditionImmunities!
                                        .map((e) => e.name)
                                        .join(", "),
                                  ),

                                _buildStatBlockRow(
                                  "Senses",
                                  _formatSenses(monster.senses),
                                ),
                                _buildStatBlockRow(
                                  "Languages",
                                  monster.languages ?? "—",
                                ),
                                _buildStatBlockRow(
                                  "Challenge",
                                  "${monster.challengeRating} (${monster.xp ?? 0} XP)",
                                ),
                                _buildStatBlockRow(
                                  "Proficiency Bonus",
                                  "+${monster.proficiencyBonus ?? 0}",
                                ),
                                const _DndDivider(),

                                // Listado de Habilidades Especiales (Pasivas).
                                if (monster.specialAbilities != null &&
                                    monster.specialAbilities!.isNotEmpty)
                                  ...monster.specialAbilities!.map(
                                    (ability) => _buildStatBlockAbility(
                                      ability.name,
                                      ability.desc,
                                    ),
                                  ),

                                // Listado de Acciones de combate.
                                if (monster.actions != null &&
                                    monster.actions!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const _DndHeader("Actions"),
                                  ...monster.actions!.map(
                                    (action) => _buildStatBlockAbility(
                                      action.name,
                                      action.desc,
                                    ),
                                  ),
                                ],

                                // Listado de Acciones Legendarias.
                                if (monster.legendaryActions != null &&
                                    monster.legendaryActions!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const _DndHeader("Legendary Actions"),
                                  ...monster.legendaryActions!.map(
                                    (action) => _buildStatBlockAbility(
                                      action.name,
                                      action.desc,
                                    ),
                                  ),
                                ],

                                // Listado de Reacciones.
                                if (monster.reactions != null &&
                                    monster.reactions!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  const _DndHeader("Reactions"),
                                  ...monster.reactions!.map(
                                    (reaction) => _buildStatBlockAbility(
                                      reaction.name,
                                      reaction.desc,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          // Borde decorativo inferior
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            // Caso por defecto: no hay datos.
            return const Center(child: Text('No hay datos disponibles'));
          },
        ),
      ),
    );
  }

  // --- Widgets Auxiliares de Construcción Estilo Stat Block ---

  Widget _buildStatBlockRow(String label, String content) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bodyColor = Theme.of(context).textTheme.bodyMedium?.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: primaryColor, fontSize: 15, height: 1.3),
          children: [
            TextSpan(
              text: "$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(
              text: content,
              style: TextStyle(color: bodyColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAbilityTable(Monster monster) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _buildAbilityScore("STR", monster.strength)),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
          ),
          Expanded(child: _buildAbilityScore("DEX", monster.dexterity)),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
          ),
          Expanded(child: _buildAbilityScore("CON", monster.constitution)),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
          ),
          Expanded(child: _buildAbilityScore("INT", monster.intelligence)),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
          ),
          Expanded(child: _buildAbilityScore("WIS", monster.wisdom)),
          Container(
            width: 1,
            height: 30,
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
          ),
          Expanded(child: _buildAbilityScore("CHA", monster.charisma)),
        ],
      ),
    );
  }

  Widget _buildAbilityScore(String label, int? value) {
    int mod = ((value ?? 10) - 10) ~/ 2;
    String modStr = mod >= 0 ? "+$mod" : "$mod";
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "$value ($modStr)",
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBlockAbility(String? name, String? desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 15,
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: "${name ?? ""}. ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            TextSpan(text: desc ?? ""),
          ],
        ),
      ),
    );
  }

  /// Construye una línea de texto con título en negrita.
  Widget _buildSection(String title, String content) {
    return _buildStatBlockRow(title, content);
  }

  /// Alias de buildSection para filas de detalle simples.
  Widget _buildDetailRow(String label, String value) {
    return _buildStatBlockRow(label, value);
  }

  /// Construye el pequeño widget de cada atributo (ej: STR 20 (+5)).
  Widget _buildStat(String label, int? value) {
    return _buildAbilityScore(label, value);
  }

  /// Construye el bloque de texto para cada acción o habilidad.
  Widget _buildActionItem(String? name, String? desc) {
    return _buildStatBlockAbility(name, desc);
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
    if (senses.blindsight != null)
      parts.add("Vista ciega ${senses.blindsight}");
    if (senses.darkvision != null)
      parts.add("Visión en la oscuridad ${senses.darkvision}");
    if (senses.tremorsense != null)
      parts.add("Sentido de la vibración ${senses.tremorsense}");
    if (senses.truesight != null)
      parts.add("Visión verdadera ${senses.truesight}");
    if (senses.passivePerception != null)
      parts.add("Percepción pasiva ${senses.passivePerception}");
    return parts.isEmpty ? "N/A" : parts.join(", ");
  }

  /// Construye el menú lateral con las acciones de la criatura.
  Widget _buildActionDrawer() {
    if (_currentMonster == null)
      return const Drawer(child: Center(child: CircularProgressIndicator()));

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Text(
                _currentMonster!.name?.toUpperCase() ?? "ACCIONES",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (widget.showActions) ...[
            ListTile(
              leading: const Icon(Icons.shield),
              title: const Text("Añadir a Batalla"),
              onTap: () {
                Provider.of<BattleQueueProvider>(
                  context,
                  listen: false,
                ).addToQueue(_currentMonster!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${_currentMonster!.name} añadido a batalla"),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(widget.monster != null ? Icons.edit : Icons.copy),
              title: Text(
                widget.monster != null ? "Editar Criatura" : "Usar como Base",
              ),
              onTap: () {
                Navigator.pop(context); // Cerrar drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonsterCreateScreen(
                      baseMonster: _currentMonster,
                      isEditing: widget.monster != null,
                      monsterIndex: widget.monsterIndex,
                    ),
                  ),
                ).then((saved) {
                  if (saved == true) Navigator.pop(context, true);
                });
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text("Exportar como JSON"),
            onTap: () {
              Navigator.pop(context);
              _exportAsJson();
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text("Exportar como PNG"),
            onTap: () {
              Navigator.pop(context);
              _exportAsPng();
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "D&D 5e Stat Block",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context).disabledColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Exporta los datos de la criatura en formato JSON.
  Future<void> _exportAsJson() async {
    try {
      final jsonStr = jsonEncode(_currentMonster!.toJson());
      
      // Intentamos abrir el selector de archivos para guardar
      // En móviles, saveFile requiere los bytes directamente
      final bytes = utf8.encode(jsonStr);
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar como JSON',
        fileName: '${_currentMonster!.name}_stats.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );

      if (outputPath != null) {
        // En móviles, si pasamos 'bytes' a saveFile, la librería ya guarda el archivo.
        // Intentar escribirlo de nuevo con File(path).writeAsString puede dar error de permisos (Errno 13).
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("JSON guardado correctamente")),
          );
        }
      } else {
        // Si cancela el guardado, mostramos el diálogo con el contenido igualmente
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Exportación JSON"),
              content: SingleChildScrollView(child: SelectableText(jsonStr)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CERRAR"),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al exportar JSON: $e")),
        );
      }
    }
  }

  /// Captura la ficha visual y la exporta como imagen PNG.
  Future<void> _exportAsPng() async {
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // Selector de archivos para guardar la imagen
      // Pasamos los bytes para compatibilidad con Android/iOS
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Guardar Ficha como PNG',
        fileName: '${_currentMonster!.name}_ficha.png',
        type: FileType.image,
        bytes: bytes,
      );

      if (outputPath != null) {
        // Si pasamos los bytes, la librería gestiona el guardado delegando en el sistema.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Imagen guardada correctamente")),
          );
        }
      } else {
        // Si cancela, permitimos compartir mediante el menú del sistema
        final directory = await getTemporaryDirectory();
        final tempPath = '${directory.path}/temp_monster_share.png';
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(bytes);
        
        if (mounted) {
          await Share.shareXFiles([XFile(tempPath)], text: 'Ficha de ${_currentMonster!.name}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al generar imagen: $e")),
        );
      }
    }
  }
}

/// Widget personalizado para los divisores cónicos estilo D&D.
class _DndDivider extends StatelessWidget {
  const _DndDivider();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CustomPaint(
        size: const Size(double.infinity, 3),
        painter: _DndDividerPainter(color),
      ),
    );
  }
}

class _DndDividerPainter extends CustomPainter {
  final Color color;

  _DndDividerPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Creamos la forma cónica: empieza fina en los bordes y se ensancha ligeramente (aunque el original es algo más complejo, esto da el pego)
    // O mejor, una línea que se ensancha en el centro
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2,
      -size.height / 2,
      size.width,
      size.height / 2,
    );
    path.quadraticBezierTo(
      size.width / 2,
      size.height * 1.5,
      0,
      size.height / 2,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget para las cabeceras de sección (Actions, Legendary Actions).
class _DndHeader extends StatelessWidget {
  final String title;

  const _DndHeader(this.title);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(fontSize: 24, color: color, fontFamily: 'serif'),
        ),
        Divider(color: color, thickness: 1, height: 8),
        const SizedBox(height: 4),
      ],
    );
  }
}
