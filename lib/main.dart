import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/battle_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_list_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_create_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/combat_list_screen.dart';
import 'package:proyecto_chachipistachi_dnd/providers/battle_queue_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => BattleQueueProvider())],
      child: const MyApp(),
    ),
  );
}

/// Clase principal de la aplicación que configura el tema global y la navegación por rutas.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const parchmentColor = Color(0xFFFDF1DC);
    const darkRed = Color(0xFF58170D);
    const goldOrange = Color(0xFFE69A28);

    return MaterialApp(
      title: 'Generador DnD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkRed,
          primary: darkRed,
          secondary: goldOrange,
          surface: parchmentColor,
          surfaceContainerHighest: const Color(0xFFF2E5CC),
        ),
        scaffoldBackgroundColor: parchmentColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkRed,
          foregroundColor: parchmentColor,
          elevation: 4,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: parchmentColor,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: goldOrange, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkRed,
            foregroundColor: parchmentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: darkRed,
          thickness: 1.5,
          space: 24,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: darkRed,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
          headlineMedium: TextStyle(
            color: darkRed,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
          titleLarge: TextStyle(
            color: darkRed,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
          bodySmall: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkRed,
          brightness: Brightness.dark,
          primary: goldOrange,
          secondary: goldOrange,
          surface: const Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: goldOrange,
          elevation: 4,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: goldOrange, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          headlineMedium: TextStyle(color: goldOrange, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          titleLarge: TextStyle(color: goldOrange, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
          bodySmall: TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ),
      themeMode: ThemeMode.system,
      // Cambia automáticamente según el sistema
      // Mapeo de rutas de la aplicación a sus respectivos componentes/pantallas.
      routes: {
        "/": (context) => const MyHomePage(),
        "/battlescreen": (context) => const BattleScreen(),
        "/api": (context) => const MonsterListScreen(isLocal: false),
        "/create": (context) => const MonsterCreateScreen(),
        "/repository": (context) => const MonsterListScreen(isLocal: true),
        "/initiative": (context) => const CombatListScreen(),
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
                "Iniciativa (Tracker)",
                Icons.list_alt,
                "/initiative",
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
