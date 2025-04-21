import 'package:flame/game.dart';

class PlayingCard {
  final String suit;
  final int rank;
  final Vector2 position;

  PlayingCard({
    required this.suit,
    required this.rank,
    required this.position,
  });

  static compareCard(PlayingCard a, PlayingCard b) {
    if (a.rank == b.rank) {
      return 0;
    } else if (a.rank > b.rank) {
      return 1; // Card a is greater
    } else {
      return -1; // Card b is greater
    }
  }
}
