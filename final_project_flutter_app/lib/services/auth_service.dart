import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth _auth = FirebaseAuth.instance;

class AuthService {

  

  Future signup({
    required String email,
    required String password
  }) async {

    try {

      //tries to create a new account with the given email and password
      UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password);
      print(user);
      //creates a document in the firestore database that will hold the users info
      FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.email).set(
        {
        "Email" : _auth.currentUser?.email,
        "Chips" : 5000, //Start with 5000 chips
        "Coins" : 150, //Start with 150 Coins
        "Games Won" : 0,
        "Games Lost" : 0,
        "ownTableSkin": false,
        "ownCardSkin": false
        }
      );

      //creates a collection owned by the user that will hold documents for all of their chats with other players
      FirebaseFirestore.instance.collection('users').doc(_auth.currentUser?.email).collection("Chats").doc("Support Chat").set({
        "0": "Support: Welcome! How can we assist you today?"
      });

      return user;

    } on FirebaseAuthException catch(e) { //gets the error from firebase and prints it to the console, can be changed to show on app later
      String message = '';
      if (e.code == 'weak-password'){
        message = 'The password is too weak.';
      } else if (e.code == 'email-already-in-use'){
        message = 'This email is already in use.';
      }
      print(message);
      return null;
    }
  }

  Future login({
    required String email,
    required String password
  }) async {

    try {

      //tries to sign into an account with the given email and password
      UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password);
      return user;
    } on FirebaseAuthException catch(e) { //gets the error from firebase and prints it to the console, can be changed to show on app later
      String message = '';
      if (e.code == 'user-not-found'){
        message = 'No user found for this email.';
      } else if (e.code == 'wrong-password'){
        message = 'Wrong password provided for this user.';
      }
      print(message);
      return null;
    }
  }

  //signs the user out
  Future<void> signout() 
    async {

      await _auth.signOut();
    }
}