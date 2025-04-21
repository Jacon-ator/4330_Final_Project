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

  // void initializeActionButtons() {
  //   actionButtons = [
  //     ActionButton(
  //       'Check',
  //       () {
  //         // Logic for checking
  //         waitingForPlayerInput = false;
  //       },
  //       key: Key('checkButton'),
  //     ),
  //     ActionButton(
  //       'Bet',
  //       () {
  //         // Logic for betting
  //         waitingForPlayerInput = false;
  //       },
  //       key: Key('betButton'),
  //     ),
  //     ActionButton(
  //       'Fold',
  //       () {
  //         // Logic for folding
  //         waitingForPlayerInput = false;
  //       },
  //       key: Key('foldButton'),
  //     ),
  //   ];
  // }

  Future<void> onLoad() async {
    super.onLoad();
    // Load game screen components here
    // For example, you can add a background or text explaining the game rules
    final bgSprite =
        await gameRef.loadSprite('art/Poker Party Gameplay Mock Up.png');
    final background = SpriteComponent()
      ..sprite = bgSprite
      ..size = gameRef.size; // Makes it fill the screen

    add(background);

    final MainMenuButton mainMenuButton = MainMenuButton()
      ..size = Vector2(gameRef.size.x / 6, gameRef.size.y / 6)
      ..position = Vector2(
          gameRef.size.x / 2 - gameRef.size.x / 12, gameRef.size.y * 0.8);
    // add(mainMenuButton);
  }

  void playGame() {
    // Logic to initialize and start the game
    gameRef.gameState.resetGame(); // Reset the game state
    gameRef.gameState.deck; // Generate a new deck

    while (!gameRef.gameState.isGameOver) {
      // Main game loop

      playHand();
    }
  }

  void playHand() {
    // Logic to play a hand of poker
    // This will include dealing cards, managing bets, and determining the winner
    gameRef.gameState.deck
        .shuffleDeck(); // Shuffle the deck before dealing cards
    for (Player player in gameRef.gameState.players) {
      player.receiveCard(
          gameRef.gameState.deck.dealCard()); // Deal one card to each player
      player.receiveCard(
          gameRef.gameState.deck.dealCard()); // Deal one card to each player
      print('Player ${player.name} received cards: ${player.hand}');
    }
    // Continue with the game logic for betting, community cards, etc.
    while (!gameRef.gameState.table.potIsRight) {
      int currentPlayerIndex = gameRef.gameState.currentPlayerIndex;
      for (Player player in gameRef.gameState.players) {
        // Logic for each player to place bets, check, fold, etc.
        // This will depend on the game rules and player actions
        // For example, you can prompt the player for their action and update the game state accordingly

        while (gameRef.gameState.players[currentPlayerIndex].isCurrentTurn) {
          // Logic for the current player to take their turn
          // This could include betting, checking, folding, etc.
          // You can use a dialog or input field to get the player's action
          // For example, you can prompt the player for their action and update the game state accordingly

          if (player.isAI) {
            player.makeAIDecision();
            player.isCurrentTurn == false; // AI makes a decision
          } else {
            // Logic for human player to take their turn
            // This could include betting, checking, folding, etc.
            // You can use a dialog or input field to get the player's action
            // For example, you can prompt the player for their action and update the game state accordingly
          }
        }
      }
    }
  }
}
