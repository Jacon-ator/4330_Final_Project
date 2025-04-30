import 'package:final_project_flutter_app/models/card.dart';

class Player {
  final String name;
  int balance;
  int bet = 0;
  List<PlayingCard> hand = [];
  bool isAI = false; // Flag to indicate if the player is an AI
  bool isCurrentTurn = false; // Flag to indicate if it's the player's turn
  bool isFolded = false; // Flag to indicate if the player has folded

  Player(String name, int balance, {this.isAI = false})
      : name = name.isEmpty ? "Player" : name,
        balance = balance < 0 ? 0 : balance; // Default to false if not provided

  void resetHand() {
    hand.clear();
    bet = 0;
    isCurrentTurn = false;
    isFolded = false;
  }

  void placeBet(int amount) {
    if (amount > balance) {
      throw Exception("Insufficient balance to place bet.");
    }
    bet += amount;
    balance -= amount;
    isCurrentTurn = false; // End the player's turn after placing a bet
  }

  void receiveCard(PlayingCard card) {
    hand.add(card);
  }

  void fold() {
    hand.clear(); // Clear the hand when the player folds
    isFolded = true; // Set the folded flag to true
    // isCurrentTurn = false; // End the player's turn
  }

  void call(int amount) {
    if (amount > balance) {
      throw Exception("Insufficient balance to call.");
    }
    placeBet(amount);
  }

  @override
  String toString() {
    return 'Player{name: $name, balance: $balance, bet: $bet, hand: $hand}';
  }

  Future<void> makeAIDecision() async {
    // Placeholder for AI decision-making logic
    // This could be expanded with actual AI strategies
    await Future.delayed(Duration(milliseconds: 200));
    placeBet(10);
  }
}
