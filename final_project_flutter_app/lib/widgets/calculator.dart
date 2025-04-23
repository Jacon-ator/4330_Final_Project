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

/// Represents the suit of a playing card
enum Suit { clubs, diamonds, hearts, spades }

/// Represents the rank of a playing card
enum Rank {
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  ace
}

/// represents an individual card
class Card {
  final Rank rank;
  final Suit suit;

  /// returns a numerical value representing the rank of the card
  /// (2 = 0, 3 = 1, ..., Ace = 12)
  int get value => rank.index;

  /// generic constructor for creating cards
  const Card(this.rank, this.suit);

  /// override == operator for proper equality comparison
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Card && other.rank == rank && other.suit == suit;
  }

  /// override hashCode for proper use in collections
  @override
  int get hashCode => rank.hashCode ^ suit.hashCode;

  /// creates a card from a standard string representation (e.g., "AS" for Ace of Spades)
  factory Card.fromString(String str) {
    if (str.length != 2)
      throw FormatException('Card string must be 2 characters');

    Rank rank;
    switch (str[0]) {
      case 'A':
        rank = Rank.ace;
        break;
      case 'K':
        rank = Rank.king;
        break;
      case 'Q':
        rank = Rank.queen;
        break;
      case 'J':
        rank = Rank.jack;
        break;
      case 'T':
        rank = Rank.ten;
        break;
      default:
        final rankValue = int.tryParse(str[0]);
        if (rankValue == null || rankValue < 2 || rankValue > 9)
          throw FormatException('Invalid rank: ${str[0]}');
        rank = Rank.values[rankValue - 2];
    }

    Suit suit;
    switch (str[1]) {
      case 'C':
        suit = Suit.clubs;
        break;
      case 'D':
        suit = Suit.diamonds;
        break;
      case 'H':
        suit = Suit.hearts;
        break;
      case 'S':
        suit = Suit.spades;
        break;
      default:
        throw FormatException('Invalid suit: ${str[1]}');
    }

    return Card(rank, suit);
  }

  /// returns a string representation of the card in format "RS"
  /// where R is the rank (2-9, T, J, Q, K, A) and S is the suit (C, D, H, S)
  @override
  String toString() {
    String rankStr;
    switch (rank) {
      case Rank.ace:
        rankStr = 'A';
        break;
      case Rank.king:
        rankStr = 'K';
        break;
      case Rank.queen:
        rankStr = 'Q';
        break;
      case Rank.jack:
        rankStr = 'J';
        break;
      case Rank.ten:
        rankStr = 'T';
        break;
      default:
        rankStr = (rank.index + 2).toString();
    }

    String suitStr;
    switch (suit) {
      case Suit.clubs:
        suitStr = 'C';
        break;
      case Suit.diamonds:
        suitStr = 'D';
        break;
      case Suit.hearts:
        suitStr = 'H';
        break;
      case Suit.spades:
        suitStr = 'S';
        break;
    }

    return '$rankStr$suitStr';
  }
}
