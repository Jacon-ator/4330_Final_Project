import 'package:flame/game.dart';

class Card {
  final String suit;
  final int rank;
  final Vector2 position;

  Card({
    required this.suit,
    required this.rank,
    required this.position,
  });

  static compareCard(Card a, Card b) {
    if (a.rank == b.rank) {
      return 0;
    } else if (a.rank > b.rank) {
      return 1; // Card a is greater
    } else {
      return -1; // Card b is greater
    }
  }
}
