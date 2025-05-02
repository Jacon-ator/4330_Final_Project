import 'package:cloud_firestore/cloud_firestore.dart';
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
      FirebaseFirestore.instance.collection("users").doc(email).update({
        "Games Won": wins,
        "Chips": currentChips
      });
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
      FirebaseFirestore.instance.collection("users").doc(email).update({
        "Games Lost": losses,
        "Chips": currentChips
      });
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

    // Reads the document from the "users" collection for the current user's email.
    currentUserData = await _databaseService.getUserData();  

    // PRINT FIRESTORE DATA TO DEBUG CONSOLE
    print("flutter: ----- Firestore Data -----");
    print("flutter: Email: ${currentUserData?.email}");
    print("flutter: Chips: ${currentUserData?.chips}");
    print("flutter: Coins: ${currentUserData?.coins}");
    print("flutter: Games Won: ${currentUserData?.games_won}");
    print("flutter: Games Lost: ${currentUserData?.games_lost}");
    print("flutter: --------------------------");

    // After we get the data, update the state so the UI shows the correct info.
    setState(() {

      // Update the email field with the value from Firestore, if it's null, use an empty string as a fallback.
      email = currentUserData?.email ?? '';
      wins = currentUserData?.games_won ?? 0;
      losses = currentUserData?.games_lost ?? 0;
      currentChips = currentUserData?.chips ?? 0;
    
    });
  }

  @override
  Widget build(BuildContext context) {
    //sets the values using the data
    final totalGames = wins + losses;
    final winRatio = totalGames > 0 ? wins / totalGames : 0.0;

    return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: Text("$email's Profile"),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Chip(
                      label: const Text("Poker Player"),
                      backgroundColor: Colors.green[700],
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    const Text("Win/Loss Ratio",
                        style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: winRatio,
                      color: Colors.green,
                      backgroundColor: Colors.grey[700],
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text("$wins Wins / $losses Losses",
                        style: const TextStyle(color: Colors.white70)),
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
                            Text("+$chipsWon",
                                style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const Text("Chips Won",
                                style: TextStyle(color: Colors.white60)),
                          ],
                        ),
                        Column(
                          children: [
                            Text("-$chipsLost",
                                style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const Text("Chips Lost",
                                style: TextStyle(color: Colors.white60)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      //temp
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            recordWin(500); // Simulate winning 500 chips
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                          ),
                          child: const Text("+500 Chips",
                              style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            recordLoss(300); // Simulate losing 300 chips
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                          ),
                          child: const Text("-300 Chips",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20), //temp
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _authService.signout();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/');
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
        ));
  }
}
