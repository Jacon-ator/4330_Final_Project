import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  Future<void> signup({
    required String email,
    required String password
  }) async {

    try {

      //tries to create a new account with the given email and password
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, 
        password: password);

    } on FirebaseAuthException catch(e) { //gets the error from firebase and prints it to the console, can be changed to show on app later
      String message = '';
      if (e.code == 'weak-password'){
        message = 'The password is too weak.';
      } else if (e.code == 'email-already-in-use'){
        message = 'This email is already in use.';
      }
      print(message);
    }
  }

  Future<void> login({
    required String email,
    required String password
  }) async {

    try {

      //tries to sign into an account with the given email and password
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password);

    } on FirebaseAuthException catch(e) { //gets the error from firebase and prints it to the console, can be changed to show on app later
      String message = '';
      if (e.code == 'user-not-found'){
        message = 'No user found for this email.';
      } else if (e.code == 'wrong-password'){
        message = 'Wrong password provided for this user.';
      }
      print(message);
    }
  }

  //signs the user out
  Future<void> signout() 
    async {

      await FirebaseAuth.instance.signOut();
    }
}