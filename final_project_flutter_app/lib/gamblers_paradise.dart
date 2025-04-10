import 'package:flame/components.dart';
import 'package:flame/game.dart';

class GamblersParadise extends FlameGame {
  late SpriteComponent background;

/* This implimentation will probabyl be changed or deleted, just messing aroud
   and trying to get an image to be drawn in the window. Just wanted to get basic 
   drawing of sprites and flame syntax working
*/

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Loads background image
    final bgSprite = await loadSprite('Gamblers Paradise Mock Up.png');

    // Create a SpriteComponent to display the background
    background = SpriteComponent()
      ..sprite = bgSprite
      ..size = size; // Makes it fill the screen

    // Add it to the game
    add(background);
  }
}
