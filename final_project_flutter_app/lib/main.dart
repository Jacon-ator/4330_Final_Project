import 'package:final_project_flutter_app/gamblers_paradise.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  // waits for flutter to be initialized before running things below
  WidgetsFlutterBinding.ensureInitialized();

  // sets the app to fullscreen
  Flame.device.fullScreen();

  // Depending on what we decide, uncomment orientation
  Flame.device.setPortrait();
  //Flame.device.setLandscape();

  // funky set up to allow for hotreloading while in debug mode
  // and not wile in release mode
  if (kDebugMode) {
    runApp(GameWidget(game: GamblersParadise()));
  } else {
    final game = GamblersParadise();
    runApp(GameWidget(game: game));
  }
}
