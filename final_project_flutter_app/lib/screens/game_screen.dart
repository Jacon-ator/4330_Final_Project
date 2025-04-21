import 'package:final_project_flutter_app/src/components/card_component.dart';
import 'package:flame/components.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/src/game_state.dart';
import 'package:final_project_flutter_app/src/components/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:final_project_flutter_app/models/deck.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/table.dart';

class GameScreen extends Component with HasGameRef<PokerParty> {
  // This class will handle the game logic and UI for the game screen.
  // It will include methods to start the game, update the game state,
  // and render the game UI.

  List<ActionButton>? actionButtons;
  bool waitingForPlayerInput = false;

  void showPlayerActions() {
    waitingForPlayerInput = true;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    //load all images
    try {
      await gameRef.images.loadAll([
        'art/cards/A-Hearts.png',
        'art/Poker Party Gameplay Mock Up.png',
        // 'art/2-Hearts.png',
        // 'art/3-Hearts.png',
        // 'art/4-Hearts.png',
        // 'art/5-Hearts.png',
        // 'art/6-Hearts.png',
        // 'art/7-Hearts.png',
        // 'art/8-Hearts.png',
        // 'art/9-Hearts.png',
        // 'art/10-Hearts.png',
        // 'art/J-Hearts.png',
        // 'art/Q-Hearts.png',
        // 'art/K-Hearts.png',
        // 'art/A-Diamonds.png',
        // Add other card images as needed
      ]);
    } catch (e) {
      print('Error loading images: $e');
    }
    // Load game screen components here
    // For example, you can add a background or text explaining the game rules
    final bgSprite = await gameRef.loadSprite(
        'art/Poker Party Gameplay Mock Up.png'); // Load the background sprite
    final background = SpriteComponent()
      ..sprite = bgSprite
      ..size = gameRef.size; // Makes it fill the screen

    add(background);

    print("Starting game...");
    startGame();
  }

  void updateHandUI(Player player, int index) {
    if (index >= player.hand.length) {
      print('Error: Card index out of bounds');
      return;
    }

    // Calculate position based on player and card index
    // Adjust for player position around the table
    Vector2 position;

    // Example: Position cards differently based on which player it is
    if (player == gameRef.gameState.players[0]) {
      // Human player
      position = Vector2(100 + (index * 100), gameRef.size.y - 100);
    } else {
      // Calculate AI player positions (example: distribute around top of screen)
      int playerIndex = gameRef.gameState.players.indexOf(player);
      double x = 100 + (playerIndex * 200) + (index * 30);
      double y = 150;
      position = Vector2(x, y);
    }

    add(CardComponent(
        card: player.hand[index],
        position: position,
        imagePath: 'art/cards/A-Hearts.png'));
  }

  void startGame() {
    gameRef.gameState.resetGame(); // Reset the game state
    gameRef.gameState.initializePlayers([
      'Player 1', // Human player
      'AI Player 1', // AI player
      'AI Player 2', // AI player
      'AI Player 3' // AI player
    ]);
    Future.delayed(Duration(seconds: 1), () {
      dealCards(); // Deal cards to players
    });
  }

  void dealCards() async {
    // Shuffle the deck before dealing cards
    for (Player player in gameRef.gameState.players) {
      player.receiveCard(
          gameRef.gameState.deck.dealCard()); // Deal one card to each player
      updateHandUI(player, 0);
      await Future.delayed(Duration(milliseconds: 500)); // Delay for better UX
      player.receiveCard(gameRef.gameState.deck.dealCard());
      updateHandUI(player, 1); // Deal one card to each player
      await Future.delayed(Duration(milliseconds: 500)); // Delay for better UX
      print(
          'Player ${player.name} received cards: ${player.hand[0].toString()} and ${player.hand[1].toString()}');
    }
  }
}
