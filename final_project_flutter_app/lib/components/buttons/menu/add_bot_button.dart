import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class AddBotButton extends PositionComponent with TapCallbacks, HasGameRef<PokerParty> {
  final Function onTap;
  late TextComponent textComponent;
  late RectangleComponent background;
  late RectangleComponent border;

  AddBotButton({
    required Vector2 position,
    required this.onTap,
  }) : super(position: position, size: Vector2(200, 60));

  @override
  Future<void> onLoad() async {
    // Create button background
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF1A5C32),
    );
    add(background);

    // Create button border
    border = RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    add(border);

    // Add text
    textComponent = TextComponent(
      text: 'Add Bot',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    textComponent.position = Vector2(
      size.x / 2 - textComponent.width / 2,
      size.y / 2 - textComponent.height / 2,
    );
    add(textComponent);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Play button click sound
    SFXManager().playButtonSelect();
    
    // Darken button to show it's pressed
    background.paint.color = const Color(0xFF0F3C1F);
  }

  @override
  void onTapUp(TapUpEvent event) {
    // Return to original color
    background.paint.color = const Color(0xFF1A5C32);
    
    // Call the onTap callback
    onTap();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    // Return to original color if tap is canceled
    background.paint.color = const Color(0xFF1A5C32);
  }
}
