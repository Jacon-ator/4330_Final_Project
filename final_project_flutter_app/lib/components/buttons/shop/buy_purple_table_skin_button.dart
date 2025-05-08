import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/screens/shop_screen.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class BuyPurpleTableSkinButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  final SFXManager _sfxManager = SFXManager();
  Sprite? sprite;
  @override
  Future<void> onLoad() async {
    double exportScale = 5;
    double yPositionOffset = 75;
    await super.onLoad();
    final image =
        await gameRef.images.load("art/buttons/Master Button Sheet.png");
    sprite = Sprite(
      image,
      srcPosition: Vector2(132 * exportScale,
          0 * exportScale), // multiplied original coordinates
      srcSize: Vector2(17 * exportScale,
          9 * exportScale), // change width and height as needed
    );

    if (sprite != null) {
      size = sprite!.srcSize;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (sprite != null) {
      sprite!.renderRect(canvas, size.toRect());
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    _sfxManager.playButtonSelect();
    final shop = parent as ShopScreen;
    shop.buyRedTableSkin();
  }
}
