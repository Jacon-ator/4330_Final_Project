import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/screens/shop_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class AddCoinsButton extends PositionComponent with TapCallbacks, HasGameRef<PokerParty> {
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()..color = const Color(0xFF2196F3);
    canvas.drawRect(size.toRect(), paint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Add 100 Coins',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.x / 2 - textPainter.width / 2, size.y / 2 - textPainter.height / 2),
    );
  }

  @override
  void onTapDown(TapDownEvent event) async {
    ShopScreen.coinBalance += 100;
    print("Added 100 coins. Total: ${ShopScreen.coinBalance}");

    final email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      await FirebaseFirestore.instance.collection("users").doc(email).update({
        "Coins": ShopScreen.coinBalance
      }).then((_) {
        print("Coins updated successfully");
      }).catchError((e) {
        print("Failed to update coins: $e");
      });
    }
  }
}
