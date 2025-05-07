import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/models/player.dart';
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

  Future<bool> addToLobby() async {
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

        return true;
      } else {
        GameState gameState = GameState.fromJson(gameRef.data()!);

        if (gameState.players.length >= gameState.table.totalCapacity) {
          print("Cannot add more players. Table is full.");
          return false;
        }
        if (gameState.players.any((p) => p.id == player?.id)) {
          print("Player already exists in the game.");
          return true;
        }

        if (gameState.isLobbyActive) {
          print("The game is currently playing. Please wait.");
          return false;
        }

        gameState.addPlayer(player);
        await _firestore
            .collection("games")
            .doc("primary_game")
            .set(gameState.toJson());
        return true;
      }
    } catch (e) {
      print("Error adding player to lobby: $e");
      return false;
    }
  }

  Future<int> removeFromLobby() async {
    try {
      final user = _auth.currentUser;

      final ref =
          await _firestore.collection("playerData").doc(user?.uid).get();

      if (ref.exists) {
        final gameRef =
            await _firestore.collection("games").doc("primary_game").get();

        if (gameRef.exists) {
          GameState gameState = GameState.fromJson(gameRef.data()!);
          gameState.removePlayer(user?.uid ?? "0");
          await _firestore
              .collection("games")
              .doc("primary_game")
              .set(gameState.toJson());
          return gameState.players.length;
        }
      }
    } catch (e) {
      print("Error removing player from lobby: $e");
    }
    return -1;
  }

  Future<void> startLobby() async {
    try {
      final gameRef =
          await _firestore.collection("games").doc("primary_game").get();

      if (gameRef.exists) {
        GameState gameState = GameState.fromJson(gameRef.data()!);

        gameState.isLobbyActive = true;

        await _firestore
            .collection("games")
            .doc("primary_game")
            .set(gameState.toJson());
      } else {
        print("Game does not exist.");
      }
    } catch (e) {
      print("Error starting lobby: $e");
    }
  }
}
