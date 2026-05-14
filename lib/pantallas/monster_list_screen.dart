import 'package:flutter/material.dart';
import 'dart:io';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/service/connection_service.dart';
import 'package:proyecto_chachipistachi_dnd/service/monster_storage_service.dart';
import 'package:proyecto_chachipistachi_dnd/service/monster_ability_registry_service.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_detail_screen.dart';

/// Pantalla unificada para mostrar listas de monstruos (API o Repositorio Local).
/// Permite buscar, filtrar por múltiples criterios (tipo, tamaño, alineamiento,
/// vulnerabilidades, resistencias e inmunidades) y navegar a los detalles.
class MonsterListScreen extends StatefulWidget {
  final bool
  isLocal; // Define el origen de datos: true para local, false para API.

  const MonsterListScreen({super.key, required this.isLocal});

  @override
  State<MonsterListScreen> createState() => _MonsterListScreenState();
}

class _MonsterListScreenState extends State<MonsterListScreen> {
  // Manejador del estado de carga de datos (Future para gestionar asincronía).
  late Future<dynamic> _futureData;

  // Controlador para gestionar el texto introducido en el buscador.
  final TextEditingController _searchController = TextEditingController();

  // Variables de estado para los filtros seleccionados por el usuario.
  String _selectedType = "Todos";
  String _selectedSize = "Todos";
  String _selectedAlign = "Todos";
  String _selectedCR = "Todos";
  String _sortBy = "Nombre (A-Z)";
  List<String> _selectedVulns = [];
  List<String> _selectedRes = [];
  List<String> _selectedImms = [];

  // Definición de las opciones disponibles para los filtros.
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
  final List<String> _crs = [
    "Todos",
    "0",
    "0.125",
    "0.25",
    "0.5",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10",
    "11",
    "12",
    "13",
    "14",
    "15",
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",
    "30",
  ];
  final List<String> _sortOptions = [
    "Nombre (A-Z)",
    "Nombre (Z-A)",
    "CR (Bajo-Alto)",
    "CR (Alto-Bajo)",
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
    _cargarDatos(); // Carga inicial de datos al instanciar la pantalla.
  }

  /// Gestiona la obtención de datos según el origen (Local o API).
  /// Soporta refresco forzado y aplica los filtros definidos en el estado.
  void _cargarDatos({bool forceRefresh = false}) {
    setState(() {
      if (widget.isLocal) {
        // Lógica para el Repositorio Local (filtrado manual en memoria).
        _futureData = MonsterStorageService().getMonsters().then((list) {
          var filteredList = list.where((m) {
            // Filtro por nombre.
            final nameMatch = (m.name ?? "").toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
            // Filtro por tipo de criatura.
            final typeMatch =
                _selectedType == "Todos" ||
                (m.type?.toLowerCase() == _selectedType.toLowerCase());
            // Filtro por tamaño.
            final sizeMatch =
                _selectedSize == "Todos" || m.size == _selectedSize;
            // Filtro por alineamiento moral/ético.
            final alignMatch =
                _selectedAlign == "Todos" ||
                (m.alignment?.toLowerCase().contains(
                      _selectedAlign.toLowerCase(),
                    ) ??
                    false);

            // Filtro por CR.
            final crMatch =
                _selectedCR == "Todos" ||
                m.challengeRating == double.tryParse(_selectedCR);

            // Filtros de daños (Vulnerabilidades, Resistencias, Inmunidades).
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
                crMatch &&
                vulnMatch &&
                resMatch &&
                immMatch;
          }).toList();

          // Aplicar ordenación.
          _applySorting(filteredList);
          return filteredList;
        });
      } else {
        // Lógica para la API remota.
        _futureData = ConnectionService()
            .fetchEventos(
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
            )
            .then((monsterList) async {
              var results = monsterList.results ?? [];

              // Para el filtrado de CR en la API y la ordenación, necesitamos los detalles.
              // Si hay CR seleccionado o la ordenación no es por nombre, forzamos la carga de detalles.
              bool needsDetails =
                  _selectedCR != "Todos" || _sortBy.contains("CR");

              if (needsDetails) {
                final List<Monster> detailedList = await Future.wait(
                  results.map(
                    (m) => ConnectionService().fetchMonsterDetail(m['url']),
                  ),
                );

                // Filtrar por CR.
                if (_selectedCR != "Todos") {
                  double targetCR = double.parse(_selectedCR);
                  List<Map<String, dynamic>> filteredResults = [];
                  for (int i = 0; i < results.length; i++) {
                    if (detailedList[i].challengeRating == targetCR) {
                      filteredResults.add(results[i]);
                    }
                  }
                  results = filteredResults;
                  // También necesitamos actualizar detailedList si vamos a ordenar después
                  // Pero si filtramos y luego ordenamos, detailedList ya no coincide por índice.
                  // Re-obtenemos los detalles filtrados si es necesario o unimos antes.
                  final List<Monster> filteredDetails = [];
                  for (int i = 0; i < detailedList.length; i++) {
                    if (detailedList[i].challengeRating == targetCR) {
                      filteredDetails.add(detailedList[i]);
                    }
                  }
                  _applySortingToApiResults(results, filteredDetails);
                } else {
                  // Ordenar sin filtrar CR.
                  _applySortingToApiResults(results, detailedList);
                }
              } else {
                // Ordenación básica por nombre si no necesitamos detalles.
                if (_sortBy == "Nombre (A-Z)") {
                  results.sort(
                    (a, b) => (a["name"] ?? "").compareTo(b["name"] ?? ""),
                  );
                } else if (_sortBy == "Nombre (Z-A)") {
                  results.sort(
                    (a, b) => (b["name"] ?? "").compareTo(a["name"] ?? ""),
                  );
                }
              }

              // Construcción única del registro de habilidades si se carga la lista completa.
              if (_searchController.text.isEmpty) {
                _checkAndBuildRegistry(monsterList);
              }
              return MonsterList(count: results.length, results: results);
            });
      }
    });
  }

  void _applySorting(List<Monster> list) {
    switch (_sortBy) {
      case "Nombre (A-Z)":
        list.sort((a, b) => (a.name ?? "").compareTo(b.name ?? ""));
        break;
      case "Nombre (Z-A)":
        list.sort((a, b) => (b.name ?? "").compareTo(a.name ?? ""));
        break;
      case "CR (Bajo-Alto)":
        list.sort(
          (a, b) => (a.challengeRating ?? 0).compareTo(b.challengeRating ?? 0),
        );
        break;
      case "CR (Alto-Bajo)":
        list.sort(
          (a, b) => (b.challengeRating ?? 0).compareTo(a.challengeRating ?? 0),
        );
        break;
    }
  }

  void _applySortingToApiResults(
    List<Map<String, dynamic>> results,
    List<Monster> details,
  ) {
    // Necesitamos mapear los resultados con sus detalles para ordenar.
    final combined = List.generate(
      results.length,
      (i) => {'res': results[i], 'det': details[i]},
    );

    switch (_sortBy) {
      case "Nombre (A-Z)":
        combined.sort(
          (a, b) => (a['det'] as Monster).name!.compareTo(
            (b['det'] as Monster).name!,
          ),
        );
        break;
      case "Nombre (Z-A)":
        combined.sort(
          (a, b) => (b['det'] as Monster).name!.compareTo(
            (a['det'] as Monster).name!,
          ),
        );
        break;
      case "CR (Bajo-Alto)":
        combined.sort(
          (a, b) => ((a['det'] as Monster).challengeRating ?? 0).compareTo(
            (b['det'] as Monster).challengeRating ?? 0,
          ),
        );
        break;
      case "CR (Alto-Bajo)":
        combined.sort(
          (a, b) => ((b['det'] as Monster).challengeRating ?? 0).compareTo(
            (a['det'] as Monster).challengeRating ?? 0,
          ),
        );
        break;
    }

    for (int i = 0; i < results.length; i++) {
      results[i] = combined[i]['res'] as Map<String, dynamic>;
    }
  }

  /// Comprueba y construye el registro local de habilidades para búsqueda rápida.
  /// Muestra un diálogo de progreso no cancelable durante la primera ejecución.
  Future<void> _checkAndBuildRegistry(MonsterList monsterList) async {
    final registryService = MonsterAbilityRegistryService();

    // Evitar reconstrucciones innecesarias si ya existe el registro.
    if (await registryService.isRegistryBuilt()) return;

    final List<Map<String, dynamic>> results = monsterList.results ?? [];
    if (results.isEmpty || !mounted) return;

    // Inicialización del estado del diálogo de progreso.
    _dialogProgress = 0;
    _dialogTotal = results.length;

    // Mostrar modal informativo con barra de progreso.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            _dialogSetState = setDialogState;
            final double percentage = _dialogTotal > 0
                ? _dialogProgress / _dialogTotal
                : 0.0;

            return AlertDialog(
              title: const Text('Construyendo Registro de Habilidades'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Sincronizando el bestiario local. Este proceso solo ocurre una vez.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(value: percentage),
                  const SizedBox(height: 10),
                  Text('$_dialogProgress / $_dialogTotal criaturas procesadas'),
                ],
              ),
            );
          },
        );
      },
    );

    // Iniciar proceso de indexación de habilidades.
    await registryService.buildRegistry(
      results,
      onProgress: (current, total) {
        if (_dialogSetState != null) {
          _dialogSetState!(() {
            _dialogProgress = current;
            _dialogTotal = total;
          });
        }
      },
    );

    // Cerrar diálogo al finalizar.
    if (mounted && Navigator.canPop(context)) Navigator.pop(context);
    _dialogSetState = null;
  }

  StateSetter? _dialogSetState;
  int _dialogProgress = 0;
  int _dialogTotal = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.isLocal ? 'Repositorio Local' : 'Bestiario API'),
        actions: [
          // Botón de actualización: ofrece opciones de limpieza de caché en modo API.
          TextButton.icon(
            onPressed: () {
              if (widget.isLocal) {
                _cargarDatos();
              } else {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Actualizar Bestiario"),
                    content: const Text(
                      "¿Deseas actualizar la lista o reconstruir el registro de habilidades?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _cargarDatos(forceRefresh: true);
                        },
                        child: const Text("Solo lista"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await MonsterAbilityRegistryService().clearRegistry();
                          _cargarDatos(forceRefresh: true);
                        },
                        child: const Text("Todo"),
                      ),
                    ],
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text(
              "Actualizar",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Buscador "Sólido": Reservado en la parte superior, no tapa la lista.
            _buildSearchBarSection(),

            // 2. Área principal: Contiene la lista de fondo y los filtros flotantes.
            Expanded(
              child: Stack(
                children: [
                  // La lista de monstruos (al fondo del Stack).
                  _buildMonsterListSection(),

                  // Panel de filtros avanzados (superpuesto en la parte superior del Stack).
                  _buildAdvancedFiltersOverlay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la barra de búsqueda de nombre.
  /// Es un widget estático que ocupa espacio físico en el Column del body.
  Widget _buildSearchBarSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      color: Theme.of(context).colorScheme.surface,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Buscar por nombre...',
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(),
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
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
        // Filtrado instantáneo en local.
        onSubmitted: (_) => _cargarDatos(), // Búsqueda al pulsar Enter.
      ),
    );
  }

  /// Construye el panel desplegable de filtros avanzados como un Overlay.
  /// Se posiciona sobre la lista y ajusta su altura si el teclado está visible.
  Widget _buildAdvancedFiltersOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ExpansionTile(
          title: Text(
            "Filtros Avanzados",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 14,
            ),
          ),
          leading: Icon(
            Icons.filter_list,
            color: Theme.of(context).colorScheme.primary,
          ),
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                // Cálculo dinámico de altura máxima para evitar errores de RenderFlex con el teclado.
                double availableHeight =
                    MediaQuery.of(context).size.height * 0.5;
                if (MediaQuery.of(context).viewInsets.bottom > 0) {
                  availableHeight = MediaQuery.of(context).size.height * 0.3;
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: availableHeight),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdown(
                                "Alineamiento",
                                _selectedAlign,
                                _alignments,
                                (v) => setState(() => _selectedAlign = v!),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildDropdown(
                                "CR",
                                _selectedCR,
                                _crs,
                                (v) => setState(() => _selectedCR = v!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          "Ordenar por",
                          _sortBy,
                          _sortOptions,
                          (v) => setState(() => _sortBy = v!),
                        ),
                        const SizedBox(height: 12),
                        _sectionTitle("Vulnerabilidades"),
                        _buildMultiSelectChips(
                          _damageTypes,
                          _selectedVulns,
                          (list) => setState(() => _selectedVulns = list),
                        ),
                        const SizedBox(height: 8),
                        _sectionTitle("Resistencias"),
                        _buildMultiSelectChips(
                          _damageTypes,
                          _selectedRes,
                          (list) => setState(() => _selectedRes = list),
                        ),
                        const SizedBox(height: 8),
                        _sectionTitle("Inmunidades"),
                        _buildMultiSelectChips(
                          _damageTypes,
                          _selectedImms,
                          (list) => setState(() => _selectedImms = list),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _cargarDatos,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                            ),
                            child: const Text("APLICAR FILTROS"),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Título de sección pequeño para los grupos de filtros.
  Widget _sectionTitle(String title) => Text(
    title,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    ),
  );

  /// Construye la lista de monstruos utilizando un FutureBuilder.
  Widget _buildMonsterListSection() {
    return FutureBuilder<dynamic>(
      future: _futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return Center(child: Text("Error: ${snapshot.error}"));

        final List results = widget.isLocal
            ? snapshot.data
            : (snapshot.data as MonsterList).results ?? [];
        if (results.isEmpty)
          return const Center(child: Text("No se encontraron criaturas."));

        return ListView.builder(
          padding: const EdgeInsets.only(top: 60),
          // Margen superior para que el ExpansionTile cerrado no tape el primer item.
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            if (widget.isLocal) {
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
              return _buildApiCard(
                item["name"] ?? "",
                item["url"] ?? "",
                item["index"] ?? "",
              );
            }
          },
        );
      },
    );
  }

  /// Crea un selector desplegable (Dropdown) con estilo personalizado.
  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
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

  /// Genera una fila de etiquetas (Chips) seleccionables para los tipos de daño.
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
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          selected: isSelected,
          selectedColor: Theme.of(context).colorScheme.primary,
          checkmarkColor: Theme.of(context).colorScheme.onPrimary,
          onSelected: (bool value) {
            List<String> newList = List.from(selected);
            value ? newList.add(option) : newList.remove(option);
            onChanged(newList);
          },
        );
      }).toList(),
    );
  }

  /// Tarjeta de visualización para monstruos obtenidos de la API.
  Widget _buildApiCard(String name, String url, String indexName) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: _buildApiImage(indexName),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: _MonsterSubtitle(url: url),
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

  /// Tarjeta de visualización para monstruos del repositorio local (incluye botón borrar).
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
        subtitle: Text(
          "$size $type, CR: ${monster.challengeRating ?? '?'}\n${monster.alignment}",
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () async {
            await MonsterStorageService().deleteMonster(index);
            _cargarDatos();
          },
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

  /// Widget de imagen para criaturas de la API (obtenidas del servidor oficial).
  Widget _buildApiImage(String indexName) {
    return _imageContainer(
      Image.network(
        "https://www.dnd5eapi.co/api/images/monsters/$indexName.png",
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.pets, color: Colors.grey),
      ),
    );
  }

  /// Widget de imagen para criaturas locales (gestiona archivos, URLs y rutas relativas).
  Widget _buildLocalImage(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty)
      return const Icon(Icons.pets, size: 40, color: Colors.brown);

    if (imagePath.startsWith('http') || imagePath.startsWith('/api')) {
      final url = imagePath.startsWith('http')
          ? imagePath
          : "https://www.dnd5eapi.co$imagePath";
      return _imageContainer(
        Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.pets),
        ),
      );
    } else {
      final file = File(imagePath);
      if (file.existsSync())
        return _imageContainer(Image.file(file, fit: BoxFit.cover));
    }
    return const Icon(Icons.pets, size: 40, color: Colors.brown);
  }

  /// Contenedor estandarizado con bordes redondeados para las imágenes de los monstruos.
  Widget _imageContainer(Widget child) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
    );
  }
}

/// Widget auxiliar para cargar información secundaria (alineamiento/tamaño) en la lista principal.
/// Evita bloqueos de la UI al realizar peticiones bajo demanda por cada item de la lista API.
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
            "${m.size} ${m.type}, CR: ${m.challengeRating ?? '?'}\n${m.alignment}",
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
