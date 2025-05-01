import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore _firestore = FirebaseFirestore.instance;

class DatabaseService {

  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  Future getUserData() 
  async {
    //gets the reference to the user document to convert it to a userData
    final ref = _firestore.collection("users").doc(_auth.currentUser?.email).withConverter(
      fromFirestore: userData.fromFirestore, 
      toFirestore: (userData userdata, _) => userdata.toFirestore());
    final docSnap = await ref.get();
    final userdata = docSnap.data() as userData;
    
    print(userdata);
    return userdata;
    }
}

//a class that represents the user's info
class userData {
  final String? email;
  final int? money;
  final int? games_won;
  final int? games_lost;

  userData({
    this.email,
    this.money,
    this.games_won,
    this.games_lost
  });

  factory userData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return userData(
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