import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class RemoveBotButton extends PositionComponent with TapCallbacks, HasGameRef<PokerParty> {
  final Function onTap;
  late TextComponent textComponent;
  late RectangleComponent background;
  late RectangleComponent border;
  bool isEnabled = false;

  RemoveBotButton({
    required Vector2 position,
    required this.onTap,
    this.isEnabled = false,
  }) : super(position: position, size: Vector2(200, 60));

  @override
  Future<void> onLoad() async {
    // Create button background
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = isEnabled ? const Color(0xFF8B0000) : const Color(0xFF555555),
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
      text: 'Remove Bot',
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

  void setEnabled(bool enabled) {
    isEnabled = enabled;
    background.paint.color = isEnabled ? const Color(0xFF8B0000) : const Color(0xFF555555);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isEnabled) return;
    
    // Play button click sound
    SFXManager().playButtonSelect();
    
    // Darken button to show it's pressed
    if (isEnabled) {
      background.paint.color = const Color(0xFF5A0000);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!isEnabled) return;
    
    // Return to original color
    background.paint.color = const Color(0xFF8B0000);
    
    // Call the onTap callback
    onTap();
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    if (!isEnabled) return;
    
    // Return to original color if tap is canceled
    background.paint.color = const Color(0xFF8B0000);
  }
}
