import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/deck.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/models/table.dart';
import 'package:final_project_flutter_app/services/calculator.dart';

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
    Deck? deck,
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
    this.deck = deck ?? Deck(name: "Standard Deck", cards: []);
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

  // This method is now deprecated in favor of manual player/bot addition in the lobby
  // It's kept for backward compatibility but not used in the main flow
  void initializePlayers() {
    // Only initialize if players list is empty
    if (players.isEmpty) {
      // Add just the human player by default
      Player player = Player(
        id: "player_1",
        name: "Player_1",
        balance: 1000,
        isAI: false,
      );

      players.add(player);
    }
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
      deck: Deck.fromJson(json['deck']),
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
      isLobbyActive: json['isLobbyActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'players': players.map((player) => player.toJson()).toList(),
      'communityCards': communityCards.map((card) => card.toJson()).toList(),
      'deck': deck.toJson(),
      'round': round,
      'pot': pot,
      'bigBlind': bigBlind,
      'smallBlind': smallBlind,
      'potIsRight': potIsRight,
      'isGameOver': isGameOver,
      'playerIndex': playerIndex,
      'dealerIndex': dealerIndex,
      'isLobbyActive': isLobbyActive,
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

  List<Card> convertHandToEvaluate(List<PlayingCard> communityCards) {
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
    List<Card> cards = communityCards.map((card) {
      return Card(
        rankMap[card.rank] ?? CardRank.ace,
        suitMap[card.suit] ?? Suit.hearts,
      );
    }).toList();
    return cards;
  }

  void reset() {
    players.clear();
    playerIndex = 0;
    dealerIndex = -1;
    communityCards.clear();
    deck.resetDeck();
    table = Table(
      id: "table1",
      name: "Main Table",
      totalCapacity: 4,
      isAvailable: true,
    );
    round = 0;
    pot = 0;
    bigBlind = 25;
    smallBlind = 10;
    potIsRight = false;
    isLobbyActive = false;
    isGameOver = false;
  }
}
