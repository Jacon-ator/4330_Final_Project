import 'package:flutter/material.dart';

class PokerProfilePage extends StatelessWidget {
  const PokerProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text("Poker Profile"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/poker_avatar.jpg'),
          ),
          const SizedBox(height: 10),
          const Text(
            "AceHighKing",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Level: Shark 🦈",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: const [
                  PokerStatRow(label: "Hands Played", value: "4,278"),
                  Divider(color: Colors.grey),
                  PokerStatRow(label: "Win Rate", value: "58.6%"),
                  Divider(color: Colors.grey),
                  PokerStatRow(label: "Total Chips Won", value: "₵1.2M"),
                  Divider(color: Colors.grey),
                  PokerStatRow(label: "Biggest Pot Won", value: "₵87,400"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "\"Playing the player, not the cards.\"",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class PokerStatRow extends StatelessWidget {
  final String label;
  final String value;

  const PokerStatRow({required this.label, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        Text(value,
            style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
