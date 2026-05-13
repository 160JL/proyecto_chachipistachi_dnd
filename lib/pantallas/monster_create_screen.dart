import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../models/monster.dart';
import '../service/monster_storage_service.dart';

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

  @override
  void initState() {
    super.initState();
    _initControllers(
      widget.baseMonster,
    ); // Inicializa con datos del monstruo base si existe.
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
        title: Text(
          widget.isEditing
              ? 'Editar: ${widget.baseMonster?.name}'
              : (widget.baseMonster != null
                    ? 'Usar como base: ${widget.baseMonster?.name}'
                    : 'Crear Nueva Criatura'),
        ),
        actions: [
          TextButton.icon(
            onPressed: _importJson,
            icon: const Icon(Icons.code, color: Colors.white),
            label: const Text(
              "IMPORTAR JSON",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Imagen",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.brown,
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
                      backgroundColor: Colors.brown[400],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),

              const Text(
                "Datos Básicos",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.brown,
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
                      onChanged: (val) => setState(() => _selectedSize = val!),
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
                      onChanged: (val) => setState(() => _selectedType = val!),
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
                      decoration: const InputDecoration(labelText: 'Hit Dice'),
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
              const Text(
                "Velocidad",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.brown,
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
              const Text(
                "Atributos",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.brown,
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
              const Text(
                "Desafío y XP",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.brown,
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
              const Text(
                "Sentidos",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.brown,
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
              const Text(
                "Otros",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.brown,
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
              _buildComplexListEditor<SpecialAbility>(
                "Habilidades Especiales",
                _specialAbilities,
                (name, desc) => SpecialAbility(name: name, desc: desc),
              ),
              const SizedBox(height: 20),
              _buildComplexListEditor<MonsterAction>(
                "Acciones",
                _actions,
                (name, desc) => MonsterAction(name: name, desc: desc),
              ),
              const SizedBox(height: 20),
              _buildComplexListEditor<LegendaryAction>(
                "Acciones Legendarias",
                _legendaryActions,
                (name, desc) => LegendaryAction(name: name, desc: desc),
              ),
              const SizedBox(height: 20),
              _buildComplexListEditor<MonsterReaction>(
                "Reacciones",
                _reactions,
                (name, desc) => MonsterReaction(name: name, desc: desc),
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
                  backgroundColor: Colors.brown[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye la previsualización de la imagen cargada (Network, File o API).
  Widget _buildImagePreview() {
    if (_imageFile != null)
      return Center(
        child: Image.file(_imageFile!, height: 150, fit: BoxFit.contain),
      );
    if (_imageController.text.startsWith('http'))
      return Center(
        child: Image.network(
          _imageController.text,
          height: 150,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 80),
        ),
      );
    if (_imageController.text.startsWith('/api'))
      return Center(
        child: Image.network(
          "https://www.dnd5eapi.co${_imageController.text}",
          height: 150,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.broken_image, size: 80),
        ),
      );
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
          activeColor: Colors.brown,
          onChanged: (val) => onChanged(val.round()),
        ),
      ],
    );
  }

  /// Constructor genérico para listas de habilidades o acciones editables.
  Widget _buildComplexListEditor<T>(
    String title,
    List<T> list,
    T Function(String name, String desc) creator,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.brown,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showItemDialog(title, "", "", (name, desc) {
                setState(() => list.add(creator(name, desc)));
              }),
              icon: const Icon(Icons.add_circle, color: Colors.brown),
              label: const Text(
                "AÑADIR",
                style: TextStyle(
                  color: Colors.brown,
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
            onTap: () =>
                _showItemDialog(title, item.name, item.desc, (name, desc) {
                  setState(() {
                    if (T == SpecialAbility)
                      list[idx] = SpecialAbility(name: name, desc: desc) as T;
                    if (T == MonsterAction)
                      list[idx] = MonsterAction(name: name, desc: desc) as T;
                    if (T == LegendaryAction)
                      list[idx] = LegendaryAction(name: name, desc: desc) as T;
                    if (T == MonsterReaction)
                      list[idx] = MonsterReaction(name: name, desc: desc) as T;
                  });
                }),
          );
        }),
      ],
    );
  }

  /// Muestra un diálogo para editar o crear un elemento con Nombre y Descripción.
  void _showItemDialog(
    String title,
    String? initialName,
    String? initialDesc,
    Function(String, String) onSave,
  ) {
    final nameCol = TextEditingController(text: initialName);
    final descCol = TextEditingController(text: initialDesc);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar $title"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCol,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: descCol,
              decoration: const InputDecoration(labelText: "Descripción"),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              onSave(nameCol.text, descCol.text);
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }
}
