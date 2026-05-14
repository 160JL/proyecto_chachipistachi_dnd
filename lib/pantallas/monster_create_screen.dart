import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import '../models/monster.dart';
import '../models/monster_ability_registry.dart';
import '../service/monster_storage_service.dart';
import '../service/monster_ability_registry_service.dart';
import '../service/monster_randomizer_service.dart';

/// Pantalla para la creación de nuevas criaturas personalizadas.
/// Permite definir todos los atributos y guardarlos de forma local persistente.
class MonsterCreateScreen extends StatefulWidget {
  final Monster? baseMonster; // Monstruo opcional para usar como plantilla.
  final bool isEditing; // Indica si estamos editando una criatura guardada.
  final int? monsterIndex; // Índice en la lista local para actualizar.

  const MonsterCreateScreen({
    super.key,
    this.baseMonster,
    this.isEditing = false,
    this.monsterIndex,
  });

  @override
  State<MonsterCreateScreen> createState() => _MonsterCreateScreenState();
}

class _MonsterCreateScreenState extends State<MonsterCreateScreen> {
  // Clave global para validación del formulario.
  final _formKey = GlobalKey<FormState>();

  // Herramienta para seleccionar imágenes de la galería del sistema.
  final ImagePicker _picker = ImagePicker();

  // Listados de opciones estándar para los selectores desplegables.
  final List<String> _types = [
    "Aberration",
    "Beast",
    "Celestial",
    "Construct",
    "Dragon",
    "Elemental",
    "Fey",
    "Fiend",
    "Giant",
    "Humanoid",
    "Monstrosity",
    "Ooze",
    "Plant",
    "Undead",
  ];
  final List<String> _sizes = [
    "Tiny",
    "Small",
    "Medium",
    "Large",
    "Huge",
    "Gargantuan",
  ];

  // Partes para el alineamiento (se eligen en dos desplegables separados).
  final List<String> _alignPart1 = [
    "unaligned",
    "lawful",
    "neutral",
    "chaotic",
  ];
  final List<String> _alignPart2 = ["good", "neutral", "evil"];

  // Controladores para los campos de texto del formulario.
  late TextEditingController _nameController;
  late String _selectedType;
  late String _selectedSize;
  late String _selectedAlign1;
  late String _selectedAlign2;

  late TextEditingController _hpController;
  late TextEditingController _acController;
  late TextEditingController _acTypeController;
  late TextEditingController _imageController;
  late TextEditingController _hitDiceController;
  late TextEditingController _hpRollController;
  late TextEditingController _walkSpeedController;
  late TextEditingController _flySpeedController;
  late TextEditingController _swimSpeedController;
  late TextEditingController _languagesController;
  late TextEditingController _crController;
  late TextEditingController _xpController;
  late TextEditingController _pbController;

  // Controladores para los sentidos de la criatura.
  late TextEditingController _blindsightController;
  late TextEditingController _darkvisionController;
  late TextEditingController _tremorsenseController;
  late TextEditingController _truesightController;
  late TextEditingController _passivePerceptionController;

  // Controladores para listas de daños (separadas por comas).
  late TextEditingController _vulnerabilitiesController;
  late TextEditingController _resistancesController;
  late TextEditingController _immunitiesController;

  File? _imageFile; // Archivo de imagen seleccionado localmente.

  // Valores numéricos para los 6 atributos principales de D&D.
  late int _str, _dex, _con, _int, _wis, _cha;

  // Listas para manejar elementos complejos (habilidades y acciones).
  late List<SpecialAbility> _specialAbilities;
  late List<MonsterAction> _actions;
  late List<LegendaryAction> _legendaryActions;
  late List<MonsterReaction> _reactions;

  // Registro de habilidades cargado desde SharedPreferences para autocompletado.
  List<AbilityRegistryEntry> _registryEntries = [];

  @override
  void initState() {
    super.initState();
    _initControllers(
      widget.baseMonster,
    ); // Inicializa con datos del monstruo base si existe.
    _loadRegistryEntries(); // Carga el registro de habilidades para sugerencias.
  }

  /// Carga las entradas del registro de habilidades desde SharedPreferences.
  /// Se usa para alimentar las sugerencias de autocompletado en los diálogos
  /// de creación/edición de acciones, reacciones, etc.
  Future<void> _loadRegistryEntries() async {
    final entries = await MonsterAbilityRegistryService().getAllEntries();
    if (mounted) {
      setState(() => _registryEntries = entries);
    }
  }

  /// Inicializa los controladores con los datos de un monstruo (o vacíos si es creación de cero).
  void _initControllers(Monster? monster) {
    _nameController = TextEditingController(text: monster?.name ?? '');

    // Configura valores iniciales de Tipo y Tamaño.
    _selectedType = _types.contains(monster?.type)
        ? monster!.type!
        : _types[1]; // Beast por defecto.
    _selectedSize = _sizes.contains(monster?.size)
        ? monster!.size!
        : _sizes[2]; // Medium por defecto.

    // Procesa el alineamiento compuesto (ej: "lawful good") para separarlo en dos selectores.
    String fullAlign = (monster?.alignment ?? 'neutral').toLowerCase();
    _selectedAlign1 = "neutral";
    _selectedAlign2 = "neutral";

    if (fullAlign.contains("unaligned")) {
      _selectedAlign1 = "unaligned";
    } else {
      for (var part in _alignPart1) {
        if (fullAlign.contains(part)) {
          _selectedAlign1 = part;
          break;
        }
      }
      for (var part in _alignPart2) {
        if (fullAlign.contains(part)) {
          _selectedAlign2 = part;
          break;
        }
      }
    }

    _hpController = TextEditingController(
      text: monster?.hitPoints?.toString() ?? '',
    );
    _imageController = TextEditingController(text: monster?.image ?? '');
    _hitDiceController = TextEditingController(text: monster?.hitDice ?? '');
    _hpRollController = TextEditingController(
      text: monster?.hitPointsRoll ?? '',
    );
    _walkSpeedController = TextEditingController(
      text: monster?.speed?.walk ?? '',
    );
    _flySpeedController = TextEditingController(
      text: monster?.speed?.fly ?? '',
    );
    _swimSpeedController = TextEditingController(
      text: monster?.speed?.swim ?? '',
    );
    _languagesController = TextEditingController(
      text: monster?.languages ?? '',
    );
    _crController = TextEditingController(
      text: monster?.challengeRating?.toString() ?? '',
    );
    _xpController = TextEditingController(text: monster?.xp?.toString() ?? '');
    _pbController = TextEditingController(
      text: monster?.proficiencyBonus?.toString() ?? '',
    );

    _blindsightController = TextEditingController(
      text: monster?.senses?.blindsight ?? '',
    );
    _darkvisionController = TextEditingController(
      text: monster?.senses?.darkvision ?? '',
    );
    _tremorsenseController = TextEditingController(
      text: monster?.senses?.tremorsense ?? '',
    );
    _truesightController = TextEditingController(
      text: monster?.senses?.truesight ?? '',
    );
    _passivePerceptionController = TextEditingController(
      text: monster?.senses?.passivePerception?.toString() ?? '',
    );

    _vulnerabilitiesController = TextEditingController(
      text: monster?.damageVulnerabilities?.join(', ') ?? '',
    );
    _resistancesController = TextEditingController(
      text: monster?.damageResistances?.join(', ') ?? '',
    );
    _immunitiesController = TextEditingController(
      text: monster?.damageImmunities?.join(', ') ?? '',
    );

    _specialAbilities = List.from(monster?.specialAbilities ?? []);
    _actions = List.from(monster?.actions ?? []);
    _legendaryActions = List.from(monster?.legendaryActions ?? []);
    _reactions = List.from(monster?.reactions ?? []);

    int? baseAc = monster?.armorClass != null && monster!.armorClass!.isNotEmpty
        ? monster.armorClass![0].value
        : 10;
    _acController = TextEditingController(text: baseAc.toString());

    String? baseAcType =
        monster?.armorClass != null && monster!.armorClass!.isNotEmpty
        ? monster.armorClass![0].type
        : 'natural';
    _acTypeController = TextEditingController(text: baseAcType);

    _str = monster?.strength ?? 10;
    _dex = monster?.dexterity ?? 10;
    _con = monster?.constitution ?? 10;
    _int = monster?.intelligence ?? 10;
    _wis = monster?.wisdom ?? 10;
    _cha = monster?.charisma ?? 10;

    // Intenta cargar la imagen local si la ruta guardada apunta al disco.
    if (monster?.image != null &&
        !monster!.image!.startsWith('http') &&
        !monster.image!.startsWith('/api')) {
      _imageFile = File(monster.image!);
      if (!_imageFile!.existsSync()) _imageFile = null;
    } else {
      _imageFile = null;
    }
  }

  @override
  void dispose() {
    // Limpieza de controladores para evitar fugas de memoria.
    _nameController.dispose();
    _hpController.dispose();
    _acController.dispose();
    _acTypeController.dispose();
    _imageController.dispose();
    _hitDiceController.dispose();
    _hpRollController.dispose();
    _walkSpeedController.dispose();
    _flySpeedController.dispose();
    _swimSpeedController.dispose();
    _languagesController.dispose();
    _crController.dispose();
    _xpController.dispose();
    _pbController.dispose();
    _blindsightController.dispose();
    _darkvisionController.dispose();
    _tremorsenseController.dispose();
    _truesightController.dispose();
    _passivePerceptionController.dispose();
    _vulnerabilitiesController.dispose();
    _resistancesController.dispose();
    _immunitiesController.dispose();
    super.dispose();
  }

  /// Permite seleccionar una imagen de la galería local.
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _imageController.text = image.path;
      });
    }
  }

  /// Muestra un diálogo para importar datos masivos pegando un JSON completo.
  void _importJson() {
    final jsonCol = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Importar desde JSON"),
        content: TextField(
          controller: jsonCol,
          decoration: const InputDecoration(
            hintText: "Pega el JSON completo de la criatura aquí",
          ),
          maxLines: 10,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              try {
                final Map<String, dynamic> data = jsonDecode(jsonCol.text);
                final monster = Monster.fromJson(data);
                setState(() {
                  _initControllers(monster);
                });
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error en el formato JSON: $e")),
                );
              }
            },
            child: const Text("Importar"),
          ),
        ],
      ),
    );
  }

  /// Recopila todos los datos del formulario y los guarda de forma persistente.
  void _saveMonster() async {
    if (_formKey.currentState!.validate()) {
      // Recomponer el alineamiento desde las dos partes seleccionadas.
      String alignment = _selectedAlign1 == "unaligned"
          ? "unaligned"
          : "$_selectedAlign1 $_selectedAlign2";

      final newMonster = Monster(
        name: _nameController.text,
        size: _selectedSize,
        type: _selectedType,
        alignment: alignment,
        hitPoints: int.tryParse(_hpController.text) ?? 10,
        hitDice: _hitDiceController.text,
        hitPointsRoll: _hpRollController.text,
        armorClass: [
          ArmorClass(
            value: int.tryParse(_acController.text) ?? 10,
            type: _acTypeController.text.isEmpty
                ? 'natural'
                : _acTypeController.text,
          ),
        ],
        strength: _str,
        dexterity: _dex,
        constitution: _con,
        intelligence: _int,
        wisdom: _wis,
        charisma: _cha,
        speed: Speed(
          walk: _walkSpeedController.text,
          fly: _flySpeedController.text,
          swim: _swimSpeedController.text,
        ),
        languages: _languagesController.text,
        challengeRating: num.tryParse(_crController.text) ?? 0,
        xp: int.tryParse(_xpController.text) ?? 0,
        proficiencyBonus: int.tryParse(_pbController.text) ?? 0,
        senses: Senses(
          blindsight: _blindsightController.text,
          darkvision: _darkvisionController.text,
          tremorsense: _tremorsenseController.text,
          truesight: _truesightController.text,
          passivePerception: int.tryParse(_passivePerceptionController.text),
        ),
        damageVulnerabilities: _vulnerabilitiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        damageResistances: _resistancesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        damageImmunities: _immunitiesController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        image: _imageController.text,
        specialAbilities: _specialAbilities,
        actions: _actions,
        legendaryActions: _legendaryActions,
        reactions: _reactions,
        proficiencies: widget.baseMonster?.proficiencies,
        conditionImmunities: widget.baseMonster?.conditionImmunities,
        index: _nameController.text.toLowerCase().replaceAll(' ', '-'),
        url: widget.baseMonster?.url,
      );

      // Elige si actualizar una entrada existente o crear una nueva.
      if (widget.isEditing && widget.monsterIndex != null) {
        await MonsterStorageService().updateMonster(
          widget.monsterIndex!,
          newMonster,
        );
      } else {
        await MonsterStorageService().saveMonster(newMonster);
      }

      // Guarda las habilidades de la criatura en el registro persistente.
      // Se usa el CR y nombre de la criatura para etiquetar cada entrada.
      // El servicio comprobará duplicados (mismo nombre + mismo CR) antes de insertar.
      final num cr = newMonster.challengeRating ?? 0;
      final String monsterName = newMonster.name ?? 'Custom';
      final List<AbilityRegistryEntry> newRegistryEntries = [];

      // Registra las acciones de combate estándar.
      for (final a in (newMonster.actions ?? [])) {
        newRegistryEntries.add(
          AbilityRegistryEntry(
            name: a.name ?? '',
            desc: a.desc ?? '',
            category: 'action',
            challengeRating: cr,
            monsterName: monsterName,
          ),
        );
      }
      // Registra las reacciones de combate.
      for (final r in (newMonster.reactions ?? [])) {
        newRegistryEntries.add(
          AbilityRegistryEntry(
            name: r.name ?? '',
            desc: r.desc ?? '',
            category: 'reaction',
            challengeRating: cr,
            monsterName: monsterName,
          ),
        );
      }
      // Registra las acciones legendarias.
      for (final la in (newMonster.legendaryActions ?? [])) {
        newRegistryEntries.add(
          AbilityRegistryEntry(
            name: la.name ?? '',
            desc: la.desc ?? '',
            category: 'legendary_action',
            challengeRating: cr,
            monsterName: monsterName,
          ),
        );
      }
      // Registra las habilidades especiales / rasgos pasivos.
      for (final sa in (newMonster.specialAbilities ?? [])) {
        newRegistryEntries.add(
          AbilityRegistryEntry(
            name: sa.name ?? '',
            desc: sa.desc ?? '',
            category: 'special_ability',
            challengeRating: cr,
            monsterName: monsterName,
          ),
        );
      }

      // Envía las nuevas entradas al servicio con deduplicación.
      if (newRegistryEntries.isNotEmpty) {
        await MonsterAbilityRegistryService().addEntriesFromMonster(
          newRegistryEntries,
        );
        // Recarga las entradas para que las sugerencias estén actualizadas.
        _loadRegistryEntries();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'Criatura actualizada con éxito'
                  : 'Criatura guardada con éxito',
            ),
          ),
        );
        Navigator.pop(context, true); // Indica éxito a la pantalla anterior.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          widget.isEditing
              ? 'Editar: ${widget.baseMonster?.name}'
              : (widget.baseMonster != null
                    ? 'Usar como base: ${widget.baseMonster?.name}'
                    : 'Crear Nueva Criatura'),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showRandomGeneratorDialog,
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            label: const Text(
              "Aleatorio",
              style: TextStyle(color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.code, color: Colors.white),
            tooltip: "Importar Json",
            onPressed: _importJson,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  "Imagen",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                _buildImagePreview(),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _imageController,
                        decoration: const InputDecoration(
                          labelText: 'URL de imagen o ruta local',
                        ),
                        onChanged: (val) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text("GALERÍA"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),

                Text(
                  "Datos Básicos",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'El nombre es obligatorio'
                      : null,
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSize,
                        decoration: const InputDecoration(labelText: "Tamaño"),
                        items: _sizes
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedSize = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(labelText: "Tipo"),
                        items: _types
                            .map(
                              (t) => DropdownMenuItem(value: t, child: Text(t)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedType = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Alineamiento",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedAlign1,
                        items: _alignPart1
                            .map(
                              (a) => DropdownMenuItem(value: a, child: Text(a)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedAlign1 = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedAlign2,
                        items: _alignPart2
                            .map(
                              (a) => DropdownMenuItem(value: a, child: Text(a)),
                            )
                            .toList(),
                        onChanged: _selectedAlign1 == "unaligned"
                            ? null
                            : (val) => setState(() => _selectedAlign2 = val!),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _hpController,
                        decoration: const InputDecoration(labelText: 'HP'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _acController,
                        decoration: const InputDecoration(
                          labelText: 'AC (Valor)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _acTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de AC (ej: natural, armor)',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hitDiceController,
                        decoration: const InputDecoration(
                          labelText: 'Hit Dice',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _hpRollController,
                        decoration: const InputDecoration(labelText: 'HP Roll'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  "Velocidad",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _walkSpeedController,
                        decoration: const InputDecoration(labelText: 'Walk'),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextFormField(
                        controller: _flySpeedController,
                        decoration: const InputDecoration(labelText: 'Fly'),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: TextFormField(
                        controller: _swimSpeedController,
                        decoration: const InputDecoration(labelText: 'Swim'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  "Atributos",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                _buildStatSelector(
                  "Fuerza (STR)",
                  _str,
                  (val) => setState(() => _str = val),
                ),
                _buildStatSelector(
                  "Destreza (DEX)",
                  _dex,
                  (val) => setState(() => _dex = val),
                ),
                _buildStatSelector(
                  "Constitución (CON)",
                  _con,
                  (val) => setState(() => _con = val),
                ),
                _buildStatSelector(
                  "Inteligencia (INT)",
                  _int,
                  (val) => setState(() => _int = val),
                ),
                _buildStatSelector(
                  "Sabiduría (WIS)",
                  _wis,
                  (val) => setState(() => _wis = val),
                ),
                _buildStatSelector(
                  "Carisma (CHA)",
                  _cha,
                  (val) => setState(() => _cha = val),
                ),

                const SizedBox(height: 20),
                Text(
                  "Desafío y XP",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _crController,
                        decoration: const InputDecoration(labelText: 'CR'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _xpController,
                        decoration: const InputDecoration(labelText: 'XP'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _pbController,
                        decoration: const InputDecoration(
                          labelText: 'Prof. Bonus',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Text(
                  "Sentidos",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextFormField(
                  controller: _blindsightController,
                  decoration: const InputDecoration(labelText: 'Blindsight'),
                ),
                TextFormField(
                  controller: _darkvisionController,
                  decoration: const InputDecoration(labelText: 'Darkvision'),
                ),
                TextFormField(
                  controller: _tremorsenseController,
                  decoration: const InputDecoration(labelText: 'Tremorsense'),
                ),
                TextFormField(
                  controller: _truesightController,
                  decoration: const InputDecoration(labelText: 'Truesight'),
                ),
                TextFormField(
                  controller: _passivePerceptionController,
                  decoration: const InputDecoration(
                    labelText: 'Passive Perception',
                  ),
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 20),
                Text(
                  "Otros",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                TextFormField(
                  controller: _languagesController,
                  decoration: const InputDecoration(labelText: 'Idiomas'),
                ),
                TextFormField(
                  controller: _vulnerabilitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Vulnerabilidades',
                  ),
                ),
                TextFormField(
                  controller: _resistancesController,
                  decoration: const InputDecoration(labelText: 'Resistencias'),
                ),
                TextFormField(
                  controller: _immunitiesController,
                  decoration: const InputDecoration(labelText: 'Inmunidades'),
                ),

                const SizedBox(height: 20),
                // Editores para elementos de lista dinámicos.
                // Editores con autocompletado del registro, categorizados.
                _buildComplexListEditor<SpecialAbility>(
                  "Habilidades Especiales",
                  _specialAbilities,
                  (name, desc) => SpecialAbility(name: name, desc: desc),
                  'special_ability', // Categoría del registro.
                ),
                const SizedBox(height: 20),
                _buildComplexListEditor<MonsterAction>(
                  "Acciones",
                  _actions,
                  (name, desc) => MonsterAction(name: name, desc: desc),
                  'action', // Categoría del registro.
                ),
                const SizedBox(height: 20),
                _buildComplexListEditor<LegendaryAction>(
                  "Acciones Legendarias",
                  _legendaryActions,
                  (name, desc) => LegendaryAction(name: name, desc: desc),
                  'legendary_action', // Categoría del registro.
                ),
                const SizedBox(height: 20),
                _buildComplexListEditor<MonsterReaction>(
                  "Reacciones",
                  _reactions,
                  (name, desc) => MonsterReaction(name: name, desc: desc),
                  'reaction', // Categoría del registro.
                ),

                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _saveMonster,
                  icon: const Icon(Icons.save),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'GUARDAR CRIATURA',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye la previsualización de la imagen cargada (Network, File o API).
  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Center(
        child: Image.file(_imageFile!, height: 150, fit: BoxFit.contain),
      );
    }
    if (_imageController.text.startsWith('http')) {
      return Center(
        child: Image.network(
          _imageController.text,
          height: 150,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 80),
        ),
      );
    }
    if (_imageController.text.startsWith('/api')) {
      return Center(
        child: Image.network(
          "https://www.dnd5eapi.co${_imageController.text}",
          height: 150,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 80),
        ),
      );
    }
    return Container(
      height: 100,
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 50),
    );
  }

  /// Construye un selector de rango deslizante (Slider) para los atributos.
  Widget _buildStatSelector(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value", style: const TextStyle(fontSize: 14)),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 30,
          divisions: 29,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (val) => onChanged(val.round()),
        ),
      ],
    );
  }

  /// Constructor genérico para listas de habilidades o acciones editables.
  ///
  /// [title] — Título visible de la sección.
  /// [list] — Lista mutable de elementos del tipo genérico T.
  /// [creator] — Función factory para crear nuevos elementos del tipo T.
  /// [category] — Categoría del registro para filtrar sugerencias de autocompletado.
  Widget _buildComplexListEditor<T>(
    String title,
    List<T> list,
    T Function(String name, String desc) creator,
    String category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            TextButton.icon(
              // Abre el diálogo de creación con sugerencias de la categoría.
              onPressed: () => _showItemDialog(title, "", "", (name, desc) {
                setState(() => list.add(creator(name, desc)));
              }, category),
              icon: Icon(
                Icons.add_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                "AÑADIR",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        ...list.asMap().entries.map((entry) {
          int idx = entry.key;
          dynamic item = entry.value;
          return ListTile(
            title: Text(
              item.name ?? "Sin nombre",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              item.desc ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: TextButton.icon(
              onPressed: () => setState(() => list.removeAt(idx)),
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              label: const Text(
                "BORRAR",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
            // Abre el diálogo de edición con datos precargados y sugerencias.
            onTap: () =>
                _showItemDialog(title, item.name, item.desc, (name, desc) {
                  setState(() {
                    if (T == SpecialAbility) {
                      list[idx] = SpecialAbility(name: name, desc: desc) as T;
                    }
                    if (T == MonsterAction) {
                      list[idx] = MonsterAction(name: name, desc: desc) as T;
                    }
                    if (T == LegendaryAction) {
                      list[idx] = LegendaryAction(name: name, desc: desc) as T;
                    }
                    if (T == MonsterReaction) {
                      list[idx] = MonsterReaction(name: name, desc: desc) as T;
                    }
                  });
                }, category),
          );
        }),
      ],
    );
  }

  /// Muestra un diálogo para editar o crear un elemento con Nombre y Descripción.
  ///
  /// El campo de nombre incluye autocompletado que sugiere habilidades existentes
  /// del registro, filtradas por [category]. Al seleccionar una sugerencia,
  /// la descripción se auto-rellena con la del registro.
  ///
  /// [title] — Título del diálogo.
  /// [initialName] — Valor inicial del nombre (vacío para creación).
  /// [initialDesc] — Valor inicial de la descripción.
  /// [onSave] — Callback ejecutado al guardar con (nombre, descripción).
  /// [category] — Categoría del registro para filtrar sugerencias.
  void _showItemDialog(
    String title,
    String? initialName,
    String? initialDesc,
    Function(String, String) onSave,
    String category,
  ) {
    // Controller para la descripción (se auto-rellena al seleccionar sugerencia).
    final descCol = TextEditingController(text: initialDesc);
    // Referencia al controller del nombre, gestionado por el Autocomplete.
    TextEditingController? nameFieldController;

    // Filtra las sugerencias del registro por la categoría correspondiente.
    final List<AbilityRegistryEntry> suggestions = _registryEntries
        .where((e) => e.category == category)
        .toList();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text("Editar $title"),
        content: SizedBox(
          // Ancho fijo para que el Autocomplete tenga espacio para el overlay.
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campo de nombre con autocompletado del registro.
                Autocomplete<AbilityRegistryEntry>(
                  // Valor inicial para edición de elementos existentes.
                  initialValue: TextEditingValue(text: initialName ?? ''),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    // No mostrar sugerencias si el campo está vacío.
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<AbilityRegistryEntry>.empty();
                    }
                    // Filtra sugerencias que contengan el texto escrito.
                    return suggestions
                        .where(
                          (entry) => entry.name.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                        )
                        .take(8); // Máximo 8 sugerencias para no saturar.
                  },
                  // Texto mostrado en el campo al seleccionar una opción.
                  displayStringForOption: (entry) => entry.name,
                  onSelected: (AbilityRegistryEntry entry) {
                    // Al seleccionar, auto-rellena la descripción.
                    descCol.text = entry.desc;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        // Captura la referencia al controller para leer el texto al guardar.
                        nameFieldController = controller;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: "Nombre",
                            hintText: "Escribe para ver sugerencias...",
                          ),
                        );
                      },
                  // Personaliza la apariencia de la lista de sugerencias.
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: 280,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final entry = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                // Nombre de la habilidad en negrita.
                                title: Text(
                                  entry.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                // Criatura de origen y CR como contexto.
                                subtitle: Text(
                                  '${entry.monsterName} (CR ${entry.challengeRating})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                onTap: () => onSelected(entry),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                // Campo de descripción con texto libre.
                TextField(
                  controller: descCol,
                  decoration: const InputDecoration(labelText: "Descripción"),
                  maxLines: 5,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              // Usa el controller capturado del Autocomplete para leer el nombre.
              onSave(nameFieldController?.text ?? '', descCol.text);
              Navigator.pop(dialogContext);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo modal que permite al usuario configurar y generar
  /// una criatura de forma aleatoria basada en un Challenge Rating (CR) objetivo.
  ///
  /// El usuario puede seleccionar el CR y la cantidad deseada de:
  /// - Habilidades especiales
  /// - Acciones
  /// - Acciones legendarias
  /// - Reacciones
  void _showRandomGeneratorDialog() {
    if (_registryEntries.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Registro Vacío"),
          content: const Text(
            "No hay habilidades guardadas en el registro local. "
            "Es necesario consultar criaturas del bestiario (API) para "
            "llenar el registro antes de poder generar una criatura aleatoria.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cierra este diálogo
                Navigator.pushNamed(context, '/api'); // Navega a la API
              },
              child: const Text("Ir a la API"),
            ),
          ],
        ),
      );
      return;
    }

    num selectedCr = 1;
    int numSpecialAbilities = 0;
    int numActions = 2;
    int numLegendaryActions = 0;
    int numReactions = 0;

    // Lista de opciones de CR disponibles en D&D 5e (incluyendo fracciones)
    final crOptions = [0, 0.125, 0.25, 0.5, ...List.generate(30, (i) => i + 1)];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Generador Aleatorio"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<num>(
                      value: selectedCr,
                      decoration: const InputDecoration(
                        labelText: "CR Objetivo",
                      ),
                      items: crOptions.map((cr) {
                        String label = cr.toString();
                        if (cr == 0.125) label = "1/8";
                        if (cr == 0.25) label = "1/4";
                        if (cr == 0.5) label = "1/2";
                        return DropdownMenuItem<num>(
                          value: cr,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setStateDialog(() => selectedCr = val!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Habilidades Especiales: $numSpecialAbilities",
                          ),
                        ),
                        Slider(
                          value: numSpecialAbilities.toDouble(),
                          min: 0,
                          max: 5,
                          divisions: 5,
                          onChanged: (val) => setStateDialog(
                            () => numSpecialAbilities = val.toInt(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: Text("Acciones: $numActions")),
                        Slider(
                          value: numActions.toDouble(),
                          min: 0,
                          max: 5,
                          divisions: 5,
                          onChanged: (val) =>
                              setStateDialog(() => numActions = val.toInt()),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Acciones Legendarias: $numLegendaryActions",
                          ),
                        ),
                        Slider(
                          value: numLegendaryActions.toDouble(),
                          min: 0,
                          max: 5,
                          divisions: 5,
                          onChanged: (val) => setStateDialog(
                            () => numLegendaryActions = val.toInt(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: Text("Reacciones: $numReactions")),
                        Slider(
                          value: numReactions.toDouble(),
                          min: 0,
                          max: 5,
                          divisions: 5,
                          onChanged: (val) =>
                              setStateDialog(() => numReactions = val.toInt()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _generateRandomMonster(
                      selectedCr,
                      numSpecialAbilities,
                      numActions,
                      numLegendaryActions,
                      numReactions,
                    );
                  },
                  child: const Text("Generar"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Genera aleatoriamente las estadísticas y habilidades de una criatura
  /// basándose en los parámetros seleccionados en el diálogo.
  ///
  /// [cr] El Challenge Rating objetivo que determinará los atributos base.
  /// [numSpecialAbilities] Cantidad de habilidades especiales a generar.
  /// [numActions] Cantidad de acciones de combate a generar.
  /// [numLegendaryActions] Cantidad de acciones legendarias a generar.
  /// [numReactions] Cantidad de reacciones a generar.
  void _generateRandomMonster(
    num cr,
    int numSpecialAbilities,
    int numActions,
    int numLegendaryActions,
    int numReactions,
  ) {
    final monster = MonsterRandomizerService.generateRandomMonster(
      targetCr: cr,
      numSpecialAbilities: numSpecialAbilities,
      numActions: numActions,
      numLegendaryActions: numLegendaryActions,
      numReactions: numReactions,
      registryEntries: _registryEntries,
    );

    setState(() {
      _nameController.text = monster.name ?? "";
      _selectedSize = monster.size ?? _selectedSize;
      _selectedType = monster.type ?? _selectedType;

      String fullAlign = monster.alignment ?? "unaligned";
      if (fullAlign == "unaligned") {
        _selectedAlign1 = "unaligned";
        _selectedAlign2 = "neutral";
      } else {
        final parts = fullAlign.split(" ");
        if (parts.isNotEmpty) _selectedAlign1 = parts[0];
        if (parts.length > 1) _selectedAlign2 = parts[1];
      }

      _crController.text = monster.challengeRating?.toString() ?? "";
      _pbController.text = monster.proficiencyBonus?.toString() ?? "";
      if (monster.armorClass != null && monster.armorClass!.isNotEmpty) {
        _acController.text = monster.armorClass!.first.value?.toString() ?? "";
      }
      _xpController.text = monster.xp?.toString() ?? "";

      _hpController.text = monster.hitPoints?.toString() ?? "";
      _hitDiceController.text = monster.hitDice ?? "";
      _hpRollController.text = monster.hitPointsRoll ?? "";

      _str = monster.strength ?? 10;
      _dex = monster.dexterity ?? 10;
      _con = monster.constitution ?? 10;
      _int = monster.intelligence ?? 10;
      _wis = monster.wisdom ?? 10;
      _cha = monster.charisma ?? 10;

      _walkSpeedController.text = monster.speed?.walk ?? "";
      _flySpeedController.text = monster.speed?.fly ?? "";
      _swimSpeedController.text = monster.speed?.swim ?? "";

      _passivePerceptionController.text =
          monster.senses?.passivePerception?.toString() ?? "";
      _blindsightController.text = monster.senses?.blindsight ?? "";
      _darkvisionController.text = monster.senses?.darkvision ?? "";
      _tremorsenseController.text = monster.senses?.tremorsense ?? "";
      _truesightController.text = monster.senses?.truesight ?? "";

      _specialAbilities = List.from(monster.specialAbilities ?? []);
      _actions = List.from(monster.actions ?? []);
      _legendaryActions = List.from(monster.legendaryActions ?? []);
      _reactions = List.from(monster.reactions ?? []);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generada criatura aleatoria CR $cr')),
      );
    });
  }
}
