import 'dart:ui';

import 'package:final_project_flutter_app/src/components/components.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:final_project_flutter_app/poker_party.dart';

class RulesScreen extends Component with HasGameRef {
  late Vector2 size;
  @override
  Future<void> onLoad() async {
    size = gameRef
        .size; // Set the size of the rules screen to fill the game window
    super.onLoad();
    // Load rules screen components here
    // For example, you can add a background or text explaining the rules

    final MainMenuButton mainMenuButton = MainMenuButton()
      ..size = Vector2(size.x / 3, size.y / 3)
      ..position = Vector2(size.x / 3, size.y / 2 - size.y / 6);

    add(mainMenuButton);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFF000000);
    canvas.drawRect(size.toRect(), paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Rules Screen',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size.x / 2 - textPainter.width / 2,
            size.y - 50 - textPainter.height / 2));
  }
}
