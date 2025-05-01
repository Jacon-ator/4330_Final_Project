import 'dart:ui';

import 'package:final_project_flutter_app/components/card_component.dart';
import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';

class CommunityCardArea extends RectangleComponent with HasGameRef<PokerParty> {
  // This class represents the area where community cards are displayed.
  // It extends RectangleComponent to provide a rectangular area for community cards.

  CommunityCardArea()
      : super(size: Vector2(465, 210), position: Vector2(255, 155));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Set the background color or any other properties if needed

    paint.color = const Color.fromARGB(
        0, 178, 21, 21); // DEBUG: Whant alpha to see window
  }

  void addCard(PlayingCard communityCard, int i, PokerParty gameRef) {
    // Create a CardComponent for the community card
    final ccardcomponent = CardComponent(
      card: communityCard,
    );
    // Position the card based on its index
    ccardcomponent.position =
        Vector2(38 + (i * 80), 45); // Adjust position as needed
    // Add the card component to the CommunityCardArea
    add(ccardcomponent);
  }

  void clearCards() {
    // Remove all child components (community cards) from the CommunityCardArea
    for (var child in children) {
      if (child is CardComponent) {
        remove(child);
      }
    }
  }
}
