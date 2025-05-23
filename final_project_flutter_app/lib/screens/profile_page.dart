import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/screens/login_page.dart';
import 'package:final_project_flutter_app/screens/shop_screen.dart';
import 'package:final_project_flutter_app/screens/signup_page.dart';
import 'package:final_project_flutter_app/services/auth_service.dart';
import 'package:final_project_flutter_app/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PokerProfilePage extends StatefulWidget {
  final String name;

  const PokerProfilePage({super.key, required this.name});

  @override
  State<PokerProfilePage> createState() => _PokerProfilePageState();
}

class _PokerProfilePageState extends State<PokerProfilePage> {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();
  final SFXManager _sfxManager = SFXManager();

  userData? currentUserData;
  String? email = '';
  int wins = 0;
  int losses = 0;
  int chipsWon = 0;
  int chipsLost = 0;
  int currentChips = 0;
  Map<String, dynamic> data = {};

  // These methods could be called from real game logic later:
  void recordWin(int amountWon) {
    setState(() {
      wins++;
      currentChips += amountWon;
      chipsWon += amountWon;
    });

    // Update Firestore
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(email)
          .update({"Games Won": wins, "Chips": currentChips});
    }
  }

  void recordLoss(int amountLost) {
    setState(() {
      losses++;
      if (currentChips >= amountLost) {
        currentChips -= amountLost;
        chipsLost += amountLost;
      } else {
        chipsLost += currentChips;
        currentChips = 0;
      }
    });

    // Update Firestore
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email != null) {
      FirebaseFirestore.instance
          .collection("users")
          .doc(email)
          .update({"Games Lost": losses, "Chips": currentChips});
    }
  }

  // Load only once when screen opens
  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // Loads user data from Firestore
  void loadUserData() async {
    currentUserData = await _databaseService.getUserData();

    // PRINT FIRESTORE DATA TO DEBUG CONSOLE
    print("flutter: ----- Firestore Data -----");
    print("flutter: Email: ${currentUserData?.email}");
    print("flutter: Chips: ${currentUserData?.chips}");
    print("flutter: Coins: ${currentUserData?.coins}");
    print("flutter: Games Won: ${currentUserData?.games_won}");
    print("flutter: Games Lost: ${currentUserData?.games_lost}");
    print(
        "flutter: Owns Magic Card Skin: ${currentUserData?.ownMagicCardSkin}");
    print(
        "flutter: Owns Pokemon Card Skin: ${currentUserData?.ownPokemonCardSkin}");
    print(
        "flutter: Owns Purple Table Skin: ${currentUserData?.ownPurpleTableSkin}");
    print("flutter: Owns Red Table Skin: ${currentUserData?.ownRedTableSkin}");
    print("flutter: --------------------------");

    // After we get the data, update the state so the UI shows the correct info.
    setState(() {
      email = currentUserData?.email ?? '';
      wins = currentUserData?.games_won ?? 0;
      losses = currentUserData?.games_lost ?? 0;
      currentChips = currentUserData?.chips ?? 0;
      ShopScreen.coinBalance = currentUserData?.coins ?? 0;
      ShopScreen.ownsMagicCardSkin = currentUserData?.ownMagicCardSkin ?? false;
      ShopScreen.ownsPokemonCardSkin =
          currentUserData?.ownPokemonCardSkin ?? false;
      ShopScreen.ownsPurpleTableSkin =
          currentUserData?.ownPurpleTableSkin ?? false;
      ShopScreen.ownsRedTableSkin = currentUserData?.ownRedTableSkin ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total games and win percentage
    final totalGames = wins + losses;
    final winRatio = totalGames > 0 ? wins / totalGames : 0.0;
    final winPercentage = totalGames > 0 ? (wins / totalGames) * 100 : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          FirebaseAuth.instance.currentUser != null
              ? "${email?.split('@').first}'s Profile"
              : "Guest's Profile", // This handles the guest profile case
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            color: Colors.grey[850],
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (email != null && email!.contains('@'))
                        ? email!.split('@').first
                        : '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    label: const Text("Poker Player"),
                    backgroundColor: Colors.green[700],
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Win/Loss Ratio",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: winRatio,
                    color: Colors.green,
                    backgroundColor: Colors.grey[700],
                    minHeight: 8,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$wins Wins / $losses Losses",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  // Display win percentage
                  Text(
                    "Win Percentage: ${winPercentage.toStringAsFixed(2)}%",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Current Chips: $currentChips",
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            "+$chipsWon",
                            style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Chips Won",
                            style: TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "-$chipsLost",
                            style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Chips Lost",
                            style: TextStyle(color: Colors.white60),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  if (FirebaseAuth.instance.currentUser == null) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                      ),
                      onPressed: () {
                        _sfxManager.playButtonSelect();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const LoginPage(name: "Player")),
                        );
                      },
                      child: const Text("Back to Login",
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                      ),
                      onPressed: () {
                        _sfxManager.playButtonSelect();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const SignUpPage(name: "Player")),
                        );
                      },
                      child: const Text("Create an Account",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],

                  const SizedBox(
                      height:
                          12), // Adding consistent spacing before the Sign Out button

                  ElevatedButton.icon(
                    onPressed: () async {
                      await _authService.signout();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (_) => const LoginPage(name: "Player")),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Sign Out',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
