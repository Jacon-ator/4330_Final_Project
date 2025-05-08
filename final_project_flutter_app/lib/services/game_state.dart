import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Add this to your GameState class
  Future<bool> initializePlayersFromLobby(FirebaseFirestore firestore) async {
    try {
      // Get the primary game document from Firestore
      final gameRef =
          await firestore.collection("games").doc("primary_game").get();

      if (!gameRef.exists) {
        print("No lobby found to initialize players from.");
        return false;
      }

      // Parse the lobby data
      final lobbyData = gameRef.data()!;

      // Check if we have players in the lobby
      if (!lobbyData.containsKey('players') ||
          (lobbyData['players'] as List).isEmpty) {
        print("No players found in the lobby.");
        return false;
      }

      // Clear existing players
      players.clear();

      // Convert and add each player from the lobby
      List<dynamic> lobbyPlayers = lobbyData['players'];
      for (var playerData in lobbyPlayers) {
        Player player = Player.fromJson(playerData);
        players.add(player);

        print(
            "Initialized player: ${player.name} with balance: ${player.balance}");
      }

      // If we need AI players to fill the table
      if (players.length < table.totalCapacity) {
        int aiCount = table.totalCapacity - players.length;
        print("Adding $aiCount AI players to fill the table");

        for (int i = 0; i < aiCount; i++) {
          initializePlayer("AI_Player_${i + 1}", true, id: "ai_${i + 1}");
        }
      }

      // Reset all player states for game start
      for (var player in players) {
        player.resetHand();
        player.isCurrentTurn = false;
        player.hasPlayedThisRound = false;
      }

      // Set the first player's turn if needed
      if (players.isNotEmpty) {
        players[0].isCurrentTurn = true;
      }

      return true;
    } catch (e) {
      print("Error initializing players from lobby: $e");
      return false;
    }
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

  // void initializeAI() {
  //   int i = 0;
  //   while (i != table.totalCapacity - players.length) {
  //     initializePlayer("AI_player_$i+1", isAI);
  //     i++;
  //   }
  // }

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
