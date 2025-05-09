import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class AddBotButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  final VoidCallback onTap;

  AddBotButton({
    required Vector2 position,
    required this.onTap,
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
          20 * exportScale), // multiplied original coordinates
      srcSize: Vector2(46 * exportScale,
          13 * exportScale), // change width and height as needed
    );

    size = loadedSprite.srcSize; // Set the size of the AddBotButton

    // Create a SpriteComponent and add it as a child
    final spriteComponent = SpriteComponent(
      sprite: loadedSprite,
      size: size, // Make the SpriteComponent the same size as the button
    );
    add(spriteComponent);
  }

  @override
  void onTapUp(TapUpEvent event) {
    super.onTapUp(event);
    onTap(); // Call the provided onTap callback
  }
}
