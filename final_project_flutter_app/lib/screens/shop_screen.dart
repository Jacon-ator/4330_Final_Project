import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/components/components.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/database_service.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ShopScreen extends Component with HasGameRef<PokerParty> {
  late Vector2 size;
  static bool ownsCardSkin = false;
  static bool ownsTableSkin = false;
  static int coinBalance = 0;
  late userData? currentUser;

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = gameRef.size;

    // Load the background image (replace 'art/Shop_Background.png' with your actual image path)
    final shopBackgroundSprite = await Sprite.load('art/Shop Screen.png');
    final shopBackground = SpriteComponent(
      sprite: shopBackgroundSprite,
      size: size, // Make the image fill the screen
      position: Vector2(0, 0),
    );
    add(shopBackground);

    // Load user data
    final db = DatabaseService();
    currentUser = await db.getUserData();
    ShopScreen.coinBalance = currentUser?.coins ?? 0;
    ShopScreen.ownsCardSkin = currentUser?.ownCardSkin ?? false;
    ShopScreen.ownsTableSkin = currentUser?.ownTableSkin ?? false;

    print("User coins: ${ShopScreen.coinBalance}");
    print("Owns Card Skin: ${ShopScreen.ownsCardSkin}");
    print("Owns Table Skin: ${ShopScreen.ownsTableSkin}");

    final MainMenuButton mainMenuButton = MainMenuButton()
      ..size = Vector2(size.x / 6, size.y / 6)
      ..position = Vector2(size.x / 2 - size.x / 12, size.y * 0.8);

    final BuyCardButton buyCardButton = BuyCardButton()
      ..size = Vector2(size.x / 3.5, 60)
      ..position = Vector2(size.x / 2 - size.x / 3, size.y * 0.55);

    final BuyTableSkinButton buyTableSkinButton = BuyTableSkinButton()
      ..size = Vector2(size.x / 3.5, 60)
      ..position = Vector2(size.x / 2 + size.x / 20, size.y * 0.55);

    final AddCoinsButton addCoinsButton = AddCoinsButton()
      ..size = Vector2(160, 50)
      ..position = Vector2(size.x / 2 - 80, size.y * 0.7);

    add(mainMenuButton);
    add(buyCardButton);
    add(buyTableSkinButton);
    add(addCoinsButton);
  }

  void buyTableSkin() {
    if (!ownsTableSkin && coinBalance >= 1000) {
      coinBalance -= 1000;
      ownsTableSkin = true;

      // Update Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.email) // use the email from currentUser
          .update({"Coins": coinBalance, "ownTableSkin": true});

      print("Table skin purchased!");
    } else {
      print("Not enough coins or already owned.");
    }
  }

  void buyCardSkin() {
    if (!ownsCardSkin && coinBalance >= 500) {
      coinBalance -= 500;
      ownsCardSkin = true;

      // Update Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.email)
          .update({"Coins": coinBalance, "ownCardSkin": true});

      print("Card skin purchased!");
    } else {
      print("Not enough coins or already owned.");
    }
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

    final coinText = TextPainter(
      text: TextSpan(
        text: 'Coins: ${ShopScreen.coinBalance}',
        style: const TextStyle(color: Colors.yellow, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );

    titleText.layout();
    cardSkinText.layout();
    tableSkinText.layout();
    coinText.layout();

    // Title
    titleText.paint(
      canvas,
      Offset(
          size.x / 2 - titleText.width / 2, size.y / 10 - titleText.height / 2),
    );

    // Card Skin Text
    cardSkinText.paint(
      canvas,
      Offset(
        size.x / 2 - size.x / 3 + (size.x / 7) - cardSkinText.width / 2,
        size.y * 0.5,
      ),
    );

    // Table Skin Texrt
    tableSkinText.paint(
      canvas,
      Offset(
        size.x / 2 + size.x / 20 + (size.x / 7) - tableSkinText.width / 2,
        size.y * 0.5,
      ),
    );

    coinText.paint(canvas, const Offset(20, 20));
  }
}
