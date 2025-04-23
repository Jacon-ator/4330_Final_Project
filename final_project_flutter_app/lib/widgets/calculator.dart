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

/// represents the suit of a playing card
enum Suit { clubs, diamonds, hearts, spades }

/// represents the rank of a playing card
enum CardRank {
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

/// represents the rank of a particular hand
enum HandType {
  highCard,
  pair,
  twoPair,
  threeOfAKind,
  straight,
  flush,
  fullHouse,
  fourOfAKind,
  straightFlush,
  royalFlush
}

/// represents an individual card
class Card {
  final CardRank rank;
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

  /// implement > operator for comparing cards by rank
  bool operator >(Card other) => value > other.value;

  /// implement < operator for comparing cards by rank
  bool operator <(Card other) => value < other.value;

  /// implement >= operator for comparing cards by rank
  bool operator >=(Card other) => value >= other.value;

  /// implement <= operator for comparing cards by rank
  bool operator <=(Card other) => value <= other.value;

  /// override hashCode for proper use in collections
  @override
  int get hashCode => rank.hashCode ^ suit.hashCode;

  /// creates a card from a standard string representation (e.g., "AS" for Ace of Spades)
  factory Card.fromString(String str) {
    if (str.length != 2)
      throw FormatException('Card string must be 2 characters');

    CardRank rank;
    switch (str[0]) {
      case 'A':
        rank = CardRank.ace;
        break;
      case 'K':
        rank = CardRank.king;
        break;
      case 'Q':
        rank = CardRank.queen;
        break;
      case 'J':
        rank = CardRank.jack;
        break;
      case 'T':
        rank = CardRank.ten;
        break;
      default:
        final rankValue = int.tryParse(str[0]);
        if (rankValue == null || rankValue < 2 || rankValue > 9)
          throw FormatException('Invalid rank: ${str[0]}');
        rank = CardRank.values[rankValue - 2];
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
      case CardRank.ace:
        rankStr = 'A';
        break;
      case CardRank.king:
        rankStr = 'K';
        break;
      case CardRank.queen:
        rankStr = 'Q';
        break;
      case CardRank.jack:
        rankStr = 'J';
        break;
      case CardRank.ten:
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

/// represents the result of a hand evaluation
class HandResult {
  final HandType type;
  final List<Card> relevantCards;

  HandResult(this.type, this.relevantCards);

  /// this will be likely used to compare other player's hands
  bool operator >(HandResult other) => type.index > other.type.index;
  bool operator <(HandResult other) => type.index < other.type.index;
  bool operator >=(HandResult other) => type.index >= other.type.index;
  bool operator <=(HandResult other) => type.index <= other.type.index;

  @override
  String toString() {
    return 'HandResult{type: $type, relevantCards: $relevantCards}';
  }
}

/// helper method to group cards by suit
/// takes a list of cards and creates a map where
/// keys are suits and values are lists of cards of that suit
/// example: {Clubs: [AC, 2C, 3C], Hearts: [KH, QH]}
Map<Suit, List<Card>> _groupCardsBySuit(List<Card> cards) {
  final result = <Suit, List<Card>>{};
  for (final card in cards) {
    if (!result.containsKey(card.suit)) {
      result[card.suit] = [];
    }
    result[card.suit]!.add(card);
  }
  return result;
}

/// helper method to group cards by rank
/// takes a list of cards and creates a map where
/// keys are ranks and values are lists of cards of that rank
/// example: {Ace: [AC, AH], King: [KD, KS]}
/// useful for finding pairs, three of a kind, etc.
Map<CardRank, List<Card>> _groupCardsByRank(List<Card> cards) {
  final result = <CardRank, List<Card>>{};
  for (final card in cards) {
    if (!result.containsKey(card.rank)) {
      result[card.rank] = [];
    }
    result[card.rank]!.add(card);
  }
  return result;
}

/// sorts cards by rank in descending order (highest first)
/// creates a new sorted list without modifying the original
/// example: [AC, KD, QH, 5S, 2C] becomes [AC, KD, QH, 5S, 2C]
/// useful for evaluating high card hands and kickers
List<Card> _sortCardsByRankDescending(List<Card> cards) {
  final sortedCards = List<Card>.from(cards);
  sortedCards.sort((a, b) => b.value.compareTo(a.value));
  return sortedCards;
}

/// evaluates the best possible poker hand from the combined player hand and community cards
/// returns a HandResult with the type and relevant cards
/// this is the main entry point for hand evaluation
HandResult evaluateHand({
  required List<Card> playerHand,
  required List<Card> communityCards,
}) {
  // combine player hand and community cards to get all available cards
  final allCards = [...playerHand, ...communityCards];
  
  // check for each hand type in descending order (best to worst)
  // as soon as a match is found, return the corresponding result
  if (_isRoyalFlush(allCards)) {
    return _createRoyalFlushResult(allCards);
  } else if (_isStraightFlush(allCards)) {
    return _createStraightFlushResult(allCards);
  } else if (_isFourOfAKind(allCards)) {
    return _createFourOfAKindResult(allCards);
  } else if (_isFullHouse(allCards)) {
    return _createFullHouseResult(allCards);
  } else if (_isFlush(allCards)) {
    return _createFlushResult(allCards);
  } else if (_isStraight(allCards)) {
    return _createStraightResult(allCards);
  } else if (_isThreeOfAKind(allCards)) {
    return _createThreeOfAKindResult(allCards);
  } else if (_isTwoPair(allCards)) {
    return _createTwoPairResult(allCards);
  } else if (_isPair(allCards)) {
    return _createPairResult(allCards);
  } else {
    // if no better hand is found, it's a high card hand
    return _createHighCardResult(allCards);
  }
}