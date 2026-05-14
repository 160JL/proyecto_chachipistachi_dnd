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
  })  : currentHp = monster.hitPoints ?? 0,
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
  /// Mantiene el marcador de turno en la misma criatura si el combate ya está en curso
  /// para evitar que el turno salte a otro combatiente tras un reordenamiento.
  void _sortInitiative() {
    setState(() {
      String? currentId;
      // Si el combate ya empezó, guardamos el ID de quien tiene el turno
      if (_isCombatStarted && _turnIndex < _combatants.length) {
        currentId = _combatants[_turnIndex].id;
      }

      // Ordenación descendente por valor de iniciativa
      _combatants.sort((a, b) => b.initiative.compareTo(a.initiative));

      // Si teníamos a alguien con el turno, buscamos su nueva posición en la lista ordenada
      if (currentId != null) {
        int newIndex = _combatants.indexWhere((c) => c.id == currentId);
        _turnIndex = newIndex != -1 ? newIndex : 0;
      } else {
        // Si el combate no ha empezado, el turno se reinicia al primero (el de mayor iniciativa)
        _turnIndex = 0;
      }
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
      // Al empezar un nuevo turno, guardamos la posición actual para permitir "deshacer"
      // y reseteamos el contador de movimiento.
      _combatants[_turnIndex].turnStartPosition =
          _combatants[_turnIndex].gridPosition;
      _combatants[_turnIndex].movedThisTurn = 0;
    });
  }

  /// Extrae el valor numérico de la velocidad (ej: "30 ft." -> 30) y lo convierte a casillas.
  /// En D&D 5e, una casilla suele equivaler a 5 pies (ft).
  int _getSpeedInCells(String? speedStr) {
    if (speedStr == null) return 0;
    final match = RegExp(r'(\d+)').firstMatch(speedStr);
    if (match == null) return 0;
    return int.parse(match.group(1)!) ~/ 5;
  }

  /// Devuelve la pieza activa a su posición inicial del turno y limpia el contador de movimiento.
  void _resetMovement() {
    setState(() {
      final active = _combatants[_turnIndex];
      active.gridPosition = active.turnStartPosition;
      active.movedThisTurn = 0;
    });
  }

  /// Calcula el modificador de atributo basado en el valor base (D&D 5e).
  /// Fórmula: (Valor - 10) / 2 redondeado hacia abajo.
  int _getModifier(int? stat) {
    if (stat == null) return 0;
    return ((stat - 10) / 2).floor();
  }

  /// Inicia el combate: Realiza tiradas automáticas de iniciativa para todos y activa el orden.
  void _startCombat() {
    if (_combatants.isEmpty) return;
    final random = Random();
    setState(() {
      for (var c in _combatants) {
        // Iniciativa = 1d20 + Modificador de Destreza
        int roll = random.nextInt(20) + 1;
        int mod = _getModifier(c.monster.dexterity);
        c.initiative = roll + mod;
      }
      _isCombatStarted = true;
      _round = 1;
      _sortInitiative(); // Ordenamos tras las tiradas iniciales
      
      // Preparamos los datos de movimiento para el primer combatiente de la ronda
      if (_combatants.isNotEmpty) {
        _combatants[0].turnStartPosition = _combatants[0].gridPosition;
        _combatants[0].movedThisTurn = 0;
      }
    });
  }

  /// Determina el espacio que ocupa la criatura en la cuadrícula según su tamaño.
  /// Large = 2x2 celdas, Huge = 3x3, Gargantuan = 4x4. Otros (Small/Medium) = 1x1.
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
    // el tablero táctico central y paneles informativos inferiores.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
          // Configuración de las dimensiones de la cuadrícula
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
            tooltip: "Configurar Tablero",
          ),
          // Acceso a la cola para añadir nuevas criaturas al campo
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddMonsterDialog,
            tooltip: "Añadir Criatura",
          ),
          // Avance manual de turnos
          IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: _isCombatStarted && _combatants.isNotEmpty
                ? _nextTurn
                : null,
            tooltip: "Siguiente Turno",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Área principal del tablero de combate con lógica de Drag & Drop
            Expanded(
              child: Container(
                color: Colors.grey[300],
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculamos el tamaño del tablero para que sea siempre el cuadrado más grande posible
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
                          onWillAcceptWithDetails: (details) => true,
                          onAcceptWithDetails: (details) {
                            // Al soltar una ficha, calculamos su nueva posición relativa al origen del tablero
                            final renderBox =
                                _boardKey.currentContext!.findRenderObject()
                                    as RenderBox;
                            final localOffset = renderBox.globalToLocal(
                              details.offset,
                            );

                            setState(() {
                              // Convertimos la posición de píxeles a coordenadas de celda (0, 1, 2...)
                              double nx = (localOffset.dx / cellSize).roundToDouble();
                              double ny = (localOffset.dy / cellSize).roundToDouble();

                              int multiplier = _getSizeMultiplier(
                                details.data.monster.size,
                              );

                              // Restringimos la posición para que la criatura no se salga del tablero,
                              // considerando que las criaturas grandes ocupan más de una celda.
                              nx = nx
                                  .clamp(0, _gridCount - multiplier)
                                  .toDouble();
                              ny = ny
                                  .clamp(0, _gridCount - multiplier)
                                  .toDouble();

                              // Si la criatura que se mueve es la que tiene el turno actual, calculamos la distancia
                              if (_isCombatStarted &&
                                  _combatants[_turnIndex] == details.data) {
                                int dx = (nx - details.data.gridPosition.dx)
                                    .abs()
                                    .toInt();
                                int dy = (ny - details.data.gridPosition.dy)
                                    .abs()
                                    .toInt();
                                // Implementación simplificada de distancia de Manhattan: suma de desplazamientos x e y
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
                                // Capa de fondo: Dibujado de las líneas de la cuadrícula
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
                                // Capa superior: Renderizado de todas las fichas activas
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
            // Panel informativo de la criatura que tiene el turno activo
            if (_isCombatStarted && _combatants.isNotEmpty)
              _buildActiveCreatureDetails(),
            // Barra inferior con la lista completa de iniciativa y HP rápido
            _buildInitiativeBar(),
          ],
        ),
      ),
    );
  }

  /// Construye el panel con las acciones, reacciones y movimiento de la criatura activa.
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
              Expanded(
                child: Text(
                  "TURNO DE: ${active.name?.toUpperCase()}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  // Icono y contador de movimiento recorrido frente al máximo permitido
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
                  // Botón para deshacer el movimiento del turno actual
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
                  // Listado de Acciones normales del monstruo
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
                  // Listado de Reacciones
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
                  // Acciones Legendarias (si la criatura es de tipo jefe)
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

  /// Construye el widget interactivo (ficha) para un combatiente.
  /// Incluye lógica de arrastre (Draggable) y toque para gestión rápida.
  Widget _buildMonsterToken(Combatant c, double cellSize) {
    bool isCurrentTurn = _combatants.isNotEmpty && _combatants[_turnIndex] == c;
    int multiplier = _getSizeMultiplier(c.monster.size);

    return Positioned(
      left: c.gridPosition.dx * cellSize,
      top: c.gridPosition.dy * cellSize,
      child: Draggable<Combatant>(
        data: c,
        // Centra la ficha bajo el dedo/puntero al empezar a arrastrar
        dragAnchorStrategy: (draggable, context, position) =>
            Offset(cellSize * multiplier / 2, cellSize * multiplier / 2),
        // Imagen que "vuela" mientras arrastramos
        feedback: _tokenCircle(c, cellSize * multiplier, true, opacity: 0.8),
        // Lo que queda en el tablero mientras la ficha está siendo arrastrada (opaco)
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _tokenCircle(c, cellSize * multiplier, false),
        ),
        child: GestureDetector(
          onTap: () => _showMonsterQuickAction(c),
          // El círculo visual de la ficha
          child: _tokenCircle(c, cellSize * multiplier, isCurrentTurn),
        ),
      ),
    );
  }

  /// Genera la representación visual circular o rectangular de la ficha.
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
          // Las criaturas medianas/pequeñas son circulares, las grandes usan un cuadrado redondeado
          shape: multiplier == 1 ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: multiplier > 1
              ? BorderRadius.circular(size * 0.1)
              : null,
          border: Border.all(
            // Resaltamos con color ámbar si es el turno de esta criatura
            color: highlighted ? Colors.amber : Colors.black87,
            width: highlighted ? 3 : 1.5,
          ),
        ),
        child: ClipOval(
          child: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: _getMonsterImage(c.monster),
            // Fallback si no hay imagen: inicial del nombre
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

  /// Resuelve la imagen del monstruo desde diversas fuentes (URL completa, API base o archivo local).
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

  /// Crea la franja inferior horizontal que muestra el orden de iniciativa.
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

  /// Diálogo de configuración para redimensionar la cuadrícula del tablero.
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
                  // Al cambiar el tamaño, reubicamos las fichas que hayan quedado fuera de los nuevos límites
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

  /// Muestra el listado de criaturas en cola para poder añadirlas al combate activo.
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
                          // Permite quitar un monstruo de la cola sin añadirlo a la batalla
                          await BattleQueueService().removeFromQueue(entry.key);
                          Navigator.pop(context);
                          _showAddMonsterDialog(); // Refrescamos el diálogo para ver el cambio
                        },
                      ),
                      onTap: () {
                        // Añade el monstruo seleccionado al campo de batalla
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

  /// Despliega un panel inferior para realizar ajustes rápidos a un combatiente (HP, Iniciativa, Reacciones).
  void _showMonsterQuickAction(Combatant c) {
    // Controladores para sincronizar los campos de texto con el estado del combatiente
    final hpEditController = TextEditingController(
      text: c.currentHp.toString(),
    );
    final initiativeEditController = TextEditingController(
      text: c.initiative.toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el panel suba cuando aparece el teclado
      builder: (context) => StatefulBuilder(
        builder: (context, setPanelState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Ajuste dinámico por teclado
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
                // Visualización de la Clase de Armadura (AC)
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

                // --- Control de Puntos de Vida (HP) ---
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
                    // Botón para restar 1 HP
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        setState(() => c.currentHp--); // Cambia el estado global
                        setPanelState(() => hpEditController.text = c.currentHp.toString()); // Refresca el panel local
                      },
                    ),
                    // Campo para editar el HP numéricamente
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
                    // Botón para sumar 1 HP
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                      onPressed: () {
                        setState(() => c.currentHp++);
                        setPanelState(() => hpEditController.text = c.currentHp.toString());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // --- Gestión de la Iniciativa ---
                // Permite corregir el orden de turnos manualmente
                TextField(
                  controller: initiativeEditController,
                  decoration: const InputDecoration(
                    labelText: "Iniciativa",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      c.initiative = int.tryParse(val) ?? 0;
                      // El reordenamiento es automático y en tiempo real
                      _sortInitiative(); 
                    });
                  },
                  onSubmitted: (val) {
                    Navigator.pop(context);
                  },
                ),
                // Panel informativo de Reacciones (útil para que el DM no las olvide)
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
                // Opción para eliminar permanentemente a la criatura de esta batalla (ej: si muere)
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

/// Pintor personalizado para dibujar la rejilla del tablero táctico.
class GridPainter extends CustomPainter {
  final double cellSize; // Tamaño lateral de cada celda en píxeles
  final int gridCount; // Cantidad de celdas por lado (cuadrícula N x N)
  GridPainter({required this.cellSize, required this.gridCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 1;

    // Dibujamos líneas equidistantes para formar la rejilla
    for (double i = 0; i <= gridCount * cellSize; i += cellSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, gridCount * cellSize), paint);
      canvas.drawLine(Offset(0, i), Offset(gridCount * cellSize, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) =>
      oldDelegate.cellSize != cellSize || oldDelegate.gridCount != gridCount;
}
