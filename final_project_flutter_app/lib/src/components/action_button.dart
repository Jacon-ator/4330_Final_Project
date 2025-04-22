import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ActionButton extends PositionComponent with TapCallbacks {
  final String action;
  final VoidCallback onPressed;
  final Color color;
  static const double defaultSpacing = 10.0; // spacing between buttons

  // Add optional parameters for positioning
  ActionButton(
    this.action,
    this.onPressed,
    this.color, {
    ActionButton? previousButton, // Optional previous button to align with
    double spacing = defaultSpacing,
    super.position,
  }) {
    size = Vector2(120, 50);

    // If previousButton is provided, position this button next to it
    if (previousButton != null) {
      position = Vector2(
        previousButton.position.x + previousButton.size.x + spacing,
        previousButton.position.y,
      );
    } else
      position = Vector2(0, 0);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
        RRect.fromRectAndRadius(size.toRect(), Radius.circular(8)), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: action,
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size.x / 2 - textPainter.width / 2,
            size.y / 2 - textPainter.height / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }
}
