import 'package:final_project_flutter_app/components/buttons/auth/profile_button.dart';
import 'package:final_project_flutter_app/components/volume_control.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/screens/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();

  // firebase intinalizatiogn
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyBEI1LMAwr18HR06SRkwF4Bnlqp6q2BnO4",
          appId: "1:136301614529:android:e8a3444fd77d64df570b40",
          messagingSenderId: "136301614529",
          projectId: "poker-party-80b1a"));

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpPage(name: "Player"), // Start with the signup page
      routes: {
        '/game': (context) => Scaffold(
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
                    child: ProfileButton(
                        name: "Player"), // Or dynamically set name
                  ),
                  // Volume control in top right corner
                  Positioned(
                    top: 20,
                    right: 20,
                    child: const VolumeControl(),
                  ),
                ],
              ),
            ),
      },
    ),
  );
}
