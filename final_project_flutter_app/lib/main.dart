import 'package:final_project_flutter_app/components/buttons/auth/profile_button.dart';
import 'package:final_project_flutter_app/components/buttons/menu/chat_button.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

// Create an instance at the top level

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  // Firebase initialization
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBEI1LMAwr18HR06SRkwF4Bnlqp6q2BnO4",
          appId: "1:136301614529:android:e8a3444fd77d64df570b40",
          messagingSenderId: "136301614529",
          projectId: "poker-party-80b1a"));

  // Check if user is already logged in
  User? currentUser = FirebaseAuth.instance.currentUser;

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // If user is logged in, start with game screen (main menu)
      // Otherwise, show signup page
      home: currentUser != null
          ? buildGameScreen(currentUser.displayName ?? "Player")
          : LoginPage(name: "Player"),
      routes: {
        '/game': (context) => buildGameScreen("Player"),
      },
    ),
  );
}

// Extract game screen building into a separate function for reuse
Widget buildGameScreen(String playerName) {
  return Scaffold(
    backgroundColor: Color(0xFF468232),
    body: Stack(
      children: [
        Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 1265,
              height: 685,
              child: GameWidget(game: PokerParty()),
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 20,
          child: ProfileButton(name: playerName),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: ChatButton(name: playerName),
        ),
        // Positioned(
        //   top: 20,
        //   right: 20,
        //   child: const VolumeControl(),
        // ),
      ],
    ),
  );
}
