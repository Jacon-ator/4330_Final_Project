import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ActionButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  final String label;
  final VoidCallback onPressed;
  final SFXManager _sfxManager = SFXManager();

  // These parameters tell the button where to extract its sprite from the spritesheet.
  final Vector2 spriteSrcPosition;
  final Vector2 spriteSrcSize;

  Sprite? sprite;

  ActionButton(
    this.label,
    this.onPressed, {
    required this.spriteSrcPosition,
    required this.spriteSrcSize,
    Vector2? position,
  }) {
    if (position != null) {
      this.position = position;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load the master button spritesheet.
    final image =
        await gameRef.images.load("art/buttons/Master Button Sheet.png");
    sprite =
        Sprite(image, srcPosition: spriteSrcPosition, srcSize: spriteSrcSize);
    size = spriteSrcSize;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Render the sprite button background.
    sprite?.renderRect(canvas, size.toRect());
    // Optionally, you can draw the label text on top here.
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _sfxManager.playButtonSelect();
    onPressed();
  }
}
