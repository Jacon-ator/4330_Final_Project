import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ShopButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  Sprite? sprite;

  @override
  Future<void> onLoad() async {
    double exportScale = 5;
    double yPositionOffset = 75;
    await super.onLoad();
    final image =
        await gameRef.images.load("art/buttons/Master Button Sheet.png");
    sprite = Sprite(
      image,
      srcPosition: Vector2(69 * exportScale,
          76 * exportScale), // multiplied original coordinates
      srcSize: Vector2(67 * exportScale,
          13 * exportScale), // change width and height as needed
    );

    if (sprite != null) {
      size = sprite!.srcSize;

      position = Vector2(
        gameRef.size.x / 2 - size.x / 2,
        (gameRef.size.y / 2 - size.y / 2) - yPositionOffset * -3,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (sprite != null) {
      sprite!.renderRect(canvas, size.toRect());
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.goTo('shop');
  }
}
