/// A test class for verifying that hand evaluation and probability calculation works correctly

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

    print('\nStarting probability calculation tests...\n');

    testProbabilityCalculationPerformance();

    print('\nAll tests completed!');
  }

  /// tests the performance and feasibility of the probability calculation
  void testProbabilityCalculationPerformance() {
    print('Testing probability calculation performance...');

    // Standard scenario: Pocket pair of aces pre-flop vs 1 opponent
    final playerHand = <Card>[Card.fromString('AS'), Card.fromString('AC')];

    final communityCards = <Card>[];

    print(
        'Calculating win probability for pocket aces pre-flop vs 1 opponent...');

    // Measure execution time
    final stopwatch = Stopwatch()..start();

    final probability = calculateWinProbability(
        playerHand: playerHand,
        communityCards: communityCards,
        numberOfOpponents: 1);

    stopwatch.stop();
    final executionTime = stopwatch.elapsedMilliseconds;

    print('Calculation completed in $executionTime ms');
    print('Win probability: ${(probability * 100).toStringAsFixed(2)}%');

    // Pocket aces should have ~85% win rate vs random hand
    assert(probability > 0.75 && probability < 0.95,
        'Pocket aces should win 75-95% of the time against one opponent');

    print('✓ Probability calculation performance test passed');
  }

  // [All existing test methods remain unchanged]

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
