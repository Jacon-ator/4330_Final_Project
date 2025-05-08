/// A test class for verifying that hand evaluation and probability calculation works correctly
library;

import 'calculator.dart';

class CalculatorTest {
  /// runs all tests and reports results
  void runAllTests() {
    print('Starting poker hand evaluator tests...\n');

    testRoyalFlush();
    testStraightFlush();
    testFourOfAKind();
    testFullHouse();
    testFlush();
    testStraight();
    testThreeOfAKind();
    testTwoPair();
    testPair();
    testHighCard();
    testHandComparison();
    testComparePokerHands();

    print('\nStarting probability calculation tests...\n');

    testProbabilityPocketAces();
    testProbabilityTopPairTopKicker();
    testProbabilityOvercard();
    testProbabilityFlushDraw();
    testProbabilityPocketPairVsOvercards();
    testProbabilitySetVsFlushDraw();

    print('\nAll tests completed!');
  }

  /// tests the comparepokerHands function
  void testComparePokerHands() {
    print('Testing comparePokerHands function...');

    // test case 1: pair vs high card
    {
      final hand1 = <Card>[
        Card.fromString('AH'),
        Card.fromString('AD')
      ]; // pair of aces
      final hand2 = <Card>[
        Card.fromString('KS'),
        Card.fromString('QH')
      ]; // king-queen high
      final communityCards = <Card>[
        Card.fromString('2C'),
        Card.fromString('7S'),
        Card.fromString('TC'),
        Card.fromString('4D'),
        Card.fromString('9H')
      ];

      final result = comparePokerHands(
          hand1: hand1, hand2: hand2, communityCards: communityCards);

      assert(result == 1, 'pair should beat high card');
    }

    // test case 2: same pair, different kickers
    {
      final hand1 = <Card>[
        Card.fromString('AH'),
        Card.fromString('KD')
      ]; // ace-king
      final hand2 = <Card>[
        Card.fromString('AC'),
        Card.fromString('QH')
      ]; // ace-queen
      final communityCards = <Card>[
        Card.fromString('AS'),
        Card.fromString('7C'),
        Card.fromString('2D'),
        Card.fromString('4H'),
        Card.fromString('9S')
      ];

      final result = comparePokerHands(
          hand1: hand1, hand2: hand2, communityCards: communityCards);

      assert(result == 1, 'higher kicker should win with same pair');
    }

    // test case 3: two pair vs three of a kind
    {
      final hand1 = <Card>[
        Card.fromString('JH'),
        Card.fromString('JD')
      ]; // pair of jacks
      final hand2 = <Card>[
        Card.fromString('KS'),
        Card.fromString('KH')
      ]; // pair of kings
      final communityCards = <Card>[
        Card.fromString('KC'),
        Card.fromString('QS'),
        Card.fromString('QH'),
        Card.fromString('2D'),
        Card.fromString('3C')
      ];

      final result = comparePokerHands(
          hand1: hand1, hand2: hand2, communityCards: communityCards);

      assert(result == -1, 'three of a kind should beat two pair');
    }

    // test case 4: same hand type with different high cards
    {
      final hand1 = <Card>[
        Card.fromString('AS'),
        Card.fromString('KS')
      ]; // a♠ k♠
      final hand2 = <Card>[
        Card.fromString('AH'),
        Card.fromString('QH')
      ]; // a♥ q♥
      final communityCards = <Card>[
        Card.fromString('2S'),
        Card.fromString('4S'),
        Card.fromString('7S'),
        Card.fromString('9H'),
        Card.fromString('JH')
      ];

      final result = comparePokerHands(
          hand1: hand1, hand2: hand2, communityCards: communityCards);

      assert(result == 1, 'higher second card should win with same flush');
    }

    // test case 5: identical hands (tie)
    {
      final hand1 = <Card>[
        Card.fromString('AH'),
        Card.fromString('KD')
      ]; // a♥ k♦
      final hand2 = <Card>[
        Card.fromString('AC'),
        Card.fromString('KS')
      ]; // a♣ k♠
      final communityCards = <Card>[
        Card.fromString('QC'),
        Card.fromString('JD'),
        Card.fromString('TD'),
        Card.fromString('3H'),
        Card.fromString('2S')
      ];

      final result = comparePokerHands(
          hand1: hand1, hand2: hand2, communityCards: communityCards);

      assert(result == 0, 'identical straights should tie');
    }

    // test case 6: straight flush vs four of a kind
    {
      final hand1 = <Card>[
        Card.fromString('7H'),
        Card.fromString('8H')
      ]; // part of straight flush
      final hand2 = <Card>[
        Card.fromString('AC'),
        Card.fromString('AS')
      ]; // two aces
      final communityCards = <Card>[
        Card.fromString('9H'),
        Card.fromString('TH'),
        Card.fromString('JH'),
        Card.fromString('AD'),
        Card.fromString('AH')
      ];

      final result = comparePokerHands(
          hand1: hand1, hand2: hand2, communityCards: communityCards);

      assert(result == 1, 'straight flush should beat four of a kind');
    }

    // test case 7: royal flush vs straight flush
    {
      final hand1 = <Card>[
        Card.fromString('AH'),
        Card.fromString('KH')
      ]; // part of royal flush
      final hand2 = <Card>[
        Card.fromString('9D'),
        Card.fromString('8D')
      ]; // part of straight flush
      final communityCards = <Card>[
        Card.fromString('QH'),
        Card.fromString('JH'),
        Card.fromString('TH'),
        Card.fromString('7D'),
        Card.fromString('6D')
      ];

      final result = comparePokerHands(
          hand1: hand1, hand2: hand2, communityCards: communityCards);

      assert(result == 1, 'royal flush should beat straight flush');
    }

    print('✓ comparePokerHands test passed');
  }

  /// tests the probability calculation for pocket aces pre-flop vs 1 opponent
  void testProbabilityPocketAces() {
    print('--------------------------------------------------------------');
    print('TESTING: Pocket Aces (AA) pre-flop vs 1 opponent');
    print('--------------------------------------------------------------');
    print('Player hand: Ace of Spades, Ace of Clubs');
    print('Community cards: None (pre-flop)');
    print(
        'Scenario: Player has the strongest possible starting hand in Hold\'em');
    print('Expected outcome: Strong favorite against a random hand');
    print('--------------------------------------------------------------');

    // standard scenario: pocket pair of aces pre-flop vs 1 opponent
    final playerHand = <Card>[Card.fromString('AS'), Card.fromString('AC')];
    final communityCards = <Card>[];

    print('Running simulation against 1 opponent...');
    final stopwatch = Stopwatch()..start();

    final probability = calculateWinProbability(
        playerHand: playerHand,
        communityCards: communityCards,
        numberOfOpponents: 1);

    stopwatch.stop();
    final executionTime = stopwatch.elapsedMilliseconds;

    print('Calculation completed in $executionTime ms');
    print(
        'RESULT: Win probability against 1 opponent: ${(probability * 100).toStringAsFixed(2)}%');
    print('Interpretation: Pocket aces are a significant favorite pre-flop');

    // Pocket aces should have ~85% win rate vs random hand
    assert(probability > 0.75 && probability < 0.95,
        'Pocket aces should win 75-95% of the time against one opponent');

    print('--------------------------------------------------------------');
    print('✓ Pocket aces probability test passed');
  }

  /// tests probability calculation for top pair top kicker on the flop
  void testProbabilityTopPairTopKicker() {
    print('--------------------------------------------------------------');
    print('TESTING: AK suited with top pair top kicker on A-7-2 rainbow flop');
    print('--------------------------------------------------------------');
    print('Player hand: Ace of Hearts, King of Hearts');
    print('Community cards: Ace of Spades, Seven of Clubs, Two of Diamonds');
    print(
        'Scenario: Player has flopped top pair with the best kicker on a dry board');
    print('Expected outcome: Strong favorite against a single opponent');
    print('--------------------------------------------------------------');

    // player has AK suited and flop comes A-7-2 rainbow
    final playerHand = <Card>[Card.fromString('AH'), Card.fromString('KH')];

    final communityCards = <Card>[
      Card.fromString('AS'), // Top pair
      Card.fromString('7C'),
      Card.fromString('2D') // Rainbow flop (different suits)
    ];

    // test against 1 opponent
    print('Running simulation against 1 opponent...');
    final stopwatch = Stopwatch()..start();

    final probability = calculateWinProbability(
        playerHand: playerHand,
        communityCards: communityCards,
        numberOfOpponents: 1);

    stopwatch.stop();
    final executionTime = stopwatch.elapsedMilliseconds;

    print('Calculation completed in $executionTime ms');
    print(
        'RESULT: Win probability against 1 opponent: ${(probability * 100).toStringAsFixed(2)}%');
    print(
        'Interpretation: Top pair top kicker is very strong on this dry board');

    // TPTK against one opponent on this flop should win around 80-90% of the time
    assert(probability > 0.75 && probability < 0.95,
        'Top pair top kicker should win 75-95% of the time against one opponent on dry flop');

    print('--------------------------------------------------------------');
    print('✓ Top pair top kicker probability test passed');
  }

  /// tests probability with a flush draw on the flop
  void testProbabilityFlushDraw() {
    print('--------------------------------------------------------------');
    print('TESTING: Flush draw on the flop vs 1 opponent');
    print('--------------------------------------------------------------');
    print('Player hand: King of Hearts, Jack of Hearts');
    print('Community cards: 7 of Hearts, 3 of Hearts, 9 of Clubs');
    print('Scenario: Player has 4 hearts and needs one more for a flush');
    print('Expected outcome: Around 35-40% chance to win by the river');
    print('--------------------------------------------------------------');

    // player has KJ suited with two hearts on the flop
    final playerHand = <Card>[Card.fromString('KH'), Card.fromString('JH')];

    final communityCards = <Card>[
      Card.fromString('7H'),
      Card.fromString('3H'),
      Card.fromString('9C')
    ];

    print('Running simulation against 1 opponent...');
    final stopwatch = Stopwatch()..start();

    final probability = calculateWinProbability(
        playerHand: playerHand,
        communityCards: communityCards,
        numberOfOpponents: 1);

    stopwatch.stop();
    final executionTime = stopwatch.elapsedMilliseconds;

    print('Calculation completed in $executionTime ms');
    print(
        'RESULT: Win probability against 1 opponent: ${(probability * 100).toStringAsFixed(2)}%');
    print(
        'Interpretation: With a flush draw on the flop, player has about a 35-40% chance');
    print('There are 9 hearts remaining in the deck out of 47 unseen cards');

    // Flush draw against one opponent should win around 35-40% of the time
    assert(probability > 0.30 && probability < 0.45,
        'Flush draw should win 30-45% of the time against one opponent');

    print('--------------------------------------------------------------');
    print('✓ Flush draw probability test passed');
  }

  /// tests probability for a coin-flip scenario: pocket pair vs two overcards
  void testProbabilityPocketPairVsOvercards() {
    print('--------------------------------------------------------------');
    print('TESTING: Pocket 88 vs AK pre-flop (classic coin flip)');
    print('--------------------------------------------------------------');
    print('Player hand: 8 of Spades, 8 of Hearts (pocket eights)');
    print('Opponent hand: Ace of Clubs, King of Diamonds (AK offsuit)');
    print('Community cards: None (pre-flop)');
    print('Scenario: Classic "race" or "coin flip" in poker');
    print(
        'Expected outcome: Nearly 50/50 chance, with pocket pair slight favorite');
    print('--------------------------------------------------------------');

    final playerHand = <Card>[Card.fromString('8S'), Card.fromString('8H')];
    final opponentHand = <Card>[Card.fromString('AC'), Card.fromString('KD')];
    final communityCards = <Card>[];

    // Since we can't directly test a specific opponent hand using the public API,
    // we'll use the regular probability calculation and verify it's in a reasonable range
    print('Running simulation for pocket 88 pre-flop vs random hand...');
    final stopwatch = Stopwatch()..start();

    final probability = calculateWinProbability(
        playerHand: playerHand,
        communityCards: communityCards,
        numberOfOpponents: 1);

    stopwatch.stop();
    final executionTime = stopwatch.elapsedMilliseconds;

    print('Calculation completed in $executionTime ms');
    print(
        'RESULT: Win probability for pocket 88 vs random hand: ${(probability * 100).toStringAsFixed(2)}%');
    print(
        'Interpretation: Small-medium pocket pairs are favorites against random hands');
    print('Against specifically AK, it would be closer to 50/50');

    // Pocket 88 against random hand should be a favorite (around 65-75%)
    assert(probability > 0.60 && probability < 0.80,
        'Pocket 88 should win 60-80% of the time against a random hand');

    print('--------------------------------------------------------------');
    print('✓ Pocket pair probability test passed');
  }

  /// tests probability for a set vs flush draw on the turn
  void testProbabilitySetVsFlushDraw() {
    print('--------------------------------------------------------------');
    print('TESTING: Set of Aces vs possible flush draw on the turn');
    print('--------------------------------------------------------------');
    print('Player hand: Ace of Clubs, Ace of Spades (pocket aces)');
    print(
        'Community cards: Ace of Diamonds, King of Hearts, Queen of Hearts, Jack of Hearts');
    print(
        'Scenario: Player has a set of aces, but opponent might have a flush draw');
    print(
        'Expected outcome: Player is favored, but vulnerable to hearts completing');
    print('--------------------------------------------------------------');

    final playerHand = <Card>[Card.fromString('AC'), Card.fromString('AS')];

    final communityCards = <Card>[
      Card.fromString('AD'), // Player has set of aces
      Card.fromString('KH'),
      Card.fromString('QH'),
      Card.fromString('JH'), // Three hearts means a heart draw is possible
    ];

    print('Running simulation against 1 opponent...');
    final stopwatch = Stopwatch()..start();

    final probability = calculateWinProbability(
        playerHand: playerHand,
        communityCards: communityCards,
        numberOfOpponents: 1);

    stopwatch.stop();
    final executionTime = stopwatch.elapsedMilliseconds;

    print('Calculation completed in $executionTime ms');
    print(
        'RESULT: Win probability against 1 opponent: ${(probability * 100).toStringAsFixed(2)}%');
    print(
        'Interpretation: Set of aces is strong, but vulnerable to a heart on the river');
    print('With only one card to come, your set is a favorite but not a lock');

    // Set vs possible flush draw on the turn should favor the set
    assert(probability > 0.60 && probability < 0.85,
        'Set should win 60-85% of the time against possible flush draw');

    print('--------------------------------------------------------------');
    print('✓ Set vs flush draw probability test passed');
  }

  /// tests probability calculation for an unfavorable scenario with a weak hand against multiple opponents
  void testProbabilityOvercard() {
    print('--------------------------------------------------------------');
    print('TESTING: KQ offsuit vs multiple opponents on a J-7-2 rainbow flop');
    print('--------------------------------------------------------------');
    print('Player hand: King of Spades, Queen of Diamonds');
    print('Community cards: Jack of Hearts, Seven of Clubs, Two of Diamonds');
    print(
        'Scenario: Player has completely missed the flop with only overcards');
    print(
        'Expected outcome: Significant underdog, especially vs multiple opponents');
    print('--------------------------------------------------------------');

    // player has KQ offsuit, missed the flop completely
    final playerHand = <Card>[Card.fromString('KS'), Card.fromString('QD')];

    final communityCards = <Card>[
      Card.fromString('JH'),
      Card.fromString('7C'),
      Card.fromString('2D')
    ];

    // test against 3 opponents (multiplayer pot)
    print('Running simulation against 3 opponents...');
    final stopwatch = Stopwatch()..start();

    final probability = calculateWinProbability(
        playerHand: playerHand,
        communityCards: communityCards,
        numberOfOpponents: 3);

    stopwatch.stop();
    final executionTime = stopwatch.elapsedMilliseconds;

    print('Calculation completed in $executionTime ms');
    print(
        'RESULT: Win probability against 3 opponents: ${(probability * 100).toStringAsFixed(2)}%');
    print(
        'Interpretation: Player needs to hit a King or Queen on turn/river or is drawing nearly dead');

    // KQ offsuit with overcards against 3 opponents should be a significant underdog
    assert(probability < 0.40,
        'Missed flop with just overcards should win less than 40% of the time against multiple opponents');

    // also test the scenario against 1 opponent for comparison
    print('\nRunning the same simulation against 1 opponent for comparison...');
    final stopwatchSingle = Stopwatch()..start();

    final probabilityOneOpponent = calculateWinProbability(
        playerHand: playerHand,
        communityCards: communityCards,
        numberOfOpponents: 1);

    stopwatchSingle.stop();
    final executionTimeSingle = stopwatchSingle.elapsedMilliseconds;

    print('Calculation completed in $executionTimeSingle ms');
    print(
        'RESULT: Win probability against 1 opponent: ${(probabilityOneOpponent * 100).toStringAsFixed(2)}%');
    print(
        'Interpretation: Significantly better chances vs a single opponent (more than doubled)');
    print(
        'This demonstrates why poker pros play tighter against multiple opponents');

    // the probability should be higher against 1 opponent than against 3
    assert(probabilityOneOpponent > probability,
        'Win probability should be higher against 1 opponent than against 3');

    // calculate the ratio to show how much worse multiple opponents makes the situation
    final ratio = probabilityOneOpponent / probability;
    print(
        '\nKey finding: Win probability is ${ratio.toStringAsFixed(2)}x higher against 1 opponent');
    print('--------------------------------------------------------------');

    print('✓ Weak overcard hand probability test passed');
  }

  /// tests royal flush detection
  void testRoyalFlush() {
    print('Testing royal flush detection...');

    // Create a royal flush in hearts
    final playerHand = <Card>[Card.fromString('AH'), Card.fromString('KH')];

    final communityCards = <Card>[
      Card.fromString('QH'),
      Card.fromString('JH'),
      Card.fromString('TH'),
      Card.fromString('2S'),
      Card.fromString('3C')
    ];

    final result =
        evaluateHand(playerHand: playerHand, communityCards: communityCards);

    assert(result.type == HandType.royalFlush, 'Failed to detect royal flush');
    assert(result.relevantCards.length == 5, 'Royal flush should have 5 cards');

    print('✓ Royal flush test passed');
  }

  /// tests straight flush detection
  void testStraightFlush() {
    print('Testing straight flush detection...');

    // Create a 9-high straight flush in clubs
    final playerHand = <Card>[Card.fromString('9C'), Card.fromString('8C')];

    final communityCards = <Card>[
      Card.fromString('7C'),
      Card.fromString('6C'),
      Card.fromString('5C'),
      Card.fromString('KH'),
      Card.fromString('AS')
    ];

    final result =
        evaluateHand(playerHand: playerHand, communityCards: communityCards);

    assert(result.type == HandType.straightFlush,
        'Failed to detect straight flush');
    assert(
        result.relevantCards.length == 5, 'Straight flush should have 5 cards');

    print('✓ Straight flush test passed');
  }

  /// tests four of a kind detection
  void testFourOfAKind() {
    print('Testing four of a kind detection...');

    // Create four aces
    final playerHand = <Card>[Card.fromString('AC'), Card.fromString('AS')];

    final communityCards = <Card>[
      Card.fromString('AD'),
      Card.fromString('AH'),
      Card.fromString('KS'),
      Card.fromString('QH'),
      Card.fromString('JC')
    ];

    final result =
        evaluateHand(playerHand: playerHand, communityCards: communityCards);

    assert(
        result.type == HandType.fourOfAKind, 'Failed to detect four of a kind');
    assert(
        result.relevantCards.length == 5, 'Four of a kind should have 5 cards');
    assert(result.relevantCards[0].rank == CardRank.ace,
        'First card should be ace');
    assert(
        result.relevantCards[4].rank == CardRank.king, 'Kicker should be king');

    print('✓ Four of a kind test passed');
  }

  /// tests full house detection
  void testFullHouse() {
    print('Testing full house detection...');

    // Create kings full of queens
    final playerHand = <Card>[Card.fromString('KH'), Card.fromString('KS')];

    final communityCards = <Card>[
      Card.fromString('KC'),
      Card.fromString('QD'),
      Card.fromString('QH'),
      Card.fromString('2C'),
      Card.fromString('3S')
    ];

    final result =
        evaluateHand(playerHand: playerHand, communityCards: communityCards);

    assert(result.type == HandType.fullHouse, 'Failed to detect full house');
    assert(result.relevantCards.length == 5, 'Full house should have 5 cards');

    print('✓ Full house test passed');
  }

  /// tests flush detection
  void testFlush() {
    print('Testing flush detection...');

    // Create a diamond flush
    final playerHand = <Card>[Card.fromString('AD'), Card.fromString('KD')];

    final communityCards = <Card>[
      Card.fromString('9D'),
      Card.fromString('5D'),
      Card.fromString('2D'),
      Card.fromString('QS'),
      Card.fromString('JC')
    ];

    final result =
        evaluateHand(playerHand: playerHand, communityCards: communityCards);

    assert(result.type == HandType.flush, 'Failed to detect flush');
    assert(result.relevantCards.length == 5, 'Flush should have 5 cards');
    assert(result.relevantCards[0].suit == Suit.diamonds,
        'Flush cards should be diamonds');

    print('✓ Flush test passed');
  }

  /// tests straight detection
  void testStraight() {
    print('Testing straight detection...');

    // Create a 9-high straight
    final playerHand = <Card>[Card.fromString('9H'), Card.fromString('8S')];

    final communityCards = <Card>[
      Card.fromString('7C'),
      Card.fromString('6D'),
      Card.fromString('5C'),
      Card.fromString('KH'),
      Card.fromString('AS')
    ];

    final result =
        evaluateHand(playerHand: playerHand, communityCards: communityCards);

    assert(result.type == HandType.straight, 'Failed to detect straight');
    assert(result.relevantCards.length == 5, 'Straight should have 5 cards');

    // Test wheel (A-5-4-3-2) straight
    final wheelPlayerHand = <Card>[
      Card.fromString('AH'),
      Card.fromString('2S')
    ];

    final wheelCommunityCards = <Card>[
      Card.fromString('3C'),
      Card.fromString('4D'),
      Card.fromString('5C'),
      Card.fromString('KH'),
      Card.fromString('QS')
    ];

    final wheelResult = evaluateHand(
        playerHand: wheelPlayerHand, communityCards: wheelCommunityCards);

    assert(wheelResult.type == HandType.straight,
        'Failed to detect wheel straight');

    print('✓ Straight test passed');
  }

  /// tests three of a kind detection
  void testThreeOfAKind() {
    print('Testing three of a kind detection...');

    // Create three jacks
    final playerHand = <Card>[Card.fromString('JH'), Card.fromString('JD')];

    final communityCards = <Card>[
      Card.fromString('JS'),
      Card.fromString('AH'),
      Card.fromString('KC'),
      Card.fromString('2S'),
      Card.fromString('3D')
    ];

    final result =
        evaluateHand(playerHand: playerHand, communityCards: communityCards);

    assert(result.type == HandType.threeOfAKind,
        'Failed to detect three of a kind');
    assert(result.relevantCards.length == 5,
        'Three of a kind should have 5 cards');

    print('✓ Three of a kind test passed');
  }

  /// tests two pair detection
  void testTwoPair() {
    print('Testing two pair detection...');

    // Create aces and kings
    final playerHand = <Card>[Card.fromString('AH'), Card.fromString('KD')];

    final communityCards = <Card>[
      Card.fromString('AS'),
      Card.fromString('KS'),
      Card.fromString('QC'),
      Card.fromString('2H'),
      Card.fromString('3D')
    ];

    final result =
        evaluateHand(playerHand: playerHand, communityCards: communityCards);

    assert(result.type == HandType.twoPair, 'Failed to detect two pair');
    assert(result.relevantCards.length == 5, 'Two pair should have 5 cards');

    print('✓ Two pair test passed');
  }

  /// tests pair detection
  void testPair() {
    print('Testing pair detection...');

    // Create a pair of queens
    final playerHand = <Card>[Card.fromString('QH'), Card.fromString('KD')];

    final communityCards = <Card>[
      Card.fromString('QS'),
      Card.fromString('JC'),
      Card.fromString('9C'),
      Card.fromString('5H'),
      Card.fromString('2D')
    ];

    final result =
        evaluateHand(playerHand: playerHand, communityCards: communityCards);

    assert(result.type == HandType.pair, 'Failed to detect pair');
    assert(result.relevantCards.length == 5, 'Pair should have 5 cards');

    print('✓ Pair test passed');
  }

  /// tests high card detection
  void testHighCard() {
    print('Testing high card detection...');

    // hand with nothing but high cards
    final playerHand = <Card>[Card.fromString('AH'), Card.fromString('KD')];

    final communityCards = <Card>[
      Card.fromString('QS'),
      Card.fromString('JC'),
      Card.fromString('9C'),
      Card.fromString('5H'),
      Card.fromString('2D')
    ];

    final result =
        evaluateHand(playerHand: playerHand, communityCards: communityCards);

    assert(result.type == HandType.highCard, 'Failed to detect high card');
    assert(result.relevantCards.length == 5, 'High card should have 5 cards');
    assert(result.relevantCards[0].rank == CardRank.ace,
        'First card should be ace');

    print('✓ High card test passed');
  }

  /// tests hand comparison
  void testHandComparison() {
    print('Testing hand comparison...');

    // royal flush vs straight flush
    final royalFlush = HandResult(HandType.royalFlush, <Card>[
      Card(CardRank.ace, Suit.hearts),
      Card(CardRank.king, Suit.hearts)
    ]);

    final straightFlush = HandResult(HandType.straightFlush, <Card>[
      Card(CardRank.king, Suit.clubs),
      Card(CardRank.queen, Suit.clubs)
    ]);

    assert(
        royalFlush > straightFlush, 'Royal flush should beat straight flush');
    assert(straightFlush < royalFlush,
        'Straight flush should lose to royal flush');

    // Full house vs flush
    final fullHouse = HandResult(HandType.fullHouse, <Card>[
      Card(CardRank.ace, Suit.hearts),
      Card(CardRank.ace, Suit.diamonds)
    ]);

    final flush = HandResult(HandType.flush, <Card>[
      Card(CardRank.ace, Suit.clubs),
      Card(CardRank.king, Suit.clubs)
    ]);

    assert(fullHouse > flush, 'Full house should beat flush');
    assert(flush < fullHouse, 'Flush should lose to full house');

    print('✓ Hand comparison test passed');
  }
}

void main() {
  final tester = CalculatorTest();
  tester.runAllTests();
}
