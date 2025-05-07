import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/deck.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/models/table.dart';

class GameState {
  List<Player> players = [];
  int playerIndex = 0;
  int dealerIndex = -1;
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
  int bigBlind = 25;
  int smallBlind = 10;
  bool potIsRight = false;

  bool isGameOver = false;

  GameState({
    List<Player>? players,
    List<PlayingCard>? communityCards,
    this.round = 0,
    this.pot = 0,
    this.bigBlind = 25,
    this.smallBlind = 10,
    this.potIsRight = false,
    this.isGameOver = false,
  }) {
    this.players = players ?? [];
    this.communityCards = communityCards ?? [];
  }

  bool initializePlayer(String playerName, bool isAI, {String id = "0"}) {
    if (players.length >= table.totalCapacity) {
      print("Cannot add more players. Table is full.");
      return false;
    }

    players.add(
      Player(
        id: id,
        name: playerName,
        balance: 1000,
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
      player.isAllIn = false; // Reset all-in status
      player.isFolded = false; // Reset folded status
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

  Player getCurrentPlayer() {
    return players.firstWhere((player) => player.isCurrentTurn!,
        orElse: () => throw Exception("No current player found"));
  }
}
