import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/game_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LobbyScreenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a stream to listen for player count changes
  Stream<int> streamPlayerCount() {
    return _firestore
        .collection("games")
        .doc("primary_game")
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        try {
          final gameState = GameState.fromJson(snapshot.data()!);
          return gameState.players.length;
        } catch (e) {
          print("Error parsing game state: $e");
          return 0;
        }
      } else {
        return 0;
      }
    });
  }

  // Stream the actual players list for more detailed information
  Stream<List<Player>> streamPlayers() {
    return _firestore
        .collection("games")
        .doc("primary_game")
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        try {
          final gameState = GameState.fromJson(snapshot.data()!);
          return gameState.players;
        } catch (e) {
          print("Error parsing players: $e");
          return [];
        }
      } else {
        return [];
      }
    });
  }

  Future<bool> addToLobby(PokerParty pokerGameRef) async {
    try {
      final user = _auth.currentUser;

      final ref =
          await _firestore.collection("playerData").doc(user?.uid).get();

      Player? player;
      if (!ref.exists) {
        player = Player(
          id: user?.uid ?? "0",
          name: user?.email ?? "Guest",
          balance: 1000,
          isAI: false,
          isCurrentTurn: false,
          isFolded: false,
          handRank: null,
          isAllIn: false,
        );
        await _firestore
            .collection("playerData")
            .doc(user?.uid)
            .set(player.toJson());
      } else {
        player = Player.fromJson(ref.data()!);
      }

      final gameRef =
          await _firestore.collection("games").doc("primary_game").get();

      if (!gameRef.exists) {
        GameState gameState = GameState();
        gameState.addPlayer(player);
        await _firestore
            .collection("games")
            .doc("primary_game")
            .set(gameState.toJson());
        // pokerGameRef.gameState.copy(gameState);
        return true;
      } else {
        GameState currentGameState = GameState.fromJson(gameRef.data()!);

        if (currentGameState.players.length >=
            currentGameState.table.totalCapacity) {
          print("Cannot add more players. Table is full.");
          return false;
        }
        if (currentGameState.players.any((p) => p.id == player?.id)) {
          print("Player already exists in the game.");
          return true;
        }

        if (currentGameState.isLobbyActive) {
          print("The game is currently playing. Please wait.");
          return false;
        }

        currentGameState.addPlayer(player);
        await _firestore
            .collection("games")
            .doc("primary_game")
            .set(currentGameState.toJson());

        // pokerGameRef.gameState.copy(currentGameState);
        return true;
      }
    } catch (e) {
      print("Error adding player to lobby: $e");
      return false;
    }
  }

  Future<int> removeFromLobby(PokerParty pokerGameRef) async {
    try {
      final user = _auth.currentUser;

      final ref =
          await _firestore.collection("playerData").doc(user?.uid).get();

      if (ref.exists) {
        final gameRef =
            await _firestore.collection("games").doc("primary_game").get();

        if (gameRef.exists) {
          GameState currentGameState = GameState.fromJson(gameRef.data()!);
          currentGameState.removePlayer(user?.uid ?? "0");
          await _firestore
              .collection("games")
              .doc("primary_game")
              .set(currentGameState.toJson());
          // pokerGameRef.gameState.copy(currentGameState);
          return currentGameState.players.length;
        }
      }
    } catch (e) {
      print("Error removing player from lobby: $e");
    }
    return -1;
  }

  Future<void> startLobby(PokerParty pokerGameRef) async {
    try {
      final gameRef =
          await _firestore.collection("games").doc("primary_game").get();

      if (gameRef.exists) {
        GameState currentGameState = GameState.fromJson(gameRef.data()!);

        currentGameState.isLobbyActive = true;
        currentGameState.players[0].isCurrentTurn =
            true; // Set the first player as current turn

        await _firestore
            .collection("games")
            .doc("primary_game")
            .set(currentGameState.toJson());

        // pokerGameRef.gameState.copy(currentGameState);
      } else {
        print("Game does not exist.");
      }
    } catch (e) {
      print("Error starting lobby: $e");
    }
  }
}
