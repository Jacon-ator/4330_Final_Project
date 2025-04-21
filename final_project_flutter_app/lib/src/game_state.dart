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

  void resetGame() {
    // Initialize the game state with default values
    players = [
      Player("Player 1", 1000),
      Player("Player 2", 1000),
      Player("Player 3", 1000),
      Player("Player 4", 1000),
    ];
    communityCards = []; // Start with no community cards
    deck.cards = deck.generateDeck(); // Generate the deck of cards
    deck.shuffleDeck(); // Shuffle the deck
    currentPlayerIndex = 0;
    pot = 0;
    isGameOver = false;
  }
}
