import 'package:final_project_flutter_app/src/components/components.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class RulesScreen extends Component with HasGameRef {
  late Vector2 size;
  @override
  Future<void> onLoad() async {
    size = gameRef
        .size; // Set the size of the rules screen to fill the game window
    super.onLoad();
    // Load rules screen components here
    // For example, you can add a background or text explaining the rules

    final MainMenuButton mainMenuButton = MainMenuButton()
      ..size = Vector2(size.x / 6, size.y / 6)
      ..position = Vector2(size.x / 2 - size.x / 12, size.y * 0.8);

    add(mainMenuButton);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFF000000);
    canvas.drawRect(size.toRect(), paint);
    final titleText = TextPainter(
      text: TextSpan(
        text: 'Rules Screen',
        style: TextStyle(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Texas Hold\'em Rules\n\n',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          TextSpan(
            text:
                '1. Each player is dealt two private cards (known as "hole cards") that belong to them alone.\n'
                '2. Five community cards are dealt face-up on the "board".\n'
                '3. All players in the game share these community cards.\n'
                '4. Players use these shared community cards in conjunction with their own hole cards to each make their best possible five-card poker hand.\n'
                '5. The player with the best hand wins the pot.\n',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    titleText.layout();
    titleText.paint(
        canvas,
        Offset(size.x / 2 - titleText.width / 2,
            size.y / 10 - titleText.height / 2));
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size.x / 2 - textPainter.width / 2,
            size.y / 2 - textPainter.height / 2));
  }
}
