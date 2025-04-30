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

/// checks if the cards contain a royal flush
/// a royal flush is A, K, Q, J, 10 of the same suit
/// returns true if the cards contain a royal flush, false otherwise
bool _isRoyalFlush(List<Card> cards) {
  final bySuit = _groupCardsBySuit(cards);

  // check each suit group that has at least 5 cards
  for (final suitCards in bySuit.values) {
    if (suitCards.length >= 5) {
      // check for A, K, Q, J, 10 of the same suit
      bool hasAce = suitCards.any((card) => card.rank == CardRank.ace);
      bool hasKing = suitCards.any((card) => card.rank == CardRank.king);
      bool hasQueen = suitCards.any((card) => card.rank == CardRank.queen);
      bool hasJack = suitCards.any((card) => card.rank == CardRank.jack);
      bool hasTen = suitCards.any((card) => card.rank == CardRank.ten);

      if (hasAce && hasKing && hasQueen && hasJack && hasTen) {
        return true;
      }
    }
  }
  return false;
}

/// creates a royal flush hand result
/// finds the specific A, K, Q, J, 10 cards that form the royal flush
/// returns a HandResult with type HandType.royalFlush and the relevant cards
HandResult _createRoyalFlushResult(List<Card> cards) {
  final bySuit = _groupCardsBySuit(cards);

  for (final suit in bySuit.keys) {
    final suitCards = bySuit[suit]!;

    // check for A, K, Q, J, 10 of the same suit
    final ace = suitCards.firstWhere((card) => card.rank == CardRank.ace,
        orElse: () => Card(
            CardRank.two, Suit.clubs) // Default that should never be reached
        );

    final king = suitCards.firstWhere((card) => card.rank == CardRank.king,
        orElse: () => Card(CardRank.two, Suit.clubs));

    final queen = suitCards.firstWhere((card) => card.rank == CardRank.queen,
        orElse: () => Card(CardRank.two, Suit.clubs));

    final jack = suitCards.firstWhere((card) => card.rank == CardRank.jack,
        orElse: () => Card(CardRank.two, Suit.clubs));

    final ten = suitCards.firstWhere((card) => card.rank == CardRank.ten,
        orElse: () => Card(CardRank.two, Suit.clubs));

    if (ace.rank == CardRank.ace &&
        king.rank == CardRank.king &&
        queen.rank == CardRank.queen &&
        jack.rank == CardRank.jack &&
        ten.rank == CardRank.ten) {
      return HandResult(HandType.royalFlush, [ace, king, queen, jack, ten]);
    }
  }

  // This should never happen if _isRoyalFlush was true
  throw StateError('Failed to create royal flush result');
}

/// checks if the cards contain a straight flush (5 sequential cards of the same suit)
/// returns true if the cards contain a straight flush, false otherwise
bool _isStraightFlush(List<Card> cards) {
  final bySuit = _groupCardsBySuit(cards);

  for (final suitCards in bySuit.values) {
    if (suitCards.length >= 5) {
      // check for 5 cards in sequence
      if (_containsStraight(suitCards)) {
        return true;
      }
    }
  }
  return false;
}

/// creates a straight flush hand result
/// finds the 5 highest sequential cards of the same suit
/// returns a HandResult with type HandType.straightFlush and the relevant cards
HandResult _createStraightFlushResult(List<Card> cards) {
  final bySuit = _groupCardsBySuit(cards);

  for (final suit in bySuit.keys) {
    final suitCards = bySuit[suit]!;
    if (suitCards.length >= 5) {
      final straightCards = _findStraightCards(suitCards);
      if (straightCards.isNotEmpty) {
        return HandResult(HandType.straightFlush, straightCards);
      }
    }
  }

  // This should never happen if _isStraightFlush was true
  throw StateError('Failed to create straight flush result');
}

/// helper method to check if a list of cards contains a straight
/// a straight is 5 cards in sequential rank (e.g., 5-6-7-8-9)
/// also handles the special case A-2-3-4-5 where Ace is low
bool _containsStraight(List<Card> cards) {
  if (cards.length < 5) return false;

  // Sort by rank
  final sortedCards = _sortCardsByRankDescending(cards);

  // Handle the special case for A-5-4-3-2 (Ace can be low)
  final hasAce = sortedCards.any((card) => card.rank == CardRank.ace);
  final hasFive = sortedCards.any((card) => card.rank == CardRank.five);
  final hasFour = sortedCards.any((card) => card.rank == CardRank.four);
  final hasThree = sortedCards.any((card) => card.rank == CardRank.three);
  final hasTwo = sortedCards.any((card) => card.rank == CardRank.two);

  if (hasAce && hasFive && hasFour && hasThree && hasTwo) {
    return true;
  }

  // Check for regular straights
  // Get distinct ranks to handle duplicates
  final distinctRanks = sortedCards.map((card) => card.rank).toSet().toList();
  distinctRanks.sort((a, b) => b.index.compareTo(a.index));

  for (int i = 0; i <= distinctRanks.length - 5; i++) {
    bool isStraight = true;
    for (int j = 0; j < 4; j++) {
      if (distinctRanks[i + j].index != distinctRanks[i + j + 1].index + 1) {
        isStraight = false;
        break;
      }
    }
    if (isStraight) return true;
  }

  return false;
}

/// helper method to find the cards that form a straight
/// returns the 5 highest sequential cards or the wheel (A-5-4-3-2)
List<Card> _findStraightCards(List<Card> cards) {
  final sortedCards = _sortCardsByRankDescending(cards);

  // Handle the special case for A-5-4-3-2
  final hasAce = sortedCards.any((card) => card.rank == CardRank.ace);
  final hasFive = sortedCards.any((card) => card.rank == CardRank.five);
  final hasFour = sortedCards.any((card) => card.rank == CardRank.four);
  final hasThree = sortedCards.any((card) => card.rank == CardRank.three);
  final hasTwo = sortedCards.any((card) => card.rank == CardRank.two);

  if (hasAce && hasFive && hasFour && hasThree && hasTwo) {
    final ace = sortedCards.firstWhere((card) => card.rank == CardRank.ace);
    final five = sortedCards.firstWhere((card) => card.rank == CardRank.five);
    final four = sortedCards.firstWhere((card) => card.rank == CardRank.four);
    final three = sortedCards.firstWhere((card) => card.rank == CardRank.three);
    final two = sortedCards.firstWhere((card) => card.rank == CardRank.two);
    return [ace, five, four, three, two];
  }

  // Get distinct rank cards (taking the highest suit for each rank)
  final distinctRankMap = <CardRank, Card>{};
  for (final card in sortedCards) {
    if (!distinctRankMap.containsKey(card.rank) ||
        card.suit.index > distinctRankMap[card.rank]!.suit.index) {
      distinctRankMap[card.rank] = card;
    }
  }

  final distinctRankCards = distinctRankMap.values.toList();
  distinctRankCards.sort((a, b) => b.value.compareTo(a.value));

  // check for regular straights
  for (int i = 0; i <= distinctRankCards.length - 5; i++) {
    bool isStraight = true;
    for (int j = 0; j < 4; j++) {
      if (distinctRankCards[i + j].value !=
          distinctRankCards[i + j + 1].value + 1) {
        isStraight = false;
        break;
      }
    }
    if (isStraight) {
      return distinctRankCards.sublist(i, i + 5);
    }
  }

  return [];
}

/// checks if the cards contain four of a kind (4 cards of the same rank)
/// returns true if the cards contain four of a kind, false otherwise
bool _isFourOfAKind(List<Card> cards) {
  final byRank = _groupCardsByRank(cards);
  return byRank.values.any((rankCards) => rankCards.length >= 4);
}

/// creates a four of a kind hand result
/// finds the 4 cards of the same rank plus the highest kicker
/// returns a HandResult with type HandType.fourOfAKind and the relevant cards
HandResult _createFourOfAKindResult(List<Card> cards) {
  final byRank = _groupCardsByRank(cards);
  final fourOfAKind =
      byRank.entries.firstWhere((entry) => entry.value.length >= 4);

  // get the four cards of the same rank
  final fourCards = fourOfAKind.value.take(4).toList();

  // get the highest remaining card as the kicker
  final remainingCards =
      cards.where((card) => card.rank != fourOfAKind.key).toList();

  final kicker = _sortCardsByRankDescending(remainingCards).first;

  return HandResult(HandType.fourOfAKind, [...fourCards, kicker]);
}

/// checks if the cards contain a full house (three of a kind plus a pair)
/// returns true if the cards contain a full house, false otherwise
bool _isFullHouse(List<Card> cards) {
  final byRank = _groupCardsByRank(cards);

  bool hasThreeOfKind = false;
  bool hasPair = false;
  CardRank? threeOfKindRank;

  for (final entry in byRank.entries) {
    if (entry.value.length >= 3) {
      hasThreeOfKind = true;
      threeOfKindRank = entry.key;
      break;
    }
  }

  if (hasThreeOfKind) {
    for (final entry in byRank.entries) {
      if (entry.key != threeOfKindRank && entry.value.length >= 2) {
        hasPair = true;
        break;
      }
    }
  }

  return hasThreeOfKind && hasPair;
}

/// creates a full house hand result
/// finds the 3 cards of the highest rank plus 2 cards of the next highest rank
/// returns a HandResult with type HandType.fullHouse and the relevant cards
HandResult _createFullHouseResult(List<Card> cards) {
  final byRank = _groupCardsByRank(cards);

  // Find three of a kind with highest rank
  var threeOfAKindEntries = byRank.entries
      .where((entry) => entry.value.length >= 3)
      .toList()
    ..sort((a, b) => b.key.index.compareTo(a.key.index));

  final threeOfAKind = threeOfAKindEntries.first.value.take(3).toList();
  final threeOfAKindRank = threeOfAKindEntries.first.key;

  // Find pair with highest rank
  var pairEntries = byRank.entries
      .where(
          (entry) => entry.key != threeOfAKindRank && entry.value.length >= 2)
      .toList()
    ..sort((a, b) => b.key.index.compareTo(a.key.index));

  final pair = pairEntries.first.value.take(2).toList();

  return HandResult(HandType.fullHouse, [...threeOfAKind, ...pair]);
}

/// checks if the cards contain a flush (5 cards of the same suit)
/// returns true if the cards contain a flush, false otherwise
bool _isFlush(List<Card> cards) {
  final bySuit = _groupCardsBySuit(cards);
  return bySuit.values.any((suitCards) => suitCards.length >= 5);
}

/// creates a flush hand result
/// finds the 5 highest cards of the same suit
/// returns a HandResult with type HandType.flush and the relevant cards
HandResult _createFlushResult(List<Card> cards) {
  final bySuit = _groupCardsBySuit(cards);

  // Find the suit with at least 5 cards
  final flushSuitEntry =
      bySuit.entries.firstWhere((entry) => entry.value.length >= 5);

  // Get the 5 highest cards of that suit
  final flushCards =
      _sortCardsByRankDescending(flushSuitEntry.value).take(5).toList();

  return HandResult(HandType.flush, flushCards);
}

/// checks if the cards contain a straight (5 sequential cards)
/// returns true if the cards contain a straight, false otherwise
bool _isStraight(List<Card> cards) {
  return _containsStraight(cards);
}

/// creates a straight hand result
/// finds the 5 highest sequential cards
/// returns a HandResult with type HandType.straight and the relevant cards
HandResult _createStraightResult(List<Card> cards) {
  final straightCards = _findStraightCards(cards);
  return HandResult(HandType.straight, straightCards);
}

/// checks if the cards contain three of a kind (3 cards of the same rank)
/// returns true if the cards contain three of a kind, false otherwise
bool _isThreeOfAKind(List<Card> cards) {
  final byRank = _groupCardsByRank(cards);
  return byRank.values.any((rankCards) => rankCards.length >= 3);
}

/// creates a three of a kind hand result
/// finds the 3 cards of the same rank plus the 2 highest kickers
/// returns a HandResult with type HandType.threeOfAKind and the relevant cards
HandResult _createThreeOfAKindResult(List<Card> cards) {
  final byRank = _groupCardsByRank(cards);

  // Find three of a kind with highest rank
  final threeOfAKindEntries = byRank.entries
      .where((entry) => entry.value.length >= 3)
      .toList()
    ..sort((a, b) => b.key.index.compareTo(a.key.index));

  final threeOfAKindRank = threeOfAKindEntries.first.key;
  final threeCards = threeOfAKindEntries.first.value.take(3).toList();

  // get the two highest remaining cards as kickers
  final kickers = _sortCardsByRankDescending(
          cards.where((card) => card.rank != threeOfAKindRank).toList())
      .take(2)
      .toList();

  return HandResult(HandType.threeOfAKind, [...threeCards, ...kickers]);
}

/// checks if the cards contain two pair (2 sets of 2 cards of the same rank)
/// returns true if the cards contain two pair, false otherwise
bool _isTwoPair(List<Card> cards) {
  final byRank = _groupCardsByRank(cards);
  final pairs =
      byRank.values.where((rankCards) => rankCards.length >= 2).length;
  return pairs >= 2;
}

/// creates a two pair hand result
/// finds the 2 highest pairs plus the highest kicker
/// returns a HandResult with type HandType.twoPair and the relevant cards
HandResult _createTwoPairResult(List<Card> cards) {
  final byRank = _groupCardsByRank(cards);

  // Find the two highest pairs
  final pairRanks = byRank.entries
      .where((entry) => entry.value.length >= 2)
      .toList()
    ..sort((a, b) => b.key.index.compareTo(a.key.index));

  final highPair = pairRanks[0].value.take(2).toList();
  final lowPair = pairRanks[1].value.take(2).toList();

  // get the highest remaining card as kicker
  final usedRanks = [pairRanks[0].key, pairRanks[1].key];
  final kicker = _sortCardsByRankDescending(
          cards.where((card) => !usedRanks.contains(card.rank)).toList())
      .take(1)
      .toList();

  return HandResult(HandType.twoPair, [...highPair, ...lowPair, ...kicker]);
}

/// checks if the cards contain a pair (2 cards of the same rank)
/// returns true if the cards contain a pair, false otherwise
bool _isPair(List<Card> cards) {
  final byRank = _groupCardsByRank(cards);
  return byRank.values.any((rankCards) => rankCards.length >= 2);
}

/// creates a pair hand result
/// finds the highest pair plus the 3 highest kickers
/// returns a HandResult with type HandType.pair and the relevant cards
HandResult _createPairResult(List<Card> cards) {
  final byRank = _groupCardsByRank(cards);

  // find the highest pair
  final pairEntries = byRank.entries
      .where((entry) => entry.value.length >= 2)
      .toList()
    ..sort((a, b) => b.key.index.compareTo(a.key.index));

  final pairRank = pairEntries.first.key;
  final pairCards = pairEntries.first.value.take(2).toList();

  // get the three highest remaining cards as kickers
  final kickers = _sortCardsByRankDescending(
          cards.where((card) => card.rank != pairRank).toList())
      .take(3)
      .toList();

  return HandResult(HandType.pair, [...pairCards, ...kickers]);
}

/// creates a high card hand result
/// finds the 5 highest cards
/// returns a HandResult with type HandType.highCard and the relevant cards
HandResult _createHighCardResult(List<Card> cards) {
  // get the 5 highest cards
  final highCards = _sortCardsByRankDescending(cards).take(5).toList();
  return HandResult(HandType.highCard, highCards);
}

/// calculates the probability of a player winning based on their hand,
/// the community cards, and the number of opponents
/// uses an adaptive simulation approach that becomes more precise in later rounds
double calculateWinProbability({
  required List<Card> playerHand,
  required List<Card> communityCards,
  required int numberOfOpponents,
}) {
  // validate inputs
  if (playerHand.length != 2) {
    throw ArgumentError('player hand must contain exactly 2 cards');
  }

  if (communityCards.length > 5) {
    throw ArgumentError('community cards cannot exceed 5');
  }

  if (numberOfOpponents < 1) {
    throw ArgumentError('number of opponents must be at least 1');
  }

  // determine the current game stage
  final gameStage = _determineGameStage(communityCards.length);

  // create a set of all cards in a deck
  final allCards = _generateDeck();

  // remove cards that are already known (player hand and community cards)
  final knownCards = [...playerHand, ...communityCards];
  for (final card in knownCards) {
    allCards.remove(card);
  }

  // remaining cards in the deck
  final remainingDeck = allCards.toList();

  // use different simulation counts based on game stage
  // more simulations for later stages (fewer unknowns)
  int simulationCount;
  switch (gameStage) {
    case 'preflop':
      simulationCount = 5000; // increased from 2000
      break;
    case 'flop':
      simulationCount = 7000; // increased from 3000
      break;
    case 'turn':
      simulationCount = 10000; // increased from 5000
      break;
    case 'river':
      // on the river, we can do exact calculation because there are no more cards to come
      return _calculateRiverExact(
          playerHand: playerHand,
          communityCards: communityCards,
          remainingDeck: remainingDeck,
          numberOfOpponents: numberOfOpponents);
    default:
      simulationCount = 5000;
  }

  // run monte carlo simulation
  return _runMonteCarloSimulation(
      playerHand: playerHand,
      communityCards: communityCards,
      remainingDeck: remainingDeck,
      numberOfOpponents: numberOfOpponents,
      simulationCount: simulationCount);
}

/// determines the current stage of the game based on community card count
String _determineGameStage(int communityCardCount) {
  switch (communityCardCount) {
    case 0:
      return 'preflop';
    case 3:
      return 'flop';
    case 4:
      return 'turn';
    case 5:
      return 'river';
    default:
      return 'unknown';
  }
}

/// runs a monte carlo simulation to estimate win probability
double _runMonteCarloSimulation({
  required List<Card> playerHand,
  required List<Card> communityCards,
  required List<Card> remainingDeck,
  required int numberOfOpponents,
  required int simulationCount,
}) {
  int wins = 0;
  int ties = 0;

  // number of community cards to be dealt
  final communityCardsToAdd = 5 - communityCards.length;

  for (int i = 0; i < simulationCount; i++) {
    // shuffle the deck for this simulation
    final shuffledDeck = List<Card>.from(remainingDeck)..shuffle();

    // deal community cards
    final drawnCommunityCards = shuffledDeck.take(communityCardsToAdd).toList();
    final completeCommunityCards = [...communityCards, ...drawnCommunityCards];

    // evaluate player's hand
    final playerHandResult = evaluateHand(
        playerHand: playerHand, communityCards: completeCommunityCards);

    // track if this scenario results in a win, tie, or loss
    bool isWin = true;
    bool isTie = false;

    // start at the index after the community cards
    int currentIndex = communityCardsToAdd;

    for (int j = 0; j < numberOfOpponents; j++) {
      // ensure we have enough cards left for this opponent
      if (currentIndex + 1 >= shuffledDeck.length) {
        break;
      }

      final opponentHand = [
        shuffledDeck[currentIndex],
        shuffledDeck[currentIndex + 1]
      ];
      currentIndex += 2;

      final opponentHandResult = evaluateHand(
          playerHand: opponentHand, communityCards: completeCommunityCards);

      // compare hand types first
      if (opponentHandResult.type.index > playerHandResult.type.index) {
        // opponent has a better hand type
        isWin = false;
        isTie = false;
        break; // one opponent with a better hand means player loses
      } else if (opponentHandResult.type.index == playerHandResult.type.index) {
        // same hand type, need to compare the relevant cards
        bool playerHasBetterCards = _compareRelevantCards(
            playerHandResult.relevantCards, opponentHandResult.relevantCards);

        if (!playerHasBetterCards) {
          // check if it's a true tie by comparing the other way around
          bool opponentHasBetterCards = _compareRelevantCards(
              opponentHandResult.relevantCards, playerHandResult.relevantCards);

          if (opponentHasBetterCards) {
            // opponent has better cards within the same hand type
            isWin = false;
            isTie = false;
            break; // one opponent with a better hand means player loses
          } else {
            // it's a true tie
            isWin = false;
            isTie = true;
            // don't break, continue checking other opponents
          }
        }
        // if player has better cards, continue checking other opponents
      }
      // if player has a better hand type, continue checking other opponents
    }

    if (isWin) {
      wins++;
    } else if (isTie) {
      ties++;
    }
  }

  // return probability (counting ties as half-wins)
  // in poker, ties result in splitting the pot, so a tie is worth 0.5 wins
  return (wins + ties * 0.5) / simulationCount;
}

bool _compareRelevantCards(
    List<Card> relevantCards, List<Card> relevantCards2) {
  return false;
}

/// calculates exact win probability on the river (all community cards known)
/// only opponents' hands are unknown
double _calculateRiverExact({
  required List<Card> playerHand,
  required List<Card> communityCards,
  required List<Card> remainingDeck,
  required int numberOfOpponents,
}) {
  // evaluate the player's hand
  final playerHandResult =
      evaluateHand(playerHand: playerHand, communityCards: communityCards);

  int totalScenarios = 0;
  int wins = 0;

  // if we have just one opponent, we can enumerate all possible hands
  if (numberOfOpponents == 1) {
    // generate all possible 2-card opponent hands
    final opponentHands = _generateCombinations(remainingDeck, 2);

    for (final opponentHand in opponentHands) {
      totalScenarios++;

      final opponentHandResult = evaluateHand(
          playerHand: opponentHand, communityCards: communityCards);

      // player wins if their hand is better (ties count as losses)
      if (playerHandResult > opponentHandResult) {
        wins++;
      }
    }

    return wins / totalScenarios;
  } else {
    // for multiple opponents, fall back to simulation
    // even on the river, exact calculation with multiple opponents is expensive
    return _runMonteCarloSimulation(
        playerHand: playerHand,
        communityCards: communityCards,
        remainingDeck: remainingDeck,
        numberOfOpponents: numberOfOpponents,
        simulationCount: 5000 // higher count for river
        );
  }
}

/// generates all possible combinations of k cards from a deck
List<List<Card>> _generateCombinations(List<Card> deck, int k) {
  final result = <List<Card>>[];

  // base cases
  if (k == 0) {
    result.add([]);
    return result;
  }

  if (k > deck.length) {
    return result;
  }

  // recursive combination generation
  _generateCombinationsHelper(deck, k, 0, [], result);

  return result;
}

/// helper function for generating combinations
void _generateCombinationsHelper(
  List<Card> deck,
  int k,
  int start,
  List<Card> current,
  List<List<Card>> result,
) {
  // if we've selected k cards, add this combination
  if (current.length == k) {
    result.add(List<Card>.from(current));
    return;
  }

  // try each card that hasn't been used yet
  for (int i = start; i < deck.length; i++) {
    // add this card to our combination
    current.add(deck[i]);

    // recursively generate combinations with this card included
    _generateCombinationsHelper(deck, k, i + 1, current, result);

    // remove this card to try the next one
    current.removeLast();
  }
}

/// generates a complete deck of 52 cards
Set<Card> _generateDeck() {
  final deck = <Card>{};

  for (final suit in Suit.values) {
    for (final rank in CardRank.values) {
      deck.add(Card(rank, suit));
    }
  }

  return deck;
}
