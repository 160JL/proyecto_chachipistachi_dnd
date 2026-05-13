import 'package:flutter/material.dart';
import 'dart:io';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/service/connection_service.dart';
import 'package:proyecto_chachipistachi_dnd/service/monster_storage_service.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_detail_screen.dart';

/// Pantalla unificada para mostrar listas de monstruos (API o Repositorio Local).
/// Permite buscar, filtrar por múltiples criterios y navegar a los detalles.
class MonsterListScreen extends StatefulWidget {
  final bool isLocal; // True para repositorio local, false para API.

  const MonsterListScreen({super.key, required this.isLocal});

  @override
  State<MonsterListScreen> createState() => _MonsterListScreenState();
}

class _MonsterListScreenState extends State<MonsterListScreen> {
  // Manejador del estado de carga de datos (Future para manejar asincronía).
  late Future<dynamic> _futureData;

  // Controlador para el campo de búsqueda por texto.
  final TextEditingController _searchController = TextEditingController();

  // Estados de los filtros seleccionados por el usuario.
  String _selectedType = "Todos";
  String _selectedSize = "Todos";
  String _selectedAlign = "Todos";
  List<String> _selectedVulns = [];
  List<String> _selectedRes = [];
  List<String> _selectedImms = [];

  // Listas de opciones para los desplegables y chips de filtrado.
  final List<String> _types = [
    "Todos",
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
    "Todos",
    "Tiny",
    "Small",
    "Medium",
    "Large",
    "Huge",
    "Gargantuan",
  ];
  final List<String> _alignments = [
    "Todos",
    "lawful",
    "neutral",
    "chaotic",
    "good",
    "evil",
    "unaligned",
  ];
  final List<String> _damageTypes = [
    "acid",
    "bludgeoning",
    "cold",
    "fire",
    "force",
    "lightning",
    "necrotic",
    "piercing",
    "poison",
    "psychic",
    "radiant",
    "slashing",
    "thunder",
  ];

  @override
  void initState() {
    super.initState();
    _cargarDatos(); // Carga inicial al entrar en la pantalla.
  }

  /// Dispara la carga de datos desde el origen correspondiente (Local o API).
  void _cargarDatos({bool forceRefresh = false}) {
    setState(() {
      if (widget.isLocal) {
        // Carga desde SharedPreferences con filtrado en memoria.
        _futureData = MonsterStorageService().getMonsters().then((list) {
          return list.where((m) {
            final nameMatch = (m.name ?? "").toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
            final typeMatch =
                _selectedType == "Todos" ||
                (m.type?.toLowerCase() == _selectedType.toLowerCase());
            final sizeMatch =
                _selectedSize == "Todos" || m.size == _selectedSize;
            final alignMatch =
                _selectedAlign == "Todos" ||
                (m.alignment?.toLowerCase().contains(
                      _selectedAlign.toLowerCase(),
                    ) ??
                    false);

            // Lógica AND para filtros múltiples: la criatura debe cumplir con TODOS los seleccionados.
            final vulnMatch =
                _selectedVulns.isEmpty ||
                _selectedVulns.every(
                  (v) =>
                      m.damageVulnerabilities?.any(
                        (mv) => mv.toLowerCase().contains(v.toLowerCase()),
                      ) ??
                      false,
                );
            final resMatch =
                _selectedRes.isEmpty ||
                _selectedRes.every(
                  (r) =>
                      m.damageResistances?.any(
                        (mr) => mr.toLowerCase().contains(r.toLowerCase()),
                      ) ??
                      false,
                );
            final immMatch =
                _selectedImms.isEmpty ||
                _selectedImms.every(
                  (imm) =>
                      m.damageImmunities?.any(
                        (mimm) =>
                            mimm.toLowerCase().contains(imm.toLowerCase()),
                      ) ??
                      false,
                );

            return nameMatch &&
                typeMatch &&
                sizeMatch &&
                alignMatch &&
                vulnMatch &&
                resMatch &&
                immMatch;
          }).toList();
        });
      } else {
        // Carga desde el servicio de red (API remota).
        _futureData = ConnectionService().fetchEventos(
          forceRefresh: forceRefresh,
          name: _searchController.text,
          type: _selectedType,
          size: _selectedSize,
          alignment: _selectedAlign,
          vulnerability: _selectedVulns.isNotEmpty
              ? _selectedVulns.join(',')
              : "Todos",
          resistance: _selectedRes.isNotEmpty
              ? _selectedRes.join(',')
              : "Todos",
          immunity: _selectedImms.isNotEmpty
              ? _selectedImms.join(',')
              : "Todos",
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isLocal ? 'Repositorio Local' : 'Bestiario API'),
        actions: [
          // Botón para refrescar la lista (fuerza descarga en API, recarga en local).
          TextButton.icon(
            onPressed: () => _cargarDatos(forceRefresh: !widget.isLocal),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "ACTUALIZAR",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          // Sección superior con barra de búsqueda y filtros.
          Expanded(
            child: FutureBuilder<dynamic>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                // Normalización de resultados según el origen.
                final List results = widget.isLocal
                    ? snapshot.data
                    : (snapshot.data as MonsterList).results ?? [];

                if (results.isEmpty) {
                  return const Center(
                    child: Text("No se encontraron criaturas."),
                  );
                }

                return ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    if (widget.isLocal) {
                      // Tarjeta para criatura del repositorio (con opción de borrar).
                      final Monster m = item;
                      return _buildMonsterCard(
                        m.name ?? "",
                        m.size ?? "",
                        m.type ?? "",
                        m,
                        index,
                        m.image,
                      );
                    } else {
                      // Tarjeta para criatura de la API.
                      final String indexName = item["index"] ?? "";
                      final String name = item["name"] ?? "";
                      final String url = item["url"] ?? "";
                      return _buildApiCard(name, url, indexName);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el panel de búsqueda y el desplegable de filtros avanzados.
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Colors.brown[50],
      child: Column(
        children: [
          // Campo de búsqueda por texto (nombre).
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar por nombre...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _cargarDatos();
                },
                icon: const Icon(Icons.clear, size: 20),
                label: const Text("LIMPIAR", style: TextStyle(fontSize: 12)),
              ),
            ),
            onChanged: (_) => widget.isLocal ? _cargarDatos() : null,
            // Filtra en tiempo real solo en local.
            onSubmitted: (_) => _cargarDatos(),
          ),
          const SizedBox(height: 8),
          // Sección expandible para filtros de atributos y daños.
          ExpansionTile(
            title: const Text(
              "Filtros Avanzados",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            leading: const Icon(Icons.filter_list, color: Colors.brown),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            "Tipo",
                            _selectedType,
                            _types,
                            (v) => setState(() => _selectedType = v!),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDropdown(
                            "Tamaño",
                            _selectedSize,
                            _sizes,
                            (v) => setState(() => _selectedSize = v!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      "Alineamiento",
                      _selectedAlign,
                      _alignments,
                      (v) => setState(() => _selectedAlign = v!),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Vulnerabilidades",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    _buildMultiSelectChips(
                      _damageTypes,
                      _selectedVulns,
                      (list) => setState(() => _selectedVulns = list),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Resistencias",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    _buildMultiSelectChips(
                      _damageTypes,
                      _selectedRes,
                      (list) => setState(() => _selectedRes = list),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Inmunidades",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    _buildMultiSelectChips(
                      _damageTypes,
                      _selectedImms,
                      (list) => setState(() => _selectedImms = list),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _cargarDatos,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("APLICAR FILTROS"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Crea un selector desplegable estándar (Dropdown).
  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
      items: items
          .map(
            (i) => DropdownMenuItem(
              value: i,
              child: Text(i, style: const TextStyle(fontSize: 13)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  /// Crea un panel de etiquetas (chips) para selección múltiple.
  Widget _buildMultiSelectChips(
    List<String> options,
    List<String> selected,
    ValueChanged<List<String>> onChanged,
  ) {
    return Wrap(
      spacing: 5,
      runSpacing: 0,
      children: options.map((option) {
        final isSelected = selected.contains(option);
        return FilterChip(
          label: Text(
            option,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
          selected: isSelected,
          selectedColor: Colors.brown,
          checkmarkColor: Colors.white,
          onSelected: (bool value) {
            List<String> newList = List.from(selected);
            if (value) {
              newList.add(option);
            } else {
              newList.remove(option);
            }
            onChanged(newList);
          },
        );
      }).toList(),
    );
  }

  /// Construye la tarjeta para un monstruo proveniente de la API remota.
  Widget _buildApiCard(String name, String url, String indexName) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: _buildApiImage(indexName),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: _MonsterSubtitle(url: url),
        // Carga el subtítulo de forma diferida.
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                MonsterDetailScreen(monsterUrl: url, monsterName: name),
          ),
        ),
      ),
    );
  }

  /// Construye la tarjeta para un monstruo del repositorio local.
  Widget _buildMonsterCard(
    String name,
    String size,
    String type,
    Monster monster,
    int index,
    String? image,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: _buildLocalImage(image),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("$size $type, ${monster.alignment}"),
        trailing: TextButton.icon(
          onPressed: () async {
            await MonsterStorageService().deleteMonster(index);
            _cargarDatos();
          },
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          label: const Text(
            "BORRAR",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () =>
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MonsterDetailScreen(
                  monsterName: name,
                  monster: monster,
                  monsterIndex: index,
                ),
              ),
            ).then((updated) {
              if (updated == true) _cargarDatos();
            }),
      ),
    );
  }

  /// Widget de imagen para la API (usa el servidor oficial de imágenes).
  Widget _buildApiImage(String indexName) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          "https://www.dnd5eapi.co/api/images/monsters/$indexName.png",
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.pets, color: Colors.grey),
        ),
      ),
    );
  }

  /// Widget de imagen para local (maneja archivos locales, URLs web y rutas API).
  Widget _buildLocalImage(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http') || imagePath.startsWith('/api')) {
        String url = imagePath.startsWith('http')
            ? imagePath
            : "https://www.dnd5eapi.co$imagePath";
        return Image.network(
          url,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.pets),
        );
      } else {
        final file = File(imagePath);
        if (file.existsSync())
          return Image.file(file, width: 50, height: 50, fit: BoxFit.cover);
      }
    }
    return const Icon(Icons.pets, size: 40, color: Colors.brown);
  }
}

/// Widget interno para cargar datos ligeros (subtítulo) sin bloquear el listado principal.
class _MonsterSubtitle extends StatelessWidget {
  final String url;

  const _MonsterSubtitle({required this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Monster>(
      future: ConnectionService().fetchMonsterDetail(url),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final m = snapshot.data!;
          return Text(
            "${m.size} ${m.type}, ${m.alignment}",
            style: const TextStyle(fontSize: 12),
          );
        }
        return const Text(
          "Cargando...",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        );
      },
    );
  }
}
