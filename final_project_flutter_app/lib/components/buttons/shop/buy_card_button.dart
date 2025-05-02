import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/screens/shop_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class BuyCardButton extends PositionComponent with TapCallbacks, HasGameRef<PokerParty> {
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFF008000);
    canvas.drawRect(size.toRect(), paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Buy Card Skin',
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
  void onTapDown(TapDownEvent event) async {
    if (ShopScreen.ownsCardSkin) {
      print("Card Skin already owned.");
      return;
    }

    if (ShopScreen.coinBalance >= 500) {
      ShopScreen.coinBalance -= 500;
      ShopScreen.ownsCardSkin = true;
      print("Card Skin bought! Remaining coins: ${ShopScreen.coinBalance}");

      final email = FirebaseAuth.instance.currentUser?.email;
      if (email != null) {
        await FirebaseFirestore.instance.collection("users").doc(email).update({"Coins": ShopScreen.coinBalance,});
      }
    } else {
      print("Not enough coins to buy Card Skin. You have ${ShopScreen.coinBalance}.");
    }
  }
}
