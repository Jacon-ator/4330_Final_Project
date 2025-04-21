import 'package:final_project_flutter_app/models/card.dart';
import 'package:flame/game.dart';

class Deck {
  String name;
  List<PlayingCard> cards;
  bool isShuffled = true;

  Deck({required this.name, required this.cards});

// pixel size 13x21
  List<PlayingCard> generateDeck() {
    List<PlayingCard> cards = [];
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
    int x = -13;
    int y = -13;
    for (String suit in suits) {
      x += 13;
      for (int rank in ranks) {
        y += 21;
        cards.add(PlayingCard(
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

  PlayingCard dealCard() {
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
