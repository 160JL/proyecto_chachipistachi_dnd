import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:proyecto_chachipistachi_dnd/l10n/app_localizations.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/battle_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_list_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/monster_create_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/combat_list_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/login_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/dashboard_screen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/blocked_user_screen.dart';
import 'package:proyecto_chachipistachi_dnd/providers/battle_queue_provider.dart';
import 'package:proyecto_chachipistachi_dnd/service/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Error inicializando Firebase: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BattleQueueProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const parchmentColor = Color(0xFFFDF1DC);
    const darkRed = Color(0xFF58170D);
    const goldOrange = Color(0xFFE69A28);
    const deepBlood = Color(0xFF8B0000);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkRed,
          primary: darkRed,
          secondary: goldOrange,
          surface: parchmentColor,
          onSurface: darkRed,
        ),
        scaffoldBackgroundColor: parchmentColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: darkRed,
          foregroundColor: parchmentColor,
          elevation: 8,
          shadowColor: Colors.black,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'serif',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: parchmentColor,
            letterSpacing: 1.2,
          ),
        ),
        cardTheme: CardThemeData(
          color: parchmentColor,
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: const _DndCardShape(), 
          shadowColor: darkRed.withAlpha(80),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkRed,
            foregroundColor: parchmentColor,
            elevation: 4,
            textStyle: const TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 1.1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: goldOrange, width: 2),
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF2E5CC),
          isDense: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: darkRed),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: darkRed, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: goldOrange, width: 2),
          ),
          labelStyle: const TextStyle(color: darkRed, fontFamily: 'serif', fontSize: 14),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: darkRed, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          headlineMedium: TextStyle(color: darkRed, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          titleLarge: TextStyle(color: darkRed, fontWeight: FontWeight.bold, fontFamily: 'serif', fontSize: 18),
          titleMedium: TextStyle(color: darkRed, fontWeight: FontWeight.bold, fontFamily: 'serif', fontSize: 16),
          bodyLarge: TextStyle(color: Colors.black87, fontSize: 15, fontFamily: 'serif'),
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 13, fontFamily: 'serif'),
        ),
        dividerTheme: const DividerThemeData(color: darkRed, thickness: 1.5, space: 20),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkRed,
          brightness: Brightness.dark,
          primary: goldOrange,
          secondary: deepBlood,
          surface: const Color(0xFF1A1A1A),
          onSurface: goldOrange,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: goldOrange,
          elevation: 10,
          shadowColor: Colors.black,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'serif',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: goldOrange,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: const _DndCardShape(), 
          shadowColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2A2A2A),
            foregroundColor: goldOrange,
            textStyle: const TextStyle(fontFamily: 'serif', fontWeight: FontWeight.bold, fontSize: 14),
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: goldOrange, width: 1),
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: goldOrange, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          headlineMedium: TextStyle(color: goldOrange, fontWeight: FontWeight.bold, fontFamily: 'serif'),
          titleLarge: TextStyle(color: goldOrange, fontWeight: FontWeight.bold, fontFamily: 'serif', fontSize: 18),
          titleMedium: TextStyle(color: goldOrange, fontWeight: FontWeight.bold, fontFamily: 'serif', fontSize: 16),
          bodyLarge: TextStyle(color: Colors.white70, fontSize: 15, fontFamily: 'serif'),
          bodyMedium: TextStyle(color: Colors.white60, fontSize: 13, fontFamily: 'serif'),
        ),
        dividerTheme: const DividerThemeData(color: goldOrange, thickness: 1.5, space: 20),
      ),
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: {
        "/dashboard": (context) => const DashboardScreen(),
        "/battlescreen": (context) => const AuthWrapper(child: BattleScreen()),
        "/api": (context) => const AuthWrapper(child: MonsterListScreen(isLocal: false, isPublic: false)),
        "/create": (context) => const AuthWrapper(child: MonsterCreateScreen()),
        "/repository": (context) => const AuthWrapper(child: MonsterListScreen(isLocal: true, isPublic: false)),
        "/public": (context) => const AuthWrapper(child: MonsterListScreen(isLocal: false, isPublic: true)),
        "/initiative": (context) => const AuthWrapper(child: CombatListScreen()),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final Widget? child;
  const AuthWrapper({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // Escuchamos el estado del usuario (Firebase User o Invitado)
    return StreamBuilder<User?>(
      stream: authService.userStream,
      builder: (context, snapshot) {
        // Estado de carga inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        // El usuario está identificado (Firebase o Invitado)
        if (snapshot.hasData || authService.isGuest) {
          
          // --- NUEVA LÓGICA DE BLOQUEO ---
          // Si el usuario está bloqueado en Firestore, redirigir a la pantalla de bloqueo
          if (authService.isBlocked) {
            return const BlockedUserScreen();
          }

          // Si todo está correcto, vamos al Dashboard o a la pantalla solicitada (child)
          return child ?? const DashboardScreen();
        }
        
        // Si no hay sesión, vamos a la pantalla de Login
        return const LoginScreen();
      },
    );
  }
}

class _DndCardShape extends OutlinedBorder {
  const _DndCardShape({super.side});

  @override
  OutlinedBorder copyWith({BorderSide? side}) => _DndCardShape(side: side ?? this.side);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path()..addRect(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = const Color(0xFFE69A28)
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, 6), paint);
    canvas.drawRect(Rect.fromLTWH(rect.left, rect.bottom - 6, rect.width, 6), paint);

    final sidePaint = Paint()
      ..color = const Color(0xFFE69A28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, sidePaint);
  }

  @override
  ShapeBorder scale(double t) => _DndCardShape(side: side.scale(t));
}
