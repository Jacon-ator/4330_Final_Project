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
  bool isLobbyActive = false;
  bool isGameOver = false;

  GameState({
    List<Player>? players,
    List<PlayingCard>? communityCards,
    this.round = 0,
    this.pot = 0,
    this.bigBlind = 25,
    this.smallBlind = 10,
    this.potIsRight = false,
    this.isLobbyActive = false,
    this.isGameOver = false,
    this.playerIndex = 0,
    this.dealerIndex = -1,
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

  void initializeAI() {
    for (int i = 0; i < 4; i++) {
      bool isAI = i == 0 ? false : true; // First player is human, others are
      initializePlayer("player_$i", isAI);
    }
    players[0].isCurrentTurn = true; // Set the first player as current turn
  }

  Player getCurrentPlayer() {
    return players.firstWhere((player) => player.isCurrentTurn!,
        orElse: () => throw Exception("No current player found"));
  }

  // FIREBASE FUNCTIONS

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      players: (json['players'] as List<dynamic>)
          .map((playerJson) => Player.fromJson(playerJson))
          .toList(),
      communityCards: (json['communityCards'] as List<dynamic>)
          .map((cardJson) => PlayingCard.fromJson(cardJson))
          .toList(),
      round: json['round'] ?? 0,
      pot: json['pot'] ?? 0,
      bigBlind: json['bigBlind'] ?? 25,
      smallBlind: json['smallBlind'] ?? 10,
      potIsRight: json['potIsRight'] ?? false,
      isGameOver: json['isGameOver'] ?? false,
      playerIndex: json['playerIndex'] ?? 0,
      dealerIndex: json['dealerIndex'] ?? -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'players': players.map((player) => player.toJson()).toList(),
      'communityCards': communityCards.map((card) => card.toJson()).toList(),
      'round': round,
      'pot': pot,
      'bigBlind': bigBlind,
      'smallBlind': smallBlind,
      'potIsRight': potIsRight,
      'isGameOver': isGameOver,
      'playerIndex': playerIndex,
      'dealerIndex': dealerIndex,
    };
  }

  bool addPlayer(Player player) {
    if (players.length >= table.totalCapacity) {
      print("Cannot add more players. Table is full.");
      return false;
    }

    players.add(player);
    return true;
  }

  void removePlayer(String s) {
    players.removeWhere((player) => player.id == s);
  }

  void copy(GameState gameState) {
    players = gameState.players;
    playerIndex = gameState.playerIndex;
    dealerIndex = gameState.dealerIndex;
    communityCards = gameState.communityCards;
    deck = gameState.deck;
    table = gameState.table;
    round = gameState.round;
    pot = gameState.pot;
    bigBlind = gameState.bigBlind;
    smallBlind = gameState.smallBlind;
    potIsRight = gameState.potIsRight;
    isLobbyActive = gameState.isLobbyActive;
    isGameOver = gameState.isGameOver;
  }
}
