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
  void initializePlayer(String playerName, bool isAI) {
    // Initialize players with given names and default balances
    players
        .add(Player(playerName, 1000, isAI: isAI)); // Default balance of 1000
  }

  void resetGame() {
    print("Resetting game state...");
    // Initialize the game state with default values
    initializePlayers();
    communityCards = [];
    deck.resetDeck(); // Start with no community cards
    deck.cards = deck.generateDeck(); // Generate the deck of cards
    deck.shuffleDeck(); // Shuffle the deck
    currentPlayerIndex = 0;
    pot = 0;
    isGameOver = false;
  }

  void initializePlayers() {
    for (int i = 0; i < 4; i++) {
      bool isAI = false; // Default to false for human players
      // Initialize players with default names and reset their states. this is just for testing and will be changed later
      if (i == 0) {
        isAI = false; // First player is a human player
      } else {
        isAI = true; // Other players are AI players
      }
      initializePlayer(
          "player ${i + 1}", isAI); // Initialize players with default names
    }
  }

  void rotateBlinds() {
    players.add(players.removeAt(0)); // Move the first player to the end
  }
}
