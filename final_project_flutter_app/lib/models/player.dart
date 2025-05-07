import 'dart:math';

import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/card_evaluator.dart';
import 'package:final_project_flutter_app/poker_party.dart';

class Player {
  final String name;
  int balance;
  int bet = 0;
  List<PlayingCard> hand = [];
  bool isAI = false; // Flag to indicate if the player is an AI
  bool isCurrentTurn = false; // Flag to indicate if it's the player's turn
  bool isFolded = false; // Flag to indicate if the player has folded
  HandRank? handRank;
  bool isAllIn = false; // Flag to indicate if the player is all-in
  bool hasPlayedThisRound = false;

  Player(String name, int balance, {this.isAI = false})
      : name = name.isEmpty ? "Player" : name,
        balance = balance < 0 ? 0 : balance; // Default to false if not provided

  void resetHand() {
    hand.clear();
    bet = 0;
    isCurrentTurn = false;
    isFolded = false;
  }

  int placeBet(int amount) {
    if (amount > balance) {
      throw Exception("Insufficient balance to place bet.");
    }
    bet += amount;
    balance -= amount;
    isCurrentTurn = false; // End the player's turn after placing a bet
    return bet;
  }

  void receiveCard(PlayingCard card) {
    hand.add(card);
  }

  void fold() {
    hand.clear(); // Clear the hand when the player folds
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
        .nextInt(2); // Randomly choose between 0 (fold), 1 (call), or 2 (raise)
    hasPlayedThisRound = true; // Mark that the player has played this round
    switch (decision) {
      case 0:
        fold();
        print("$name folds.");
        return 0; // Fold
      case 1:
        print("$name calls.");
        return call(gameRef); // Call

      // case 2:
      //   int raiseAmount = 50;
      //   int betAmount = getCallAmount(gameRef) + raiseAmount;
      //   //     random.nextInt(balance ~/ 2) + 1; // Random raise amount
      //   // print("$name raises by $raiseAmount.");
      //   print("$name raises 50.");
      //   placeBet(betAmount);

      //   return betAmount; // Raise
      default:
        return 0; // Default to fold if something goes wrong
    }
  }

  int getCallAmount(PokerParty gameRef) {
    // Calculate the amount needed to call based on the current game state
    int maxBet = 0;
    for (Player player in gameRef.gameState.players) {
      if (!player.isFolded && player.bet > maxBet) {
        maxBet = player.bet;
      }
    }
    return maxBet -
        bet; // Return the difference between the max bet and the player's current bet
  }
}
