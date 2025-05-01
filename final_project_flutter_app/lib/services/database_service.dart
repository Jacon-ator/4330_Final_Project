import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future getData({required String key}) 
  async {
    return _firestore.collection("users").doc(_auth.currentUser?.email);
  }
}

//a class that represents the user's info
class userObject {
  final String? email;
  final int? money;
  final int? games_won;
  final int? games_lost;

  userObject({
    this.email,
    this.money,
    this.games_won,
    this.games_lost
  });

  factory userObject.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return userObject(
      email: data?['Email'],
      money: data?['Money'],
      games_won: data?['Games Won'],
      games_lost: data?['Games Lost'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) "Email": email,
      if (money != null) "Money": money,
      if (games_won != null) "Games Won": games_won,
      if (games_lost != null) "Games Lost": games_lost,
    };
  }
}