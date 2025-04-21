import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';

class ShopOverlay extends PositionComponent with HasGameRef {
  late TextComponent title;
  late RectangleComponent background;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Title 
    title = TextComponent(
      text: 'Shop',
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    )
      ..anchor = Anchor.topCenter
      ..x = gameRef.size.x / 2
      ..y = 50;
    add(title);

    // Add items for shop here
    final cosmeticCard = TextComponent(
      text: 'Fancy Card - 500 Coins',
      textRenderer: TextPaint(
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    )
      ..anchor = Anchor.topCenter
      ..x = gameRef.size.x / 2
      ..y = 120;
    add(cosmeticCard);
  }
}
