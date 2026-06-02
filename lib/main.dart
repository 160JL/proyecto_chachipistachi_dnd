import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:proyecto_chachipistachi_dnd/l10n/app_localizations.dart';
import 'package:proyecto_chachipistachi_dnd/models/changelog.dart';
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
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
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
  String _version = appChangelogES.isNotEmpty ? appChangelogES.first.version : "";

  @override
  void initState() {
    super.initState();
  }

  // Eliminamos _loadVersion ya que usaremos el changelog directamente

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.appTitle),
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botones de acceso a las distintas secciones con etiquetas claras.
                  _buildMenuButton(
                    context,
                    l10n.battleSimulation,
                    Icons.grid_on,
                    "/battlescreen",
                  ),
                  _buildMenuButton(
                    context,
                    l10n.initiativeTracker,
                    Icons.list_alt,
                    "/initiative",
                  ),
                  _buildMenuButton(
                    context,
                    l10n.createNewCreature,
                    Icons.add_circle_outline,
                    "/create",
                  ),
                  _buildMenuButton(
                    context,
                    l10n.consultBestiary,
                    Icons.public,
                    "/api",
                  ),
                  _buildMenuButton(
                    context,
                    l10n.mySavedCreatures,
                    Icons.storage,
                    "/repository",
                  ),
                ],
              ),
            ),
          ),
          if (_version.isNotEmpty)
            Positioned(
              bottom: 12,
              right: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'v$_version',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _showChangelog(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.history,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary.withAlpha(180),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showChangelog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final changelog = isEn ? appChangelogEN : appChangelogES;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.changelogTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: changelog.length,
            itemBuilder: (context, index) {
              final entry = changelog[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${l10n.version} ${entry.version} (${entry.date})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...entry.changes.map((change) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("• "),
                        Expanded(child: Text(change)),
                      ],
                    ),
                  )),
                  const Divider(),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  /// Función auxiliar para crear botones de menú uniformes y descriptivos.
  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    String? route, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onTap ?? () => Navigator.pushNamed(context, route!),
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
