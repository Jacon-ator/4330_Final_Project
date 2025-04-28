import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class BuyCardButton extends PositionComponent with TapCallbacks, HasGameRef<PokerParty> {
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFF008000); // Green color
    canvas.drawRect(size.toRect(), paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Buy Card Skin',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.x / 2 - textPainter.width / 2,
          size.y / 2 - textPainter.height / 2),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    print("Card Skin bought!");
  }
}
