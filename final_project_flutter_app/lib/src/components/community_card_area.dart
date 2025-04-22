import 'dart:ui';

import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/src/components/card_component.dart';
import 'package:flame/components.dart';

class CommunityCardArea extends RectangleComponent with HasGameRef<PokerParty> {
  // This class represents the area where community cards are displayed.
  // It extends RectangleComponent to provide a rectangular area for community cards.

  CommunityCardArea()
      : super(size: Vector2(305, 100), position: Vector2(195, 105));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Set the background color or any other properties if needed
    paint.color =
        const Color.fromARGB(51, 178, 21, 21); // Light gray background
  }

  void addCard(PlayingCard communityCard, int i, PokerParty gameRef) {
    // Create a CardComponent for the community card
    final ccardcomponent =
        CardComponent(card: communityCard, imagePath: '', position: position);
    // Position the card based on its index
    ccardcomponent.position =
        Vector2(20 + (i * 55), 15); // Adjust position as needed
    // Add the card component to the CommunityCardArea
    add(ccardcomponent);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Optionally, you can draw additional elements like borders or text
    final borderPaint = Paint()
      ..color = const Color.fromARGB(255, 0, 0, 0) // Black border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(size.toRect(), borderPaint);
  }
}
