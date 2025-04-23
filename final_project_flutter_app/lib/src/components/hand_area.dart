import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/src/components/card_component.dart';
import 'package:flame/components.dart';

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
      position = Vector2(20 + (index * 78), 15); // Relative to HandArea
      card.position = position;
      add(card); // Add to HandArea's children
    }
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Set HandArea position and size
    position = Vector2(
        gameRef.size.x / 2 - 91, gameRef.size.y / 2 + 180); // Bottom of screen
    size = Vector2(gameRef.size.x - 1082, 155); // Full width, 150px height

    // DEBUG: Draws Window
    // final bgPaint = Paint()
    //   ..color = const Color.fromARGB(51, 178, 21, 21); // Semi-transparent black
    // add(RectangleComponent(
    //   size: size,
    //   paint: bgPaint,
    // ));
  }
}

//   @override
//   void render(Canvas canvas) {
//     super.render(canvas);
//     // Optionally draw background area
//   }
// }
