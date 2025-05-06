import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/screens/shop_screen.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class BuyTableSkinButton extends PositionComponent with TapCallbacks, HasGameRef<PokerParty> {
  final SFXManager _sfxManager = SFXManager();

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFF2196F3);
    canvas.drawRect(size.toRect(), paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Buy Table Skin',
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
    super.onTapDown(event);
    _sfxManager.playButtonSelect();
    final shop = parent as ShopScreen;
    shop.buyTableSkin();
  }
}
