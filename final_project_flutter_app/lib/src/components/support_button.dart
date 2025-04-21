import 'dart:ui';

import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class SupportButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  final String label = 'Single';

  SupportButton({label});

  @override
  void render(Canvas canvas) {
    // This method would contain the logic to render the button in the UI.
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFF00FF00);
    canvas.drawRect(size.toRect(), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Support',
        style: TextStyle(color: Colors.white, fontSize: 24),
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
    super.onTapDown(event);
    // Navigate to the main menu screen when the button is tapped
    gameRef.router.pushNamed('game');
  }
}