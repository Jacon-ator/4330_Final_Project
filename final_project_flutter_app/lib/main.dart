import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'widgets/profile_page.dart';
import 'package:flame_audio/flame_audio.dart';

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
