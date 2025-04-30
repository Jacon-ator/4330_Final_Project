import 'dart:ui';

import 'package:final_project_flutter_app/config.dart';
import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';

class CardComponent extends PositionComponent with HasGameRef<PokerParty> {
  late Sprite sprite;
  final PlayingCard card;

  late Image spritesheet;
  late Image cardBack;

  CardComponent({
    required this.card,
    required Vector2 position,
  }) : super(size: Vector2(cardWidth, cardHeight), anchor: Anchor.topLeft) {
    // Load the sprite for the card based on its suit and rank
  }

  @override
  Future<void> onLoad() async {
    spritesheet = game.images.fromCache(AssetPaths.cardFronts);
    cardBack = game.images.fromCache(AssetPaths.cardBacks);

    if (card.isFlipped) {
      sprite = Sprite(cardBack, srcPosition: Vector2(0, 0), srcSize: size);
    } else {
      // Create a sprite from the spritesheet using the card's position
      sprite = Sprite(spritesheet,
          srcPosition: Vector2(card.position.x, card.position.y),
          srcSize: Vector2(cardWidth + 1, cardHeight));
    }

    // You may want to scale up the card for display
    scale = Vector2(1.24, 1.5); // Scale up 4x
  }

  @override
  void render(Canvas canvas) {
    // Draw the card sprite at the component's position
    sprite.render(
      canvas,
      size: size,
    );
  }

  void flipCard() {
    bool isFlipped = card.flipCard();

    if (isFlipped) {
      sprite = Sprite(cardBack, srcPosition: Vector2(0, 0), srcSize: size);
    } else {
      sprite = Sprite(spritesheet,
          srcPosition: Vector2(card.position.x, card.position.y),
          srcSize: Vector2(cardWidth + 1, cardHeight));
    }
  }
}
