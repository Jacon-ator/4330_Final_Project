import 'package:final_project_flutter_app/config.dart';
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
    List<String> suits = ['Hearts', 'Diamonds', 'Spades', 'Clubs'];
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
    if (cards.isEmpty) {
      throw Exception("No cards left in the deck.");
    }
    if (!isShuffled) {
      shuffleDeck();
    }
    return cards.removeLast();
  }

  static Deck fromJson(Map<String, dynamic> json) {
    return Deck(
      name: json['name'] as String,
      cards: (json['cards'] as List<dynamic>)
          .map((card) => PlayingCard.fromJson(card))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cards': cards.map((card) => card.toJson()).toList(),
    };
  }

  void resetDeck() {
    cards = generateDeck();
    isShuffled = false;
  }
}
