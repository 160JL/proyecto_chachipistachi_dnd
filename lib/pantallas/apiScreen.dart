import 'package:flutter/material.dart';
import 'package:proyecto_chachipistachi_dnd/models/monster.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_detail_screen.dart';
import '../service/connection_service.dart';

/// Pantalla principal con listado, búsqueda y filtros de monstruos.
class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  State<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  // El Future que maneja la carga de datos.
  late Future<MonsterList> futureMonsterSmall;

  // Controladores y variables para los filtros.
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = "Todos";
  String _selectedSize = "Todos";

  // Listas de opciones para los filtros (basadas en la API de D&D).
  final List<String> _types = [
    "Todos", "Aberration", "Beast", "Celestial", "Construct", "Dragon", 
    "Elemental", "Fey", "Fiend", "Giant", "Humanoid", "Monstrosity", 
    "Ooze", "Plant", "Undead"
  ];

  final List<String> _sizes = [
    "Todos", "Tiny", "Small", "Medium", "Large", "Huge", "Gargantuan"
  ];

  @override
  void initState() {
    super.initState();
    // Carga inicial sin filtros.
    _cargarMonstruos();
  }

  /// Método para disparar la carga de monstruos aplicando los filtros actuales.
  void _cargarMonstruos({bool forceRefresh = false}) {
    setState(() {
      futureMonsterSmall = ConnectionService().fetchEventos(
        forceRefresh: forceRefresh,
        name: _searchController.text,
        type: _selectedType,
        size: _selectedSize,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bestiario D&D'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _cargarMonstruos(forceRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // Sección de Filtros y Búsqueda
          _buildFilterSection(),
          
          // Listado de Monstruos
          Expanded(
            child: FutureBuilder<MonsterList>(
              future: futureMonsterSmall,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  final results = snapshot.data!.results ?? [];
                  
                  if (results.isEmpty) {
                    return const Center(child: Text("No se encontraron monstruos con estos filtros."));
                  }

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final monster = results[index];
                      final String indexName = monster["index"] ?? "";

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: ListTile(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MonsterDetailScreen(
                                monsterUrl: monster["url"].toString(),
                                monsterName: monster["name"].toString(),
                              ),
                            ),
                          ),
                          leading: _buildMonsterImage(indexName),
                          title: Text(
                            monster["name"]?.toString() ?? "Sin nombre",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: _MonsterSubtitle(url: monster["url"].toString()),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return _buildErrorWidget(snapshot.error.toString());
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la interfaz de búsqueda y filtros.
  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: Colors.brown[50],
      child: Column(
        children: [
          // Barra de búsqueda por nombre
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar por nombre...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _cargarMonstruos();
                },
              ),
            ),
            onSubmitted: (_) => _cargarMonstruos(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Selector de Tipo
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(labelText: "Tipo", border: OutlineInputBorder()),
                  items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedType = val!);
                    _cargarMonstruos();
                  },
                ),
              ),
              const SizedBox(width: 10),
              // Selector de Tamaño
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSize,
                  decoration: const InputDecoration(labelText: "Tamaño", border: OutlineInputBorder()),
                  items: _sizes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) {
                    setState(() => _selectedSize = val!);
                    _cargarMonstruos();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye el widget de la imagen del monstruo.
  Widget _buildMonsterImage(String indexName) {
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
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.pets, color: Colors.grey),
        ),
      ),
    );
  }

  /// Widget que se muestra en caso de error.
  Widget _buildErrorWidget(String error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, color: Colors.red, size: 60),
        Text('Error: $error'),
        ElevatedButton(onPressed: () => _cargarMonstruos(), child: const Text('Reintentar')),
      ],
    );
  }
}

/// Widget interno para cargar el subtítulo (Size - Type) de forma asíncrona.
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
          return Text("${m.size} - ${m.type}", style: const TextStyle(fontSize: 12));
        }
        return const Text("Cargando...", style: TextStyle(fontSize: 12, color: Colors.grey));
      },
    );
  }
}
