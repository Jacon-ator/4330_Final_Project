import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ActionButton extends PositionComponent with TapCallbacks {
  final String action;
  final VoidCallback onPressed;
  final Color color;

  ActionButton(this.action, this.onPressed, this.color) {
    size = Vector2(120, 50);
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
