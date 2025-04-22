import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/src/config.dart';
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
      14,
      13,
      12,
      11,
      10,
      9,
      8,
      7,
      6,
      5,
      4,
      3,
      2,
    ]; // 11 = Jack, 12 = Queen, 13 = King, 14 = Ace
    int x = -cardWidth.toInt();
    int y = -cardHeight.toInt();
    for (String suit in suits) {
      y += cardHeight.toInt();
      x = -cardWidth.toInt();
      for (int rank in ranks) {
        x += cardWidth.toInt();
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
