import 'package:flame/game.dart';
import 'package:poker/poker.dart' as poker;

class PlayingCard {
  final String suit;
  final int rank;
  final Vector2 position;
  bool isFlipped = false; // Indicates if the card is flipped

  PlayingCard({
    required this.suit,
    required this.rank,
    required this.position,
    this.isFlipped = false,
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

  @override
  String toString() {
    return 'PlayingCard{suit: $suit, rank: $rank, position: $position}';
  }

  bool flipCard() {
    isFlipped = !isFlipped;
    return isFlipped;
  }

  poker.Card toPokerCard() {
    // Convert PlayingCard to poker.Card
    Map<String, String> suitMap = {
      'Hearts': 'h',
      'Diamonds': 'd',
      'Clubs': 'c',
      'Spades': 's'
    };
    return poker.Card(
        rank: poker.Rank.fromIndex(rank - 2),
        suit: poker.Suit.parse(suitMap[suit]!));
  }
}
