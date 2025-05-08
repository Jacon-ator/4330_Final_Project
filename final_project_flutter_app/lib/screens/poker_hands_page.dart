import 'package:final_project_flutter_app/models/card.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PokerHandsPage extends StatelessWidget {
  const PokerHandsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            const Text(
              'Poker Hand Rankings',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontFamily: 'C&C Red Alert [INET]',
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildHandRow('Royal Flush', [
                    PlayingCard(suit: "hearts", rank: 10, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 11, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 12, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 13, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 14, position: Vector2.zero()),
                  ]),
                  _buildHandRow('Four of a Kind', [
                    PlayingCard(suit: "spades", rank: 9, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 9, position: Vector2.zero()),
                    PlayingCard(suit: "clubs", rank: 9, position: Vector2.zero()),
                    PlayingCard(suit: "diamonds", rank: 9, position: Vector2.zero()),
                    PlayingCard(suit: "spades", rank: 2, position: Vector2.zero()),
                  ]),
                  _buildHandRow('Full House', [
                    PlayingCard(suit: "diamonds", rank: 3, position: Vector2.zero()),
                    PlayingCard(suit: "clubs", rank: 3, position: Vector2.zero()),
                    PlayingCard(suit: "spades", rank: 3, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 6, position: Vector2.zero()),
                    PlayingCard(suit: "clubs", rank: 6, position: Vector2.zero()),
                  ]),
                  _buildHandRow('Flush', [
                    PlayingCard(suit: "hearts", rank: 2, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 6, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 9, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 11, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 13, position: Vector2.zero()),
                  ]),
                  _buildHandRow('Straight', [
                    PlayingCard(suit: "clubs", rank: 5, position: Vector2.zero()),
                    PlayingCard(suit: "hearts", rank: 6, position: Vector2.zero()),
                    PlayingCard(suit: "diamonds", rank: 7, position: Vector2.zero()),
                    PlayingCard(suit: "spades", rank: 8, position: Vector2.zero()),
                    PlayingCard(suit: "clubs", rank: 9, position: Vector2.zero()),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandRow(String label, List<PlayingCard> cards) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'C&C Red Alert [INET]',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: cards
                .map((card) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 52,
                        height: 84,
                        //child: CardComponent(card: card),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
