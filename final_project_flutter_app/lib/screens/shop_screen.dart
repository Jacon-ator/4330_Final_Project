import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/src/components/components.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ShopScreen extends Component with HasGameRef<PokerParty> {
  late Vector2 size;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = gameRef.size;

    final MainMenuButton mainMenuButton = MainMenuButton()
      ..size = Vector2(size.x / 6, size.y / 6)
      ..position = Vector2(size.x / 2 - size.x / 12, size.y * 0.8);

    final BuyCardButton buyCardButton = BuyCardButton()
      ..size = Vector2(size.x / 3, 60)
      ..position = Vector2(size.x / 2 - size.x / 6, size.y * 0.6);

    add(mainMenuButton);
    add(buyCardButton);
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
        style: TextStyle(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );

    // Description / item
    final itemText = TextPainter(
      text: const TextSpan(
        text: 'Fancy Card - 500 Coins',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );

    titleText.layout();
    itemText.layout();

    titleText.paint(
        canvas,
        Offset(size.x / 2 - titleText.width / 2,
            size.y / 10 - titleText.height / 2));
    itemText.paint(
        canvas,
        Offset(size.x / 2 - itemText.width / 2,
            size.y / 2 - itemText.height / 2));
  }
}

// Simple Buy Button for Shop
class BuyCardButton extends PositionComponent with TapCallbacks, HasGameRef<PokerParty> {
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFF008000); // green
    canvas.drawRect(size.toRect(), paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Buy Card',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.x / 2 - textPainter.width / 2,
          size.y / 2 - textPainter.height / 2),
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Add logic for buying the card
    print("Buy Card tapped!");
  }
}
