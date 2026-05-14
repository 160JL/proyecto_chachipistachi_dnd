import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import 'package:provider/provider.dart';
import '../models/monster.dart';
import '../models/combat.dart';
import '../providers/battle_queue_provider.dart';
import '../service/combat_storage_service.dart';
import 'monster_detail_screen.dart';

/// Pantalla de seguimiento de iniciativa (Initiative Tracker).
/// Permite gestionar el orden de turnos, la vida de los participantes y el estado del combate.
class InitiativeTrackerScreen extends StatefulWidget {
  final CombatSession?
  session; // Sesión de combate existente (si se retoma uno guardado)
  const InitiativeTrackerScreen({super.key, this.session});

  @override
  State<InitiativeTrackerScreen> createState() =>
      _InitiativeTrackerScreenState();
}

class _InitiativeTrackerScreenState extends State<InitiativeTrackerScreen> {
  late CombatSession _session;
  final CombatStorageService _storageService = CombatStorageService();

  @override
  void initState() {
    super.initState();
    // Si recibimos una sesión, la usamos; si no, creamos una nueva.
    if (widget.session != null) {
      _session = widget.session!;
    } else {
      _session = CombatSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "Nuevo Combate",
        participants: [],
        lastModified: DateTime.now(),
      );
    }
  }

  /// Guarda el estado actual del combate en el almacenamiento persistente.
  void _saveSession() {
    setState(() {
      _session.lastModified = DateTime.now();
    });
    _storageService.saveSession(_session);
  }

  /// Añade una criatura desde el bestiario al combate.
  /// Implementa lógica de numeración automática para múltiples instancias del mismo monstruo.
  void _addMonsterToCombat(Monster monster) {
    setState(() {
      var sameType = _session.participants
          .where((p) => p.monster?.index == monster.index)
          .toList();
      String baseName = monster.name ?? "Criatura";
      String name = baseName;

      // Si ya hay criaturas del mismo tipo, empezamos a numerarlas.
      if (sameType.isNotEmpty) {
        if (sameType.length == 1 && !sameType[0].name.endsWith(" 1")) {
          sameType[0].name = "$baseName 1";
        }
        name = "$baseName ${sameType.length + 1}";
      }

      final p = Participant(
        id:
            DateTime.now().millisecondsSinceEpoch.toString() +
            Random().nextInt(1000).toString(),
        name: name,
        image: monster.image,
        currentHp: monster.hitPoints ?? 0,
        maxHp: monster.hitPoints ?? 0,
        temporaryHp: 0,
        isPlayer: false,
        monster: monster,
        initiativeBonus: _getModifier(monster.dexterity),
      );
      _session.participants.add(p);
      _sortInitiative();
    });
    _saveSession();
  }

  /// Calcula el modificador de atributo (D&D 5e).
  int _getModifier(int? stat) {
    if (stat == null) return 0;
    return ((stat - 10) / 2).floor();
  }

  /// Ordena a los participantes por iniciativa (descendente).
  /// En caso de empate, usa el bono de iniciativa como desempate.
  void _sortInitiative() {
    setState(() {
      String? currentId;
      if (_session.isStarted &&
          _session.turnIndex < _session.participants.length) {
        currentId = _session.participants[_session.turnIndex].id;
      }

      _session.participants.sort((a, b) {
        int cmp = b.initiative.compareTo(a.initiative);
        if (cmp == 0) {
          return b.initiativeBonus.compareTo(a.initiativeBonus);
        }
        return cmp;
      });

      // Mantenemos el turno en la persona correcta tras reordenar.
      if (currentId != null) {
        int newIndex = _session.participants.indexWhere(
          (p) => p.id == currentId,
        );
        _session.turnIndex = newIndex != -1 ? newIndex : 0;
      }
    });
  }

  /// Realiza tiradas automáticas de iniciativa para todos los monstruos.
  void _rollCreatureInitiative() {
    final random = Random();
    setState(() {
      for (var p in _session.participants) {
        if (!p.isPlayer) {
          p.initiative = random.nextInt(20) + 1 + p.initiativeBonus;
        }
      }
      _sortInitiative();
    });
    _saveSession();
  }

  /// Realiza tiradas automáticas de iniciativa para todos los jugadores.
  void _rollPlayerInitiative() {
    final random = Random();
    setState(() {
      for (var p in _session.participants) {
        if (p.isPlayer) {
          p.initiative = random.nextInt(20) + 1 + p.initiativeBonus;
        }
      }
      _sortInitiative();
    });
    _saveSession();
  }

  /// Inicia oficialmente el combate.
  void _startCombat() {
    setState(() {
      _session.isStarted = true;
      _session.round = 1;
      _session.turnIndex = 0;
      _sortInitiative();
    });
    _saveSession();
  }

  /// Avanza al siguiente turno. Incrementa la ronda si se completa el ciclo.
  void _nextTurn() {
    setState(() {
      _session.turnIndex++;
      if (_session.turnIndex >= _session.participants.length) {
        _session.turnIndex = 0;
        _session.round++;
      }
    });
    _saveSession();
  }

  /// Detiene el estado de combate iniciado.
  void _endCombat() {
    setState(() {
      _session.isStarted = false;
    });
    _saveSession();
  }

  /// Pide confirmación para eliminar a un participante.
  void _confirmDelete(int index) {
    final p = _session.participants[index];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Participante"),
        content: Text("¿Estás seguro de que quieres eliminar a ${p.name} del combate?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _session.participants.removeAt(index);
                if (_session.turnIndex >= _session.participants.length &&
                    _session.turnIndex > 0) {
                  _session.turnIndex--;
                }
              });
              Navigator.pop(context);
              _saveSession();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Muestra la ficha de la criatura.
  void _showMonsterDetails(Participant p) {
    if (p.monster != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MonsterDetailScreen(
            monsterName: p.name,
            monster: p.monster,
            showActions: false, // Ocultamos botones de acción desde el tracker
          ),
        ),
      );
    }
  }

  /// Muestra un diálogo para añadir un nuevo jugador manualmente.
  void _addPlayer() {
    String name = "";
    int bonus = 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Añadir Jugador"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: "Nombre"),
              onChanged: (val) => name = val,
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Bono Iniciativa"),
              keyboardType: TextInputType.number,
              onChanged: (val) => bonus = int.tryParse(val) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _session.participants.add(
                  Participant(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    isPlayer: true,
                    initiativeBonus: bonus,
                  ),
                );
              });
              Navigator.pop(context);
              _saveSession();
            },
            child: const Text("AÑADIR"),
          ),
        ],
      ),
    );
  }

  /// Diálogo para editar el valor de iniciativa de un participante.
  void _editInitiative(Participant p) {
    final controller = TextEditingController(text: p.initiative.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar Iniciativa - ${p.name}"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Valor de iniciativa"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                p.initiative = int.tryParse(controller.text) ?? p.initiative;
                _sortInitiative();
              });
              Navigator.pop(context);
              _saveSession();
            },
            child: const Text("GUARDAR"),
          ),
        ],
      ),
    );
  }

  /// Diálogo para actualizar los puntos de vida de un participante.
  void _editHp(Participant p) {
    final hpController = TextEditingController(text: p.currentHp.toString());
    final tempHpController = TextEditingController(
      text: p.temporaryHp.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Gestión de Vida - ${p.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: hpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Vida Actual"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: tempHpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Vida Temporal"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                p.currentHp = int.tryParse(hpController.text) ?? p.currentHp;
                p.temporaryHp =
                    int.tryParse(tempHpController.text) ?? p.temporaryHp;
              });
              Navigator.pop(context);
              _saveSession();
            },
            child: const Text("GUARDAR"),
          ),
        ],
      ),
    );
  }

  /// Resuelve la imagen del participante desde URL o archivo.
  ImageProvider? _getParticipantImage(Participant p) {
    String? img = p.image;
    if (img == null || img.isEmpty) return null;
    if (img.startsWith('http')) return NetworkImage(img);
    if (img.startsWith('/api')) {
      return NetworkImage("https://www.dnd5eapi.co$img");
    }
    final file = File(img);
    if (file.existsSync()) return FileImage(file);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_session.name),
        actions: [
          // Botón para renombrar el combate actual.
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final controller = TextEditingController(text: _session.name);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Nombre del Combate"),
                  content: TextField(controller: controller),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("CANCELAR"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _session.name = controller.text);
                        Navigator.pop(context);
                        _saveSession();
                      },
                      child: const Text("GUARDAR"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final bool isPortrait = orientation == Orientation.portrait;

          // Definimos el widget de controles (botones y gestión).
          // Se adapta automáticamente al espacio disponible.
          final Widget controlsWidget = Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_session.isStarted) ...[
                    const Text(
                      "PREPARACIÓN",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Botón para añadir criaturas desde la cola.
                    ElevatedButton.icon(
                      onPressed: _showAddMonsterDialog,
                      icon: const Icon(Icons.add, size: 20),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Añadir Criaturas", style: TextStyle(fontSize: 13)),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Botón para añadir jugadores manualmente.
                    ElevatedButton.icon(
                      onPressed: _addPlayer,
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Añadir Jugadores", style: TextStyle(fontSize: 13)),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      ),
                    ),
                    const Divider(height: 30),
                    // Botones de iniciativa más prominentes y visuales.
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _rollCreatureInitiative,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 4,
                            ),
                            child: const Text("INI. MONSTRUOS", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _rollPlayerInitiative,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 4,
                            ),
                            child: const Text("INI. JUGADORES", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Botón para iniciar el ciclo de turnos.
                    ElevatedButton(
                      onPressed: _session.participants.isNotEmpty
                          ? _startCombat
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "EMPEZAR COMBATE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Panel informativo del combate en curso (Ronda y Turno).
                    Card(
                      color: Colors.brown.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              "RONDA ${_session.round}",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_session.participants.isNotEmpty)
                              Text(
                                "Turno de: ${_session.participants[_session.turnIndex].name}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Avanzar al siguiente participante.
                    ElevatedButton.icon(
                      onPressed: _nextTurn,
                      icon: const Icon(Icons.skip_next, size: 28),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "SIGUIENTE TURNO",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Finalizar la sesión de combate actual.
                    ElevatedButton.icon(
                      onPressed: _endCombat,
                      icon: const Icon(Icons.stop, size: 20),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("TERMINAR COMBATE", style: TextStyle(fontSize: 14)),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );

          // Definimos el widget de la lista de iniciativa (el tracker).
          final Widget listWidget = Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: !isPortrait
                      ? BorderSide(color: Colors.brown.shade200, width: 2)
                      : BorderSide.none,
                  top: isPortrait
                      ? BorderSide(color: Colors.brown.shade200, width: 2)
                      : BorderSide.none,
                ),
                color: Colors.brown.shade50.withValues(alpha: 0.5),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _session.participants.length,
                itemBuilder: (context, index) {
                  final p = _session.participants[index];
                  final isActive =
                      _session.isStarted && _session.turnIndex == index;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.amber.shade100 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? Colors.amber.shade800
                            : Colors.brown.shade200,
                        width: isActive ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Parte superior de la tarjeta: Información y detalles.
                        InkWell(
                          onTap: () => _showMonsterDetails(p),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                // Número de iniciativa editable al toque.
                                GestureDetector(
                                  onTap: () => _editInitiative(p),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.brown.shade800,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      p.initiative.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.brown,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        p.isPlayer
                                            ? "JUGADOR"
                                            : (p.monster?.type?.toUpperCase() ??
                                                  "CRIATURA"),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: p.isPlayer
                                              ? Colors.blue.shade700
                                              : Colors.red.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Avatar del participante (si no es jugador).
                                if (!p.isPlayer)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      color: Colors.grey.shade200,
                                      child: p.image != null || p.monster != null
                                          ? Image(
                                              image:
                                                  _getParticipantImage(p) ??
                                                  const AssetImage(
                                                    'assets/placeholder.png',
                                                  ),
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, s) =>
                                                  Center(child: Text(p.name[0])),
                                            )
                                          : Center(child: Text(p.name[0])),
                                    ),
                                  ),
                                // Botón para eliminar participante con confirmación.
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => _confirmDelete(index),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Barra inferior de HP y HP Temporal editable.
                        InkWell(
                          onTap: () => _editHp(p),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.brown.shade50,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "HP: ${p.currentHp}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.shield,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "TMP: ${p.temporaryHp}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.brown,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );

          // Retornamos Flex con dirección vertical u horizontal según la orientación.
          return Flex(
            direction: isPortrait ? Axis.vertical : Axis.horizontal,
            children: isPortrait
                ? [listWidget, controlsWidget]
                : [controlsWidget, listWidget],
          );
        },
      ),
    );
  }

  /// Muestra el diálogo para añadir monstruos que están actualmente en la cola de batalla.
  void _showAddMonsterDialog() {
    final queuedMonsters = Provider.of<BattleQueueProvider>(context, listen: false).queue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Añadir desde la Cola"),
        content: SizedBox(
          width: double.maxFinite,
          child: queuedMonsters.isEmpty
              ? const Text(
                  "La cola de batalla está vacía. Añade criaturas desde el Bestiario.",
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: queuedMonsters.length,
                  itemBuilder: (context, index) {
                    final m = queuedMonsters[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: _getParticipantImage(
                          Participant(
                            id: "",
                            name: "",
                            image: m.image,
                            monster: m,
                          ),
                        ),
                        child: m.image == null ? Text(m.name?[0] ?? "?") : null,
                      ),
                      title: Text(m.name ?? "Sin nombre"),
                      subtitle: Text("${m.size} ${m.type}"),
                      onTap: () {
                        _addMonsterToCombat(m);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
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
