import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/screens/settings_screen.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class SettingsButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  Sprite? sprite;
  final SFXManager _sfxManager = SFXManager();

  @override
  Future<void> onLoad() async {
    double exportScale = 5;
    await super.onLoad();
    final image =
        await gameRef.images.load("art/buttons/Master Button Sheet.png");
    sprite = Sprite(
      image,
      srcPosition: Vector2(1 * exportScale, 48 * exportScale),
      srcSize: Vector2(67 * exportScale, 13 * exportScale),
    );

    if (sprite != null) {
      size = sprite!.srcSize;
      position = Vector2(
        gameRef.size.x / 2 - size.x / 2,
        (gameRef.size.y * 0.9) -
            6, //boofed logic to get settings button to play nice with positioning
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
    _sfxManager.playButtonSelect();
    Navigator.of(gameRef.buildContext!).push(
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}
