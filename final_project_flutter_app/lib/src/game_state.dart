import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/deck.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/models/table.dart';

class GameState {
  List<Player> players = [];
  List<PlayingCard> communityCards = [];
  Deck deck =
      Deck(name: "Standard Deck", cards: []); // Initialize with an empty deck
  Table table = Table(
      id: "table1",
      name: "Main Table",
      capacity: 4,
      isAvailable: true); // Initialize the table
  int currentPlayerIndex = 0;
  int pot = 0;
  bool isGameOver = false;
  int round =
      0; // Track the current round (pre-flop: 0, flop: 1, turn: 2, river: 3)
  int bigBlind = 10; // Big blind amount
  int smallBlind = 25; // Small blind amount

  GameState();
  void initializePlayers(List<String> playerNames) {
    // Initialize players with given names and default balances
    players = playerNames
        .map((name) =>
            Player(name, 1000)) // Default balance of 1000 for each player
        .toList();
  }

  void resetGame() {
    // Initialize the game state with default values
    initializePlayers([
      "Player 1",
      "Player 2",
      "Player 3",
      "Player 4"
    ]); // Example player names
    communityCards = [];
    deck.resetDeck(); // Start with no community cards
    deck.cards = deck.generateDeck(); // Generate the deck of cards
    deck.shuffleDeck(); // Shuffle the deck
    currentPlayerIndex = 0;
    pot = 0;
    isGameOver = false;
  }
}
