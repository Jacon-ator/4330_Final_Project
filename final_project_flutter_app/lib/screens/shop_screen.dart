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
  static late TextComponent coinTextOutline,
      coinTextFill; //use static for testing add_coins_button (can remove if app is done testing? or just use for demo)
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
    coinBalance = currentUser?.coins ?? 0;
    ownsCardSkin = currentUser?.ownCardSkin ?? false;
    ShopScreen.ownsTableSkin = currentUser?.ownTableSkin ?? false;

    print("User coins: ${ShopScreen.coinBalance}");
    print("Owns Card Skin: ${ShopScreen.ownsCardSkin}");
    print("Owns Table Skin: ${ShopScreen.ownsTableSkin}");

    final MainMenuButton mainMenuButton = MainMenuButton()
      ..size = Vector2(size.x / 6, size.y / 6)
      ..position = Vector2(size.x / 2 - size.x / 12, size.y * 0.8);

    final BuyPokemonCardButton buyPokemonCardButton = BuyPokemonCardButton()
      ..size = Vector2(size.x / 3.5, 60)
      ..position = Vector2(110, size.y * 0.25);

    final BuyMagicCardButton buyMagicCardButton = BuyMagicCardButton()
      ..size = Vector2(size.x / 3.5, 60)
      ..position = Vector2(250, size.y * 0.25);

    final BuyRedTableSkinButton buyRedTableSkinButton = BuyRedTableSkinButton()
      ..size = Vector2(size.x / 3.5, 60)
      ..position = Vector2(935, size.y * 0.25);

    final BuyPurpleTableSkinButton buyPurpleTableSkinButton =
        BuyPurpleTableSkinButton()
          ..size = Vector2(size.x / 3.5, 60)
          ..position = Vector2(1060, size.y * 0.25);

    final AddCoinsButton addCoinsButton = AddCoinsButton()
      ..size = Vector2(160, 50)
      ..position = Vector2(145, size.y * 0.825);

    ShopScreen.coinTextOutline = TextComponent(
      text: 'Coins: ${ShopScreen.coinBalance}',
      textRenderer: TextPaint(
        style: TextStyle(
          fontFamily: 'RedAlert', // pixel font
          fontSize: 48,
          foreground: Paint()
            ..style = PaintingStyle.stroke // Set to stroke
            ..strokeWidth = 5 // Adjust outline thickness as needed
            ..color = const Color.fromARGB(255, 118, 161, 93), // Outline color
        ),
      ),
      position: Vector2(size.x / 2, 10),
      anchor: Anchor.topCenter,
    );

    // Initialize Fill Text Component
    ShopScreen.coinTextFill = TextComponent(
      text: 'Coins: ${ShopScreen.coinBalance}',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: 'RedAlert', // pixel font
          fontSize: 48,
          color: Color.fromARGB(255, 70, 130, 50), // Fill color
        ),
      ),
      position: Vector2(size.x / 2, 10),
      anchor: Anchor.topCenter,
    );

    add(mainMenuButton);
    add(buyPokemonCardButton);
    add(buyMagicCardButton);
    add(buyRedTableSkinButton);
    add(buyPurpleTableSkinButton);
    add(addCoinsButton);
    add(coinTextOutline);
    add(coinTextFill);
  }

  void buyRedTableSkin() {
    if (!ownsTableSkin && coinBalance >= 1000) {
      coinBalance -= 1000;
      coinTextOutline.text = 'Coins: $coinBalance';
      coinTextFill.text = 'Coins: $coinBalance';
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

  void buyPurpleTableSkin() {
    if (!ownsTableSkin && coinBalance >= 1000) {
      coinBalance -= 1000;
      coinTextOutline.text = 'Coins: $coinBalance';
      coinTextFill.text = 'Coins: $coinBalance';
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

  void buyPokemonCardSkin() {
    if (!ownsCardSkin && coinBalance >= 200) {
      coinBalance -= 200;
      coinTextOutline.text = 'Coins: $coinBalance';
      coinTextFill.text = 'Coins: $coinBalance';
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

  void buyMagicCardSkin() {
    if (!ownsCardSkin && coinBalance >= 500) {
      coinBalance -= 500;
      coinTextOutline.text = 'Coins: $coinBalance';
      coinTextFill.text = 'Coins: $coinBalance';
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

    titleText.layout();
    cardSkinText.layout();
    tableSkinText.layout();

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
  }
}
