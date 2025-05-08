import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/screens/shop_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class AddCoinsButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
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
      srcPosition: Vector2(152 * exportScale,
          0 * exportScale), // multiplied original coordinates
      srcSize: Vector2(85, 70), // change width and height as needed
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
  void onTapDown(TapDownEvent event) async {
    ShopScreen.coinBalance += 100;
    ShopScreen.coinTextFill.text = 'Coins: ${ShopScreen.coinBalance}';
    ShopScreen.coinTextOutline.text = 'Coins: ${ShopScreen.coinBalance}';
    print("Added 100 coins. Total: ${ShopScreen.coinBalance}");

    final email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(email)
          .update({"Coins": ShopScreen.coinBalance}).then((_) {
        print("Coins updated successfully");
      }).catchError((e) {
        print("Failed to update coins: $e");
      });
    }
  }
}
