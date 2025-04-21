import 'dart:ui';

import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/src/config.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class CardComponent extends PositionComponent with HasGameRef<PokerParty> {
  late final Sprite sprite;
  final PlayingCard card;

  CardComponent({
    required this.card,
    required String imagePath,
    super.position,
  }) : super(size: Vector2(cardWidth, cardHeight), anchor: Anchor.topLeft) {
    // Load the sprite for the card based on its suit and rank
    sprite = Sprite(gameRef.images.fromCache(imagePath));
  }

  @override
  void render(Canvas canvas) {
    // Draw the card sprite at the component's position
    sprite.render(
      canvas,
      position: Vector2.zero(), // Position is relative to the component
      size: size,
    );

    // Optionally add debugging visual elements
    // For example, draw a border around the card
    /*
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);
    */

    // If you want to draw the card's rank/suit as text
    /*
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${card.rank} ${card.suit}',
        style: TextStyle(color: Colors.black, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, 5));
    */
  }
}
