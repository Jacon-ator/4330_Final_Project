import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LobbyScreenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<int> addToLobby() async {
    final user = _auth.currentUser;

    final ref = await _firestore.collection("playerData").doc(user?.uid).get();

    if (!ref.exists) {
      Player newPlayer = Player(
        id: user?.uid ?? "0",
        name: user?.displayName ?? "Guest",
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
          .set(newPlayer.toJson());
    }

    // TODO: ADD PLAYER TO GAME

    return 0;
  }
}
