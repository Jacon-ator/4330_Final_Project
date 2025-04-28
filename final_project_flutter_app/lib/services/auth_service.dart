import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signup({
    required String email,
    required String password
  }) async {

    try {

      //tries to create a new account with the given email and password
      UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password);
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