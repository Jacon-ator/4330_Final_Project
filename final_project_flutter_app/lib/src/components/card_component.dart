import 'dart:ui';

import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/src/config.dart';
import 'package:flame/components.dart';

class CardComponent extends RectangleComponent with HasGameRef<PokerParty> {
  CardComponent({
    required Card card,
    super.position,
  }) : super(size: Vector2(cardWidth, cardHeight), anchor: Anchor.center) {
    // Load the sprite for the card based on its suit and rank
  }

  void render(Canvas canvas) {
    // Render the card using its sprite and position
    // sprite.render(canvas, position: position, size: size);
  }
}
