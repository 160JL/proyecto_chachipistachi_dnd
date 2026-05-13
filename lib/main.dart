import 'package:flutter/material.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/battle_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_list_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_create_screen.dart';

void main() {
  runApp(const MyApp());
}

/// Clase principal de la aplicación que configura el tema global y la navegación por rutas.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Mapeo de rutas de la aplicación a sus respectivos componentes/pantallas.
      routes: {
        "/": (context) => const MyHomePage(),
        "/battlescreen": (context) => const BattleScreen(),
        "/api": (context) => const MonsterListScreen(isLocal: false),
        "/create": (context) => const MonsterCreateScreen(),
        "/repository": (context) => const MonsterListScreen(isLocal: true),
      },
    );
  }
}

/// Pantalla de inicio que actúa como menú principal de la aplicación.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _title = "Generador DnD";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botones de acceso a las distintas secciones con etiquetas claras.
              _buildMenuButton(
                context,
                "Simulación de batalla",
                Icons.grid_on,
                "/battlescreen",
              ),
              _buildMenuButton(
                context,
                "Crear Criatura Nueva",
                Icons.add_circle_outline,
                "/create",
              ),
              _buildMenuButton(
                context,
                "Consultar Bestiario (API)",
                Icons.public,
                "/api",
              ),
              _buildMenuButton(
                context,
                "Mis Criaturas Guardadas",
                Icons.storage,
                "/repository",
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Función auxiliar para crear botones de menú uniformes y descriptivos.
  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    String route,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamed(context, route),
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(280, 50),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
