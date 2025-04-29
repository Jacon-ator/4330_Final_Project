import 'package:flutter/material.dart';

class PokerProfilePage extends StatefulWidget {
  final String name;

  const PokerProfilePage({super.key, required this.name});

  @override
  State<PokerProfilePage> createState() => _PokerProfilePageState();
}

class _PokerProfilePageState extends State<PokerProfilePage> {
  int wins = 0;
  int losses = 0;
  int chipsWon = 0;
  int chipsLost = 0;
  int currentChips = 5000; // Starting chips

  // These methods could be called from real game logic later:
  void recordWin(int amountWon) {
    setState(() {
      wins++;
      currentChips += amountWon;
      chipsWon += amountWon;
    });
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
  }

  @override
  Widget build(BuildContext context) {
    final totalGames = wins + losses;
    final winRatio = totalGames > 0 ? wins / totalGames : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("${widget.name}'s Profile"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Card(
          color: Colors.grey[850],
          margin: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
