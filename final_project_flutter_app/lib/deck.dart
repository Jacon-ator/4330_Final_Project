import 'package:final_project_flutter_app/card.dart';
import 'package:flame/game.dart';

class Deck {
  String name;
  List<Card> cards;
  bool isShuffled = true;

  Deck({required this.name, required this.cards});

// pixel size 13x21
  List<Card> generateDeck() {
    List<Card> cards = [];
    List<String> suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    List<int> ranks = [
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10,
      11,
      12,
      13,
      14,
    ]; // 11 = Jack, 12 = Queen, 13 = King, 14 = Ace
    for (int suitIndex = 0; suitIndex < suits.length; suitIndex++) {
      String suit = suits[suitIndex];
      for (int rankIndex = 0; rankIndex < ranks.length; rankIndex++) {
        int rank = ranks[rankIndex];

        // Calculate position in spritesheet grid
        int x = rankIndex * 13; // Each card is 13px wide
        int y = suitIndex * 21; // Each card is 21px tall

        cards.add(Card(
          suit: suit,
          rank: rank,
          position: Vector2(x.toDouble(), y.toDouble()),
        ));
      }
    }
    return cards;
  }

  void shuffleDeck() {
    cards = cards.toList()..shuffle();
    isShuffled = true;
  }

  Card dealCard() {
    if (!isShuffled) {
      shuffleDeck();
    }
    return cards.removeLast();
  }

  void resetDeck() {
    cards = generateDeck();
    isShuffled = false;
  }
}
