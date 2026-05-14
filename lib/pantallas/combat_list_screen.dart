import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/combat.dart';
import '../service/combat_storage_service.dart';
import 'initiative_tracker_screen.dart';

/// Pantalla que lista todos los combates guardados en la aplicación.
/// Permite gestionar las sesiones de combate (crear, abrir, eliminar).
class CombatListScreen extends StatefulWidget {
  const CombatListScreen({super.key});

  @override
  State<CombatListScreen> createState() => _CombatListScreenState();
}

class _CombatListScreenState extends State<CombatListScreen> {
  final CombatStorageService _storageService = CombatStorageService();
  List<CombatSession> _sessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSessions(); // Cargamos las sesiones al iniciar la pantalla.
  }

  /// Recupera las sesiones guardadas del almacenamiento y las ordena por fecha de modificación.
  Future<void> _loadSessions() async {
    setState(() => _isLoading = true);
    final sessions = await _storageService.getSessions();
    setState(() {
      _sessions = sessions;
      _sessions.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      _isLoading = false;
    });
  }

  /// Navega a la pantalla del tracker para crear un nuevo combate.
  void _createNewCombat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InitiativeTrackerScreen()),
    ).then((_) => _loadSessions()); // Recargamos al volver por si se guardó el nuevo.
  }

  /// Abre un combate existente.
  void _openCombat(CombatSession session) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InitiativeTrackerScreen(session: session)),
    ).then((_) => _loadSessions()); // Recargamos al volver por posibles cambios.
  }

  /// Elimina definitivamente una sesión de combate del almacenamiento.
  void _deleteCombat(String id) async {
    await _storageService.deleteSession(id);
    _loadSessions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Gestión de Combates"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? _buildEmptyState()
              : _buildSessionList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewCombat,
        tooltip: "Nuevo Combate",
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Widget mostrado cuando no hay sesiones de combate guardadas.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shield_outlined, size: 100, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            "No hay combates guardados",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _createNewCombat,
            icon: const Icon(Icons.add),
            label: const Text("NUEVO COMBATE"),
          ),
        ],
      ),
    );
  }

  /// Lista de tarjetas representativas de cada sesión de combate.
  Widget _buildSessionList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _sessions.length,
      itemBuilder: (context, index) {
        final session = _sessions[index];
        // Formateo de fecha legible usando la librería 'intl'.
        final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(session.lastModified);
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: session.isStarted ? Colors.green : Colors.grey,
              child: Icon(
                session.isStarted ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
            ),
            title: Text(
              session.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Último cambio: $dateStr\nParticipantes: ${session.participants.length} | Ronda: ${session.round}",
            ),
            isThreeLine: true,
            titleAlignment: ListTileTitleAlignment.center,
            onTap: () => _openCombat(session),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(session),
            ),
          ),
        );
      },
    );
  }

  /// Muestra un diálogo de confirmación antes de eliminar un combate.
  void _confirmDelete(CombatSession session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Eliminar Combate"),
        content: Text("¿Estás seguro de que quieres eliminar '${session.name}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCombat(session.id);
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
