import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class SupportButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  Sprite? sprite;
  final String label = 'Single';
  final SFXManager _sfxManager = SFXManager();

  SupportButton({label});

  @override
  Future<void> onLoad() async {
    double exportScale = 5; // Adjust this value based on your export scale
    double yPositionOffset = 75; // Adjust this value based on your export scale
    await super.onLoad();
    final image =
        await gameRef.images.load("art/buttons/Master Button Sheet.png");
    sprite = Sprite(
      image,
      srcPosition: Vector2(
          1 * exportScale, 76 * exportScale), // multiplied original coordinates
      srcSize: Vector2(67 * exportScale,
          13 * exportScale), // change width and height as needed
    );

    // Optionally, adjust the size based on your asset's dimensions.
    if (sprite != null) {
      size = sprite!.srcSize;

      position = Vector2(
        gameRef.size.x / 2 - size.x / 2,
        (gameRef.size.y / 2 - size.y / 2) - yPositionOffset * -4,
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
    super.onTapDown(event);
    _sfxManager.playButtonSelect();
    // Navigate to the main menu screen when the button is tapped
    gameRef.router.pushNamed('support');
  }
}
