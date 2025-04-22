///
/// THIS MODULE TRIES TO CALCULATES THE PROBABILITY OF A PLAYER WINNING A GAME OF
/// POKER BASED ON THEIR CURRENT HAND AND THE STATE OF THE GAME.
///
/// THE MODULE SHOULD QUERY A[T LEAST ONE] DATABASE IN ORDER TO FETCH PARAMETERS.
/// IT WILL TRY TO RETREIVE:
/// - THE HAND (2 CARDS)
/// - CARDS ON THE TABLE (3-5 CARDS)
/// - THE CARDS CURRENTLY IN THE DECK (ALSO INCLUDES THE PLAYERS' HANDS)
///
/// THE MODULE SHOULD RETURN A NUMERICAL VALUE SHOWING THE PROABILITY OF A PLAYER
/// WINNING GIVEN THEIR PARTICULAR HAND.
library;

class Card {
  final String rank;
  final String suit;
  late final int numericRank;

  Card(this.rank, this.suit) {
    numericRank = _getNumericRank();
  }

  int _getNumericRank() {
    switch (rank) {
      case 'A':
        return 14;
      case 'K':
        return 13;
      case 'Q':
        return 12;
      case 'J':
        return 11;
      case '10':
        return 10;
      case '9':
        return 9;
      case '8':
        return 8;
      case '7':
        return 7;
      case '6':
        return 6;
      case '5':
        return 5;
      case '4':
        return 4;
      case '3':
        return 3;
      case '2':
        return 2;
      default:
        return int.tryParse(rank) ?? 0;
    }
  }
}

class HandEvaluator {
  static const int HIGH_CARD = 1;
  static const int PAIR = 2;
  static const int TWO_PAIR = 3;
  static const int THREE_OF_A_KIND = 4;
  static const int STRAIGHT = 5;
  static const int FLUSH = 6;
  static const int FULL_HOUSE = 7;
  static const int FOUR_OF_A_KIND = 8;
  static const int STRAIGHT_FLUSH = 9;
  static const int ROYAL_FLUSH = 10;

  static const Map<int, String> handRankNames = {
    1: "High Card",
    2: "Pair",
    3: "Two Pair",
    4: "Three of a Kind",
    5: "Straight",
    6: "Flush",
    7: "Full House",
    8: "Four of a Kind",
    9: "Straight Flush",
    10: "Royal Flush"
  };
}
