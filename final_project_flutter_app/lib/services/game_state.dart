import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/deck.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/models/table.dart';

class GameState {
  List<Player> players = [];

  // not used
  // int currentPlayerIndex = 0;

  List<PlayingCard> communityCards = [];
  Deck deck = Deck(name: "Standard Deck", cards: []);

  Table table = Table(
    id: "table1",
    name: "Main Table",
    totalCapacity: 4,
    isAvailable: true,
  );

  // (pre-flop: 0, flop: 1, turn: 2, river: 3)
  int round = 0;

  int pot = 0;
  int bigBlind = 10;
  int smallBlind = 25;

  bool isGameOver = false;

  GameState();
  bool initializePlayer(String playerName, bool isAI) {
    if (players.length >= table.totalCapacity) {
      print("Cannot add more players. Table is full.");
      return false;
    }

    players.add(
      Player(
        playerName,
        1000,
        isAI: isAI,
      ),
    ); // Default balance of 1000

    return true;
  }

  void resetGame() {
    print("Resetting game state...");
    // Initialize the game state with default values
    for (Player player in players) {
      player.resetHand(); // Reset each player's hand and bet
    }
    communityCards = [];
    deck.resetDeck(); // Start with no community cards
    deck.shuffleDeck(); // Shuffle the deck
    // not used
    // currentPlayerIndex = 0;
    pot = 0;
    round = 0;
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
