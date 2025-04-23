import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            // your “logical” canvas size:
            width: 1265,
            height: 685,
            child: GameWidget(game: PokerParty()),
          ),
        ),
      ),
    ),
  );
}
