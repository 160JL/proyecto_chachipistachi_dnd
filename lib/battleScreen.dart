import 'package:flutter/material.dart';

class Battlescreen extends StatefulWidget {
  const Battlescreen({super.key});

  @override
  State<Battlescreen> createState() => _BattlescreenState();
}

class _BattlescreenState extends State<Battlescreen> {
  int _turno = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [Text("Batalla"), Text("Turno: $_turno"), Text(selectedPiece)],
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: BoardBuilder(
                builder: (context, tileId) {
                  if (pieces.containsValue(tileId)) {
                    return Piece(
                      pieces.entries.firstWhere((p) => p.value == tileId).key,
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Expanded(child: Card(child: Row())),
          ],
        ),
      ),
    );
  }
}

String selectedPiece = playerSelected.name;
Player playerSelected = Player("", Colors.white);

Map<Player, String> pieces = {
  Player("A", Colors.green): "D2",
  Player("B", Colors.red): "D7",
};

class Player {
  final String name;
  final Color color;

  Player(this.name, this.color);
}

class Piece extends StatelessWidget {
  final Player player;

  Piece(this.player);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: CircleAvatar(backgroundColor: player.color),
    );
  }
}

typedef BoardWidgetBuilder = Widget Function(BuildContext context, String tileId);

class BoardBuilder extends StatefulWidget {
  final BoardWidgetBuilder builder;

  BoardBuilder({required this.builder});

  @override
  _BoardBuilderState createState() => _BoardBuilderState();
}

class _BoardBuilderState extends State<BoardBuilder> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 7 / 8, // columnas / filas
      child: GridView.builder(
        physics: NeverScrollableScrollPhysics(), // sin scroll
        itemCount: 56,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1, // casillas cuadradas
        ),
        itemBuilder: (context, index) {
          var xIndex = index % 7;
          var yIndex = (index / 7).floor();
          var tileId = '${tileLetter[xIndex]}${yIndex + 1}';
          return GestureDetector(
            onTap: () {
              setState(() {
                if (pieces.containsValue(tileId)) {
                  playerSelected = pieces.entries
                      .firstWhere((p) => p.value == tileId)
                      .key;
                } else {
                  pieces.update(playerSelected, (value) => tileId);
                }
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black),
              ),
              child: Stack(
                children: <Widget>[
                  Text(
                    tileId,
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  widget.builder(context, tileId),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

final Map<int, String> tileLetter = {
  0: 'A',
  1: 'B',
  2: 'C',
  3: 'D',
  4: 'E',
  5: 'F',
  6: 'G',
};