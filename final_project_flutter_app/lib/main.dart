import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  // waits for flutter to be initialized before running things below
  WidgetsFlutterBinding.ensureInitialized();

  // sets the app to fullscreen
  Flame.device.fullScreen();

  // sets the phone orentation to landscape mode
  Flame.device.setLandscape();

  // funky set up to allow for hotreloading while in debug mode
  // and not while in release mode
  PokerParty game = PokerParty();
  runApp(
    GameWidget(game: kDebugMode ? PokerParty() : game),
  );
}

/* Following code properly scales with resizng the window. Still has black bard
   but i will figure it out later, dont want to break demo


import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
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
            width: 2570,
            height: 1190,
            child: GameWidget(game: PokerParty()),
          ),
        ),
      ),
    ),
  );
}

*/
