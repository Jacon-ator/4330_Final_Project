import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/src/components/components.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ShopScreen extends Component with HasGameRef<PokerParty> {
  late Vector2 size;
  static bool ownsTableSkin = false;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = gameRef.size;

    final MainMenuButton mainMenuButton = MainMenuButton()
      ..size = Vector2(size.x / 6, size.y / 6)
      ..position = Vector2(size.x / 2 - size.x / 12, size.y * 0.8);

    final BuyCardButton buyCardButton = BuyCardButton()
      ..size = Vector2(size.x / 3.5, 60)
      ..position = Vector2(size.x / 2 - size.x / 3, size.y * 0.55);

    final BuyTableSkinButton buyTableSkinButton = BuyTableSkinButton()
      ..size = Vector2(size.x / 3.5, 60)
      ..position = Vector2(size.x / 2 + size.x / 20, size.y * 0.55); 

    add(mainMenuButton);
    add(buyCardButton);
    add(buyTableSkinButton);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final paint = Paint()..color = const Color(0xFF000000);
    canvas.drawRect(size.toRect(), paint);

    // Title
    final titleText = TextPainter(
      text: const TextSpan(
        text: 'Shop',
        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );

    // Description for Card
    final cardSkinText = TextPainter(
      text: const TextSpan(
        text: 'Fancy Card - 500 Coins',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );

    // Description for Table Skin
    final tableSkinText = TextPainter(
      text: const TextSpan(
        text: 'Table Skin - 1000 Coins',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );

    titleText.layout();
    cardSkinText.layout();
    tableSkinText.layout();

    // Title
    titleText.paint(
      canvas,
      Offset(size.x / 2 - titleText.width / 2, size.y / 10 - titleText.height / 2),
    );

    // Card Skin Text
    cardSkinText.paint(
      canvas,
      Offset(size.x / 2 - size.x / 3 + (size.x / 7) - cardSkinText.width / 2, size.y * 0.5,),
    );

    // Table Skin Texrt
    tableSkinText.paint(
      canvas,
      Offset(size.x / 2 + size.x / 20 + (size.x / 7) - tableSkinText.width / 2, size.y * 0.5,),
    );
  }
}