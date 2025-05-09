import 'dart:async';

import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class PlayNextRoundButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  final VoidCallback onPressed;
  final SFXManager _sfxManager = SFXManager();

  // These parameters tell the button where to extract its sprite from the spritesheet.
  final Vector2 spriteSrcPosition;
  final Vector2 spriteSrcSize;
  late double spriteScale = 1;

  Sprite? sprite;

  PlayNextRoundButton(
    this.onPressed, {
    required this.spriteSrcPosition,
    required this.spriteSrcSize,
    required this.spriteScale,
    Vector2? position,
  }) {
    if (position != null) {
      this.position = position;
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final image =
        await gameRef.images.load("art/buttons/Master Button Sheet.png");
    sprite = Sprite(
      image,
      srcPosition: spriteSrcPosition, // multiplied original coordinates
      srcSize: spriteSrcSize, // change width and height as needed
    );

    // Optionally, adjust the size based on your asset's dimensions.
    if (sprite != null) {
      size = sprite!.srcSize * spriteScale;

      position = position;
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
    onPressed();
  }
}
