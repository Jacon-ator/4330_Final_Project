import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/src/components/card_component.dart';
import 'package:final_project_flutter_app/src/config.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

// In hand_area.dart
class HandArea extends PositionComponent with HasGameRef<PokerParty> {
  // Map to store player cards
  final Map<Player, List<CardComponent>> playerCards = {};

  void addCard(Player player, CardComponent card, int index, dynamic gameRef) {
    // Initialize the list for the player if it doesn't exist
    playerCards.putIfAbsent(player, () => []);

    // Add the card to the player's hand
    if (index < playerCards[player]!.length) {
      playerCards[player]![index] = card;
    } else {
      playerCards[player]!.add(card);
    }

    // Position the card based on player and index
    Vector2 position;
    if (!player.isAI) {
      // Human player cards at bottom
      position = Vector2(20 + (index * 55), 20); // Relative to HandArea
    } else {
      // AI player cards
      int playerIndex = gameRef.gameState.players.indexOf(player);
      position = Vector2((playerIndex - 1) * 200 + (index * 30), 0);
    }

    card.position = position;
    add(card); // Add to HandArea's children
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Set HandArea position and size
    position = Vector2(
        gameRef.size.x / 2 - 75, gameRef.size.y / 2 + 100); // Bottom of screen
    size = Vector2(gameRef.size.x / 8 + 40, 150); // Full width, 150px height

    // Draw background if desired
    final bgPaint = Paint()
      ..color = const Color.fromARGB(51, 178, 21, 21); // Semi-transparent black
    add(RectangleComponent(
      size: size,
      paint: bgPaint,
    ));
  }
}

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     // Optionally draw background area
//   }
// }
