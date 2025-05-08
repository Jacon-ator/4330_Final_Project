import 'package:final_project_flutter_app/screens/poker_hands_page.dart';
import 'package:flutter/material.dart';

class InfoButton extends StatelessWidget {
  final String name;

  const InfoButton({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PokerHandsPage(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: const Icon(
          Icons.info_outline,
          size: 32,
          color: Colors.black,
        ),
      ),
    );
  }
}
