import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/screens/settings_screen.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class SettingsButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  Sprite? sprite;

  @override
  Future<void> onLoad() async {
    double exportScale = 5;
    await super.onLoad();
    final image = await gameRef.images.load("art/buttons/Master Button Sheet.png");
    sprite = Sprite(
      image,
      srcPosition: Vector2(1 * exportScale, 48 * exportScale),
      srcSize: Vector2(67 * exportScale, 13 * exportScale),
    );

    if (sprite != null) {
      size = sprite!.srcSize;
      position = Vector2(
        gameRef.size.x / 2 - size.x / 2,
        gameRef.size.y * 0.8,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    sprite?.renderRect(canvas, size.toRect());
  }

  @override
  void onTapDown(TapDownEvent event) {
    Navigator.of(gameRef.buildContext!).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}
