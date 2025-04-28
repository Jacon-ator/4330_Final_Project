import 'package:final_project_flutter_app/src/components/profile_button.dart';
import 'package:final_project_flutter_app/src/components/login_button.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  Firebase.initializeApp(
    options: FirebaseOptions(apiKey: "AIzaSyBEI1LMAwr18HR06SRkwF4Bnlqp6q2BnO4", appId: "1:136301614529:android:e8a3444fd77d64df570b40", messagingSenderId: "136301614529", projectId: "poker-party-80b1a") 
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
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
              child: ProfileButton(name: "Player"), // Or dynamically set name
            ),
            Positioned(
              top: 40,
              left: 20,
              child: LoginButton(name: "Player"), // Or dynamically set name
            ),
          ],
        ),
      ),
    ),
  );
}
