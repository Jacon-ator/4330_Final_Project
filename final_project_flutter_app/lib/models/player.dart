import 'dart:math';

import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/card_evaluator.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/calculator.dart';

class Player {
  final String id;
  final String name;
  int balance;
  int? bet = 0;
  List<PlayingCard>? hand = [];
  bool? isAI = false; // Flag to indicate if the player is an AI
  bool? isCurrentTurn = false; // Flag to indicate if it's the player's turn
  bool? isFolded = false; // Flag to indicate if the player has folded
  HandRank? handRank = HandRank.none; // Default hand rank
  bool? isAllIn = false; // Flag to indicate if the player is all-in
  late bool? hasPlayedThisRound;

  Player({
    required this.id,
    required this.name,
    required this.balance,
    this.bet,
    this.hand,
    this.isAI,
    this.isCurrentTurn,
    this.hasPlayedThisRound,
    this.isFolded,
    this.handRank,
    this.isAllIn,
  }) {
    hand ??= []; // Initialize hand if it's null
    isAI ??= false; // Default to false if not provided
    isCurrentTurn ??= false; // Default to false if not provided
    isFolded ??= false; // Default to false if not provided
    isAllIn ??= false; // Default to false if not provided
    hasPlayedThisRound ??= false; // Default to false if not provided
  }

  void resetHand() {
    if (hand != null) {
      hand!.clear();
    }
    bet = 0;
    isCurrentTurn = false;
    isFolded = false;
    isAllIn = false; // Reset all-in status
  }

  int placeBet(int amount) {
    if (amount > balance) {
      isAllIn = true; // Set all-in flag if going all-in
      amount = balance; // Go all-in
    }
    bet = (bet ?? 0) + amount;
    balance -= amount;
    isCurrentTurn = false; // End the player's turn after placing a bet
    return bet!;
  }

  void receiveCard(PlayingCard card) {
    if (hand != null) {
      hand!.add(card);
    }
  }

  void fold() {
    if (hand != null) {
      hand!.clear(); // Clear the hand when the player folds
    }
    isFolded = true; // Set the folded flag to true
    // isCurrentTurn = false; // End the player's turn
  }

  int call(PokerParty gameRef) {
    int amount = getCallAmount(gameRef);
    if (amount < 0) {
      return 0;
    }
    if (amount > balance) {
      amount = balance; //go all-in
      isAllIn = true; // Set all-in flag if going all-in
    }
    placeBet(amount);

    return amount;
  }

  @override
  String toString() {
    return 'Player{name: $name, balance: $balance, bet: $bet, hand: $hand}';
  }

  Future<int> makeAIDecision(PokerParty gameRef) async {
    // Placeholder for AI decision-making logic
    // This could be expanded with actual AI strategies
    Random random = Random();
    int decision = random
        .nextInt(3); // Randomly choose between 0 (fold), 1 (call), or 2 (raise)
    hasPlayedThisRound = true; // Mark that the player has played this round
    switch (decision) {
      case 0:
        fold();
        print("$name folds.");
        return 0; // Fold
      case 1:
        print("$name calls.");
        return call(gameRef); // Call
      case 2:
        int raiseAmount = random.nextInt(balance ~/ 2);
        if (raiseAmount > balance) {
          raiseAmount =
              balance; // Go all-in if the raise amount exceeds balance
          isAllIn = true; // Set all-in flag if going all-in
        }
        print("$name raises by $raiseAmount.");
        print("$name raises $raiseAmount.");
        placeBet(raiseAmount);

        return raiseAmount; // Raise
      default:
        return 0; // Default to fold if something goes wrong
    }
  }

  int getCallAmount(PokerParty gameRef) {
    // Calculate the amount needed to call based on the current game state
    int maxBet = 0;
    for (Player player in gameRef.gameState.players) {
      if (!player.isFolded! && player.bet! > maxBet) {
        maxBet = player.bet!;
      }
    }
    return maxBet -
        bet!; // Return the difference between the max bet and the player's current bet
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: json['balance'] as int,
      bet: json['bet'] as int?,
      hand: (json['hand'] as List<dynamic>?)
          ?.map((card) => PlayingCard.fromJson(card))
          .toList(),
      isAI: json['isAI'] as bool?,
      isCurrentTurn: json['isCurrentTurn'] as bool?,
      hasPlayedThisRound: json['hasPlayedThisRound'] as bool?,
      isFolded: json['isFolded'] as bool?,
      handRank: HandRank.fromString(json['handRank'] as String?),
      isAllIn: json['isAllIn'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'bet': bet,
      'hand': hand?.map((card) => card.toJson()).toList(),
      'isAI': isAI,
      'isCurrentTurn': isCurrentTurn,
      'hasPlayedThisRound': hasPlayedThisRound,
      'isFolded': isFolded,
      'handRank': handRank?.toString() ?? 'none',
      'isAllIn': isAllIn,
    };
  }

  List<Card> convertHandToEvaluate(List<PlayingCard> hand) {
    Map<String, Suit> suitMap = {
      'Hearts': Suit.hearts,
      'Diamonds': Suit.diamonds,
      'Spades': Suit.spades,
      'Clubs': Suit.clubs,
    };

    Map<int, CardRank> rankMap = {
      2: CardRank.two,
      3: CardRank.three,
      4: CardRank.four,
      5: CardRank.five,
      6: CardRank.six,
      7: CardRank.seven,
      8: CardRank.eight,
      9: CardRank.nine,
      10: CardRank.ten,
      11: CardRank.jack,
      12: CardRank.queen,
      13: CardRank.king,
      14: CardRank.ace,
    };
    List<Card> cards = hand.map((card) {
      return Card(
        rankMap[card.rank] ?? CardRank.ace,
        suitMap[card.suit] ?? Suit.hearts,
      );
    }).toList();
    return cards;
  }
}
