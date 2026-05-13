import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/service/monster_storage_service.dart';
import 'package:proyecto_chachipistachi_dnd/service/battle_queue_service.dart';

/// Representa a un individuo o criatura específica presente en el campo de batalla.
/// Mantiene el estado dinámico del combate como vida actual, posición y su iniciativa.
class Combatant {
  final Monster monster; // Referencia a los datos base del monstruo
  final String
  id; // Identificador único para distinguir entre múltiples copias del mismo monstruo
  Offset
  gridPosition; // Posición actual en la cuadrícula (coordenadas de celda x, y)
  int currentHp; // Puntos de vida actuales
  int initiative; // Valor obtenido en la tirada de iniciativa
  Offset
  turnStartPosition; // Posición al inicio del turno para permitir rehacer movimiento
  int movedThisTurn; // Contador de casillas recorridas en el turno actual

  Combatant({
    required this.monster,
    required this.id,
    this.gridPosition = const Offset(0, 0),
    this.initiative = 0,
  }) : currentHp = monster.hitPoints ?? 0,
       turnStartPosition = gridPosition,
       movedThisTurn = 0;
}

/// Pantalla principal de la simulación de batalla.
/// Gestiona un tablero cuadrado dinámico y el orden de los turnos.
class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

/// Estado de la pantalla de batalla que controla la lógica del tablero, 
/// el sistema de turnos y la gestión de combatientes.
class _BattleScreenState extends State<BattleScreen> {
  // Lista de todas las criaturas activas en el combate
  final List<Combatant> _combatants = [];

  // Índice que indica a quién le toca el turno en la lista de combatientes ordenada
  int _turnIndex = 0;

  // Contador de rondas de combate transcurridas
  int _round = 1;

  // Indica si el combate ha sido iniciado oficialmente
  bool _isCombatStarted = false;

  // Dimensión de la cuadrícula (ej: 7 significa un tablero de 7x7 celdas)
  int _gridCount = 7;

  // Clave global para identificar el widget del tablero y calcular posiciones locales de drop
  final GlobalKey _boardKey = GlobalKey();

  /// Crea un nuevo combatiente basado en un monstruo y lo añade a la batalla.
  /// Genera un ID único y lo posiciona inicialmente en el origen (0,0).
  void _addMonsterToBattle(Monster monster) {
    setState(() {
      final newCombatant = Combatant(
        monster: monster,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        gridPosition: const Offset(0, 0),
      );
      _combatants.add(newCombatant);
      _sortInitiative(); // Reordenar al añadir un nuevo participante
    });
  }

  /// Ordena la lista de combatientes basándose en su valor de iniciativa (descendente).
  /// Reinicia el índice de turno al primer combatiente tras el reordenamiento.
  void _sortInitiative() {
    setState(() {
      _combatants.sort((a, b) => b.initiative.compareTo(a.initiative));
      _turnIndex = 0;
    });
  }

  /// Avanza el turno actual al siguiente combatiente.
  /// Si se llega al final de la lista, se reinicia al primero e incrementa el contador de rondas.
  void _nextTurn() {
    if (_combatants.isEmpty || !_isCombatStarted) return;
    setState(() {
      _turnIndex++;
      if (_turnIndex >= _combatants.length) {
        _turnIndex = 0;
        _round++;
      }
      // Reiniciar contadores de movimiento para el nuevo turno
      _combatants[_turnIndex].turnStartPosition =
          _combatants[_turnIndex].gridPosition;
      _combatants[_turnIndex].movedThisTurn = 0;
    });
  }

  /// Extrae el valor numérico de la velocidad (ej: "30 ft." -> 30) y lo convierte a casillas.
  int _getSpeedInCells(String? speedStr) {
    if (speedStr == null) return 0;
    final match = RegExp(r'(\d+)').firstMatch(speedStr);
    if (match == null) return 0;
    return int.parse(match.group(1)!) ~/ 5;
  }

  /// Devuelve la pieza activa a su posición inicial del turno.
  void _resetMovement() {
    setState(() {
      final active = _combatants[_turnIndex];
      active.gridPosition = active.turnStartPosition;
      active.movedThisTurn = 0;
    });
  }

  /// Calcula el modificador de atributo basado en el valor base (D&D 5e).
  int _getModifier(int? stat) {
    if (stat == null) return 0;
    return ((stat - 10) / 2).floor();
  }

  /// Inicia el combate: Tira iniciativa para todos y activa el orden de turnos.
  void _startCombat() {
    if (_combatants.isEmpty) return;
    final random = Random();
    setState(() {
      for (var c in _combatants) {
        // Fórmula de iniciativa: 1d20 + Modificador de Destreza
        int roll = random.nextInt(20) + 1;
        int mod = _getModifier(c.monster.dexterity);
        c.initiative = roll + mod;
      }
      _isCombatStarted = true;
      _round = 1;
      _sortInitiative();
      // Inicializar movimiento para el primer combatiente
      if (_combatants.isNotEmpty) {
        _combatants[0].turnStartPosition = _combatants[0].gridPosition;
        _combatants[0].movedThisTurn = 0;
      }
    });
  }

  /// Determina el multiplicador de tamaño basado en la categoría de la criatura.
  /// Large = 2x2, Huge = 3x3, Gargantuan = 4x4. Otros = 1x1.
  int _getSizeMultiplier(String? size) {
    switch (size?.toLowerCase()) {
      case 'large':
        return 2;
      case 'huge':
        return 3;
      case 'gargantuan':
        return 4;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    // La interfaz se divide en un AppBar con controles globales, 
    // el tablero táctico superior y paneles inferiores de información.
    return Scaffold(
      appBar: AppBar(
        title: Text(
          !_isCombatStarted
              ? "Preparación ($_gridCount x $_gridCount)"
              : "Ronda $_round - ${_combatants[_turnIndex].monster.name}",
        ),
        actions: [
          // Botón para iniciar el combate si aún no ha empezado
          if (!_isCombatStarted && _combatants.isNotEmpty)
            TextButton.icon(
              onPressed: _startCombat,
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                "INICIAR",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          // Botón para configurar dimensiones del tablero
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: "Configurar Tablero",
          ),
          // Botón para seleccionar y añadir monstruos del repositorio
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddMonsterDialog,
            tooltip: "Añadir Criatura",
          ),
          // Botón para saltar al siguiente turno
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _isCombatStarted && _combatants.isNotEmpty
                ? _nextTurn
                : null,
            tooltip: "Siguiente Turno",
          ),
        ],
      ),
      body: Column(
        children: [
          // Área principal del tablero de combate
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Ajuste automático: El tablero siempre es cuadrado y ocupa el máximo espacio posible
                  double boardSide = min(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  );
                  double cellSize = boardSide / _gridCount;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: boardSide,
                      height: boardSide,
                      child: DragTarget<Combatant>(
                        // Gestiona el soltado de las fichas tras el arrastre
                        onWillAcceptWithDetails: (details) => true,
                        onAcceptWithDetails: (details) {
                          // Obtenemos la posición exacta del drop relativa al tablero
                          final renderBox =
                              _boardKey.currentContext!.findRenderObject()
                                  as RenderBox;
                          final localOffset = renderBox.globalToLocal(
                            details.offset,
                          );

                          setState(() {
                            // Calculamos la celda (x, y) destino usando redondeo para que se base en el centro
                            double nx = (localOffset.dx / cellSize).roundToDouble();
                            double ny = (localOffset.dy / cellSize).roundToDouble();

                            int multiplier = _getSizeMultiplier(
                              details.data.monster.size,
                            );

                            // Aseguramos que la ficha se mantenga dentro de los límites del tablero considerando su tamaño
                            nx = nx
                                .clamp(0, _gridCount - multiplier)
                                .toDouble();
                            ny = ny
                                .clamp(0, _gridCount - multiplier)
                                .toDouble();

                            // Calcular distancia recorrida si es su turno
                            if (_isCombatStarted &&
                                _combatants[_turnIndex] == details.data) {
                              int dx = (nx - details.data.gridPosition.dx)
                                  .abs()
                                  .toInt();
                              int dy = (ny - details.data.gridPosition.dy)
                                  .abs()
                                  .toInt();
                              // Las diagonales cuentan como 2 casillas (Manhattan distance)
                              int dist = dx + dy;
                              details.data.movedThisTurn += dist;
                            }

                            details.data.gridPosition = Offset(nx, ny);
                          });
                        },
                        builder: (context, candidateData, rejectedData) {
                          return Stack(
                            key: _boardKey,
                            children: [
                              // Capa inferior: Dibujo de la cuadrícula blanca
                              Container(
                                color: Colors.white,
                                child: CustomPaint(
                                  size: Size(boardSide, boardSide),
                                  painter: GridPainter(
                                    cellSize: cellSize,
                                    gridCount: _gridCount,
                                  ),
                                ),
                              ),
                              // Capa superior: Mapeo de todos los combatientes a sus fichas visuales
                              ..._combatants.map(
                                (c) => _buildMonsterToken(c, cellSize),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Sección de detalles de la criatura activa (Acciones, Reacciones, etc.)
          if (_isCombatStarted && _combatants.isNotEmpty)
            _buildActiveCreatureDetails(),
          // Barra inferior informativa con el orden de iniciativa y estados rápidos
          _buildInitiativeBar(),
        ],
      ),
    );
  }

  /// Muestra las acciones, acciones legendarias y reacciones de la criatura que tiene el turno.
  Widget _buildActiveCreatureDetails() {
    final activeCombatant = _combatants[_turnIndex];
    final active = activeCombatant.monster;
    int speedCells = _getSpeedInCells(active.speed?.walk);

    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TURNO DE: ${active.name?.toUpperCase()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                  fontSize: 13,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.directions_run,
                    size: 16,
                    color: activeCombatant.movedThisTurn > speedCells
                        ? Colors.red
                        : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "MOVIMIENTO: ${activeCombatant.movedThisTurn} / $speedCells casillas",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: activeCombatant.movedThisTurn > speedCells
                          ? Colors.red
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.history, size: 20),
                    onPressed: activeCombatant.movedThisTurn > 0
                        ? _resetMovement
                        : null,
                    tooltip: "Rehacer movimiento",
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Acciones Estándar
                  if (active.actions != null && active.actions!.isNotEmpty) ...[
                    const Text(
                      "ACCIONES:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    ...active.actions!.map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Text(
                          "• ${a.name}: ${a.desc}",
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                  // Reacciones
                  if (active.reactions != null &&
                      active.reactions!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "REACCIONES:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.blueGrey,
                      ),
                    ),
                    ...active.reactions!.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Text(
                          "• ${r.name}: ${r.desc}",
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                  // Acciones Legendarias
                  if (active.legendaryActions != null &&
                      active.legendaryActions!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      "ACCIONES LEGENDARIAS:",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.deepOrange,
                      ),
                    ),
                    ...active.legendaryActions!.map(
                      (la) => Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 4),
                        child: Text(
                          "• ${la.name}: ${la.desc}",
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Crea el widget visual de una ficha de monstruo que se puede arrastrar.
  Widget _buildMonsterToken(Combatant c, double cellSize) {
    bool isCurrentTurn = _combatants.isNotEmpty && _combatants[_turnIndex] == c;
    int multiplier = _getSizeMultiplier(c.monster.size);

    return Positioned(
      left: c.gridPosition.dx * cellSize,
      top: c.gridPosition.dy * cellSize,
      child: Draggable<Combatant>(
        data: c,
        // Centra la ficha bajo el puntero durante el arrastre
        dragAnchorStrategy: (draggable, context, position) =>
            Offset(cellSize * multiplier / 2, cellSize * multiplier / 2),
        // Visualización de la ficha mientras se mueve por la pantalla
        feedback: _tokenCircle(c, cellSize * multiplier, true, opacity: 0.8),
        // Visualización de la posición original mientras se arrastra
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _tokenCircle(c, cellSize * multiplier, false),
        ),
        child: GestureDetector(
          onTap: () => _showMonsterQuickAction(c),
          // Abre el menú de acciones al tocar
          child: _tokenCircle(c, cellSize * multiplier, isCurrentTurn),
        ),
      ),
    );
  }

  /// Construye el círculo visual de la ficha, incluyendo la imagen y el borde de estado.
  Widget _tokenCircle(
    Combatant c,
    double size,
    bool highlighted, {
    double opacity = 1.0,
  }) {
    int multiplier = _getSizeMultiplier(c.monster.size);
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          // Si el multiplicador es 1 usamos círculo, si es mayor usamos un cuadrado redondeado para ocupar mejor el espacio
          shape: multiplier == 1 ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: multiplier > 1
              ? BorderRadius.circular(size * 0.1)
              : null,
          border: Border.all(
            // El color ámbar indica que es el turno actual de esta criatura
            color: highlighted ? Colors.amber : Colors.black87,
            width: highlighted ? 3 : 1.5,
          ),
        ),
        child: ClipOval(
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: _getMonsterImage(c.monster),
            // Si no hay imagen, mostramos la inicial del nombre
            child: c.monster.image == null
                ? Text(
                    c.monster.name?[0] ?? "?",
                    style: TextStyle(
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  /// Resuelve la fuente de la imagen del monstruo (Red, API oficial o Almacenamiento local).
  ImageProvider? _getMonsterImage(Monster m) {
    if (m.image != null && m.image!.isNotEmpty) {
      if (m.image!.startsWith('http')) return NetworkImage(m.image!);
      if (m.image!.startsWith('/api'))
        return NetworkImage("https://www.dnd5eapi.co${m.image}");
      final file = File(m.image!);
      if (file.existsSync()) return FileImage(file);
    }
    return null;
  }

  /// Crea un carrusel horizontal en la parte inferior con la información de todos los combatientes.
  Widget _buildInitiativeBar() {
    if (_combatants.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 90,
      color: Colors.brown[900],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _combatants.length,
        itemBuilder: (context, index) {
          final c = _combatants[index];
          bool isActive = index == _turnIndex;
          return Container(
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive ? Colors.amber[800] : Colors.brown[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  c.monster.name ?? "???",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "HP: ${c.currentHp}",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                Text(
                  "Ini: ${c.initiative}",
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Diálogo para configurar el número de casillas por lado del tablero.
  void _showSettingsDialog() {
    int tempCount = _gridCount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Tamaño del Tablero"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Cuadrícula: $tempCount x $tempCount"),
              Slider(
                value: tempCount.toDouble(),
                min: 3,
                max: 15,
                divisions: 12,
                onChanged: (v) => setDialogState(() => tempCount = v.toInt()),
              ),
              const Text(
                "El tamaño de las casillas se ajustará automáticamente.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
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
                  _gridCount = tempCount;
                  // Al cambiar el tamaño, forzamos que todas las fichas se queden dentro del nuevo límite
                  for (var c in _combatants) {
                    int multiplier = _getSizeMultiplier(c.monster.size);
                    c.gridPosition = Offset(
                      c.gridPosition.dx
                          .clamp(0, _gridCount - multiplier)
                          .toDouble(),
                      c.gridPosition.dy
                          .clamp(0, _gridCount - multiplier)
                          .toDouble(),
                    );
                  }
                });
                Navigator.pop(context);
              },
              child: const Text("GUARDAR"),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra un diálogo de selección para añadir monstruos de la cola de batalla.
  void _showAddMonsterDialog() async {
    final queuedMonsters = await BattleQueueService().getQueue();
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Añadir al combate"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (queuedMonsters.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "La cola de batalla está vacía. Añade criaturas desde el Bestiario o Mis Criaturas primero.",
                      textAlign: TextAlign.center,
                    ),
                  )
                else ...[
                  const Text(
                    "COLA DE BATALLA",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...queuedMonsters.asMap().entries.map((entry) {
                    final m = entry.value;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: _getMonsterImage(m),
                      ),
                      title: Text(m.name ?? "Sin nombre"),
                      subtitle: Text("${m.size} ${m.type}"),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: Colors.redAccent,
                        ),
                        onPressed: () async {
                          await BattleQueueService().removeFromQueue(entry.key);
                          Navigator.pop(context);
                          _showAddMonsterDialog(); // Refrescar el diálogo
                        },
                      ),
                      onTap: () {
                        _addMonsterToBattle(m);
                        Navigator.pop(context);
                      },
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
        actions: [
          if (queuedMonsters.isNotEmpty)
            TextButton(
              onPressed: () async {
                await BattleQueueService().clearQueue();
                Navigator.pop(context);
                _showAddMonsterDialog();
              },
              child: const Text(
                "LIMPIAR COLA",
                style: TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CERRAR"),
          ),
        ],
      ),
    );
  }

  /// Panel inferior de gestión rápida para un combatiente específico.
  /// Permite modificar vida, establecer iniciativa o eliminar la criatura del combate.
  void _showMonsterQuickAction(Combatant c) {
    // Controlador para la edición directa de la vida
    final hpEditController = TextEditingController(
      text: c.currentHp.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setPanelState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  c.monster.name ?? "",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Mostrar Clase de Armadura (AC)
                if (c.monster.armorClass != null &&
                    c.monster.armorClass!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      "AC: ${c.monster.armorClass!.first.value} (${c.monster.armorClass!.first.type})",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // --- Gestión de Vida ---
                const Text(
                  "PUNTOS DE VIDA",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón -1
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(
                          () => c.currentHp--,
                        ); // Actualiza la pantalla principal (tablero e iniciativa)
                        setPanelState(
                          () => hpEditController.text = c.currentHp.toString(),
                        ); // Actualiza el panel localmente
                      },
                    ),
                    // Campo de edición directa de HP
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: hpEditController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          setState(() {
                            c.currentHp = int.tryParse(val) ?? c.currentHp;
                          });
                        },
                      ),
                    ),
                    Text(
                      "/ ${c.monster.hitPoints}",
                      style: const TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    // Botón +1
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        setState(
                          () => c.currentHp++,
                        ); // Actualiza la pantalla principal
                        setPanelState(
                          () => hpEditController.text = c.currentHp.toString(),
                        ); // Actualiza el panel
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Entrada para el valor de iniciativa
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Iniciativa",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: (val) {
                    setState(() {
                      c.initiative = int.tryParse(val) ?? 0;
                      _sortInitiative(); // Reordenar la lista al cambiar iniciativa
                    });
                    Navigator.pop(context);
                  },
                ),
                // Mostrar Reacciones si existen
                if (c.monster.reactions != null &&
                    c.monster.reactions!.isNotEmpty) ...[
                  const Divider(height: 30),
                  const Text(
                    "REACCIONES",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...c.monster.reactions!.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.name ?? "",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            r.desc ?? "",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const Divider(),
                // Botón para retirar la criatura del combate
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Eliminar de la batalla"),
                  onTap: () {
                    setState(() => _combatants.remove(c));
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibujante personalizado encargado de renderizar las líneas de la cuadrícula del tablero.
class GridPainter extends CustomPainter {
  final double cellSize; // Tamaño de la celda en píxeles
  final int gridCount; // Número de celdas por lado
  GridPainter({required this.cellSize, required this.gridCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1;

    // Dibujar líneas verticales y horizontales equidistantes
    for (double i = 0; i <= gridCount * cellSize; i += cellSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, gridCount * cellSize), paint);
      canvas.drawLine(Offset(0, i), Offset(gridCount * cellSize, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) =>
      oldDelegate.cellSize != cellSize || oldDelegate.gridCount != gridCount;
}
