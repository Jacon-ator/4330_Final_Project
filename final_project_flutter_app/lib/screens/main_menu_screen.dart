import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/src/components/components.dart';
import 'package:final_project_flutter_app/src/components/rules_button.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class MainMenuScreen extends Component with HasGameRef<PokerParty> {
  late Vector2 size;
  late SpriteComponent background;
  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Set the size of the main menu screen to fill the game window
    size = gameRef.size;

    // Loads background image
    // final bgSprite =
    //     await gameRef.loadSprite('art/Poker Party Gameplay Mock Up.png');

    // // Create a SpriteComponent to display the background
    // background = SpriteComponent()
    //   ..sprite = bgSprite
    //   ..size = size; // Makes it fill the screen

    // // Add it to the game
    // add(background);

    final RulesButton rulesButton = RulesButton()
      ..size = Vector2(size.x / 3, size.y / 3)
      ..position = Vector2(size.x / 3, size.y / 2 - size.y / 6);

    final StartGameButton startGameButton = StartGameButton()
      ..size = Vector2(size.x / 3, size.y / 3)
      ..position = Vector2(size.x / 3 * 2, size.y / 2 - size.y / 6);

    background = SpriteComponent()
      ..sprite = await gameRef.loadSprite('art/Temp Title Screen.png')
      ..size = size; // Makes it fill the screen
    add(background);
    add(rulesButton);
    add(startGameButton);
  }

  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFF000000);
    canvas.drawRect(size.toRect(), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Main Menu',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size.x / 2 - textPainter.width / 2,
            size.y - 50 - textPainter.height / 2));
  }
}
