import 'package:flutter/material.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/battleScreen.dart';
import 'package:proyecto_chachipistachi_dnd/pantallas/apiScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        "/": (context) => MyHomePage(),
        "/battlescreen": (context) => Battlescreen(),
        "/api": (context) => ApiScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _title = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, "/battlescreen"),
            child: Text("Simulación de batalla"),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, "/"),
            child: Text("Crear desde cero"),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, "/"),
            child: Text("Generar criatura"),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, "/api"),
            child: Text("Api"),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, "/"),
            child: Text("Repositorio"),
          ),

        ],
      ),
    );
  }
}
