import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class RemoveBotButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  final VoidCallback onTap;
  bool isEnabled; // To control if the button is active

  RemoveBotButton({
    required Vector2 position,
    required this.onTap,
    this.isEnabled = true, // Default to enabled
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    Sprite? loadedSprite;
    double exportScale = 5; // Adjust this value based on your export scale

    final image =
        await gameRef.images.load("art/buttons/Master Button Sheet.png");
    loadedSprite = Sprite(
      image,
      srcPosition: Vector2(147 * exportScale,
          34 * exportScale), // multiplied original coordinates
      srcSize: Vector2(46 * exportScale,
          13 * exportScale), // change width and height as needed
    );

    size = loadedSprite.srcSize; // Set the size of the RemoveBotButton

    // Create a SpriteComponent and add it as a child
    final spriteComponent = SpriteComponent(
      sprite: loadedSprite,
      size: size, // Make the SpriteComponent the same size as the button
    );
    add(spriteComponent);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (isEnabled) {
      super.onTapUp(event);
      onTap(); // Call the provided onTap callback
    }
  }

  // Method to update the enabled state and visual feedback
  void setEnabled(bool enabled) {
    isEnabled = enabled;
    final spriteChild = children.whereType<SpriteComponent>().firstOrNull;
    final textChild = children.whereType<TextComponent>().firstOrNull;
  }
}
