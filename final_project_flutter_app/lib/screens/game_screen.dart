import 'dart:async';

import 'package:final_project_flutter_app/components/buttons/gameplay/play_next_round_button.dart';
import 'package:final_project_flutter_app/components/buttons/gameplay/raise_slider.dart';
import 'package:final_project_flutter_app/components/components.dart';
import 'package:final_project_flutter_app/config.dart';
import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/card_evaluator.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/game_state.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameScreen extends Component with HasGameRef<PokerParty> {
  // This class will handle the game logic and UI for the game screen.
  // It will include methods to start the game, update the game state,
  // and render the game UI.

  List<ActionButton>? actionButtons;
  int playerIndex = 0;
  int dealerIndex = -1;
  late GameState gameState = gameRef.gameState; // Reference to the game state
  CardEvaluator cardEvaluator = CardEvaluator();
  bool showPlayAgainButton = false;
  int potRightCount = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    gameState = gameRef.gameState; // Get the game state from the game reference

    await gameRef.images.loadAll([
      AssetPaths.cardFronts,
      AssetPaths.cardBacks,
    ]);

    // Load sprites
    final tableSprite = await gameRef.loadSprite('art/Base Poker Table.png');
    final uiSprite = await gameRef.loadSprite('art/Base Player UI.png');
    final chatMenuSprite = await gameRef.loadSprite('art/Chat Menu.png');

    // Define heights based on the screen dimensions
    var scalarForDiff = 0.755;
    final tableHeight = gameRef.size.y * scalarForDiff;
    final uiHeight = gameRef.size.y * (1 - scalarForDiff);

    // Define chat menu width as, e.g., 25% of the total screen width
    final chatMenuWidth = gameRef.size.x * 0.242;
    final tableWidth =
        gameRef.size.x - chatMenuWidth; // remaining width for the poker table

    // Create the poker table component (occupies the left portion)
    final pokerTable = SpriteComponent()
      ..sprite = tableSprite
      ..size = Vector2(tableWidth, tableHeight)
      ..position = Vector2(0, 0)
      // Set the same priority as chat to have them on the same layer
      ..priority = 0;

    // Create the chat menu component (occupies the right portion of the table area)
    final chatMenu = SpriteComponent()
      ..sprite = chatMenuSprite
      ..size = Vector2(chatMenuWidth, tableHeight)
      ..position = Vector2(tableWidth, 0)
      ..priority = 0;

    // Create the player UI component (occupies the bottom 30% of the screen)
    final playerUI = SpriteComponent()
      ..sprite = uiSprite
      ..size = Vector2(gameRef.size.x, uiHeight)
      ..position = Vector2(0, tableHeight)
      ..priority = 0;

    // Add the components
    add(pokerTable);
    add(chatMenu);
    add(playerUI);

    add(HandArea());
    add(CommunityCardArea());

    print("Starting game...");
    gameState.initializePlayers();
    await startGame();
  }

  Future<void> startGame() async {
    gameState.resetGame();
    dealerIndex =
        (dealerIndex + 1) % gameState.players.length; // Move to the next dealer

    HandArea? handArea = children.whereType<HandArea>().firstOrNull;
    CommunityCardArea? ccardArea =
        children.whereType<CommunityCardArea>().firstOrNull;

    if (handArea != null) {
      handArea.clearCards();
    }
    if (ccardArea != null) {
      ccardArea.clearCards();
    }
    await dealCards();
    blinds(); // Place the blinds for the game

    playerIndex = dealerIndex;
    await playerTurn();
  }

  Future<void> dealCards() async {
    gameState.deck.shuffleDeck();

    for (Player player in gameState.players) {
      player.receiveCard(gameState.deck.dealCard());
      player.receiveCard(gameState.deck.dealCard());

      print("Community cards dealt: ${gameState.communityCards.toString()}");
      print(
          '${player.name} received cards: ${player.hand[0].toString()} and ${player.hand[1].toString()}');
    }
  }

  Future<void> nextPlayer() async {
    // move to next player
    bool potRight = false; // Flag to check if the pot is right
    playerIndex = (playerIndex + 1) % gameState.players.length;
    if (playerIndex == dealerIndex) {
      potRight = checkPotIsRight(gameState.players);
    }
    if (potRight) {
      gameState.round++;
      await roundBasedDealing(gameState.round);
    }
    gameState.players[playerIndex].isCurrentTurn = true;

    await playerTurn();
    print('Next player is ${gameState.players[playerIndex].name}');
  }

  Future<void> playerTurn() async {
    List<Player> playerList = gameRef.gameState.players;

    // Set the first player as current turn
    Player currentPlayer = playerList[playerIndex];

    // This method will be called to start the player's turn.
    // It will show the action buttons and wait for player input.
    if (currentPlayer.isFolded || currentPlayer.isAllIn) {
      print(
          '${currentPlayer.name} has folded or cannot bet any more money. Skipping turn.');
      currentPlayer.isCurrentTurn = false; // End the current player's turn
      await nextPlayer(); // Skip to the next player if current player has folded
      return;
    }

    currentPlayer.isCurrentTurn = true; // Set current player turn to true

    print(
        'Current player: ${currentPlayer.name} balance: ${currentPlayer.balance},amount to call: ${currentPlayer.getCallAmount(gameRef)}');

    if (currentPlayer.isAI) {
      // If it's an AI player's turn, handle AI logic here
      print('AI Player ${currentPlayer.name}\'s turn.');
      endRoundIfFolded(currentPlayer);
      int amount = await currentPlayer.makeAIDecision(gameRef);
      gameRef.gameState.pot += amount; // Add the bet to the pot
      currentPlayer.isCurrentTurn = false; // End AI turn after decision
      endRoundIfFolded(currentPlayer);

      await nextPlayer(); // Move to the next player
    } else {
      showPlayerActions(currentPlayer);
    }
  }

  void showPlayerActions(Player player) {
    updateHandUI(player, 0); // Update the hand UI for the current player
    updateHandUI(player, 1); // Update the hand UI for the second card
    print('Showing player actions...');
    print(
        'Current player: ${gameState.players[playerIndex].name}, amount to call: ${player.getCallAmount(gameRef)}');

    // Set the base position for the first button
    children.whereType<ActionButton>().forEach((button) {
      remove(button); // Remove any existing action buttons
    });
    Vector2 basePosition = Vector2(50, gameRef.size.y - 140);

    final double exportScale = 5; // your export scale factor

    final checkButton = ActionButton('Check', () async {
      if (!gameState.isGameOver && player.isCurrentTurn) {
        print('${player.name} checked!');
        player.isCurrentTurn = false;
        await nextPlayer();
      } else {
        print('It is not your turn!');
      }
    },
        // Using exported coordinates for Check button:
        spriteSrcPosition: Vector2(71 * exportScale, 0 * exportScale),
        spriteSrcSize: Vector2(24 * exportScale, 23 * exportScale),
        position: basePosition);
    // First button - Call button region from the spritesheet.
    final callButton = ActionButton(
      'Call',
      () async {
        if (!gameState.isGameOver && player.isCurrentTurn) {
          print('${player.name} called!');
          int bet = player.call(gameRef);
          gameState.pot += bet; // Add the bet to the pot
          player.isCurrentTurn = false;
          await nextPlayer();
        } else {
          print('It is not your turn!');
        }
      },
      // Using exported coordinates for Call button:
      spriteSrcPosition: Vector2(0 * exportScale, 0 * exportScale),
      spriteSrcSize: Vector2(23 * exportScale, 23 * exportScale),
      position: basePosition,
    );

    if (player.getCallAmount(gameRef) == 0) {
      add(checkButton); // Remove the button if not needed
    } else {
      add(callButton); // Add the button to the game
    }

    // Second button - Fold button (adjust these coordinates as needed).
    final foldButton = ActionButton(
      'Fold',
      () async {
        if (!gameState.isGameOver && player.isCurrentTurn) {
          print('${player.name} folded!');
          player.fold();
          player.isCurrentTurn = false;
          await nextPlayer();
        } else {
          print('It is not your turn!');
        }
      },
      // Using exported coordinates for Call button:
      spriteSrcPosition:
          Vector2(24 * exportScale, 0 * exportScale), // change as needed
      spriteSrcSize:
          Vector2(23 * exportScale, 23 * exportScale), // change as needed
      // Optionally use the previous button’s position to auto-layout.
      position: basePosition + Vector2(150, 0),
    );
    add(foldButton);

    // Third button - Raise button (adjust coordinates accordingly)
    final raiseButton = ActionButton(
      'Raise',
      () async {
        if (!gameState.isGameOver && player.isCurrentTurn) {
          int bet = await showSlider();
          print('${player.name} raised to $bet!');
          gameState.pot += bet; // Add the bet to the pot
          hideRaiseSlider();
          player.isCurrentTurn = false;
          await nextPlayer();
        } else {
          print('It is not your turn!');
        }
      },
      // For example:
      spriteSrcPosition:
          Vector2(48 * exportScale, 0 * exportScale), // change as needed
      spriteSrcSize:
          Vector2(23 * exportScale, 23 * exportScale), // change as needed
      position: basePosition + Vector2(300, 0),
    );
    add(raiseButton);
  }

  void blinds() {
    // This method will handle the blinds for the game.
    // It will deduct the small and big blinds from the players' balances.
    if (gameState.players.length < 2) {
      print('Not enough players to place blinds.');
      return;
    }

    Player smallBlindPlayer =
        gameState.players[(dealerIndex + 1) % gameState.players.length];
    Player bigBlindPlayer =
        gameState.players[(dealerIndex + 2) % gameState.players.length];

    smallBlindPlayer.placeBet(gameState.smallBlind);
    bigBlindPlayer.placeBet(gameState.bigBlind);

    print(
        '${smallBlindPlayer.name} placed small blind of ${gameState.smallBlind}');
    print('${bigBlindPlayer.name} placed big blind of ${gameState.bigBlind}');
  }

  void updateHandUI(Player player, int index) {
    if (index >= player.hand.length) {
      print('Error: Card index out of bounds');
      return;
    }

    // Find the HandArea component
    final handArea = children.whereType<HandArea>().firstOrNull;
    if (handArea == null) {
      print('Error: HandArea not found');
      return;
    }

    // Create the card component
    final cardComponent = CardComponent(
      card: player.hand[index],
    );

    // Add the card to the HandArea instead of directly to the screen
    handArea.addCard(player, cardComponent, index);
  }

  int checkFolds() {
    int foldCount = 0;
    for (Player player in gameState.players) {
      if (player.isFolded) {
        foldCount++;
      }
    }
    return foldCount;
  }

  void endRoundIfFolded(Player currentPlayer) {
    int foldCount = checkFolds();
    if (foldCount == gameState.players.length - 1) {
      print('All other players folded. ${currentPlayer.name} wins by default!');
      roundBasedDealing(4); // skips to the determining of the winner
      return; // Exit the turn
    }
  }

  bool checkPotIsRight(List<Player> players) {
    List<Player> activePlayers = players.where((p) => !p.isFolded).toList();
    for (var player in activePlayers) {
      if (player.getCallAmount(gameRef) != 0) {
        print('${player.name} has not called yet. Pot is not right.');
        return false; // If any player has not called, pot is not right
      }
    }
    print('Pot is right!');
    return true;
  }

  Future<void> roundBasedDealing(int round) async {
    //find the community card area component
    final communityCardArea =
        children.whereType<CommunityCardArea>().firstOrNull;

    switch (round) {
      case 0: // Pre-flop
        print('Pre-flop round, no community cards shown.');
        break;
      case 1: // Flop
        print('Flop round, showing 3 community cards.');
        gameState.deck.dealCard(); // Burn a card
        for (int i = 0; i < 3; i++) {
          PlayingCard card = gameState.deck.dealCard();
          gameState.communityCards.add(card);

          communityCardArea!
              .addCard(card, i, gameRef); // Add the card to the community area
        }
        break;
      case 2: // Turn
        print('Turn round, showing 1 community card.');
        gameState.deck.dealCard(); // Burn a card
        for (int i = 3; i < 4; i++) {
          PlayingCard card = gameState.deck.dealCard();
          gameState.communityCards.add(card);

          communityCardArea!
              .addCard(card, i, gameRef); // Add the card to the community area
        }
        break;
      case 3: // River
        print('River round, showing 1 community card.');
        gameState.deck.dealCard(); // Burn a card
        for (int i = 4; i < 5; i++) {
          PlayingCard card = gameState.deck.dealCard();
          gameState.communityCards.add(card);

          communityCardArea!
              .addCard(card, i, gameRef); // Add the card to the community area
        }
        break;
      case 4: // End of game
        Player winner = determineWinner();
        winner.balance += gameState.pot; // Add the pot to the winner's balance
        gameState.isGameOver = true; // Set the game state to over
        if (checkFolds() == gameState.players.length - 1) {
          print('${winner.name} wins by default!');
        } else {
          print(
              '${winner.name} wins the game with a ${winner.handRank.toString()}!');
        }

        // Show the play again button
        showPlayAgainButton = true;
        late final PlayNextRoundButton playAgainButton;
        playAgainButton = PlayNextRoundButton(
          spriteSrcPosition: Vector2(0, 0), // Replace with appropriate values
          spriteSrcSize: Vector2(100, 50), // Replace with appropriate values
          position: Vector2(gameRef.size.x / 2 - 50, gameRef.size.y / 2 - 25),
          () async {
            showPlayAgainButton = false; // Hide the button
            remove(playAgainButton); // Remove the button from the screen
            await startGame(); // Start a new game
          },
        );
        add(playAgainButton);

        break;
      default:
        print('Invalid round number: $round');
        break;
    }
  }

  Player determineWinner() {
    Map<HandRank, int> handranksToInts = {
      HandRank.highCard: 1,
      HandRank.onePair: 2,
      HandRank.twoPair: 3,
      HandRank.threeOfAKind: 4,
      HandRank.straight: 5,
      HandRank.flush: 6,
      HandRank.fullHouse: 7,
      HandRank.fourOfAKind: 8,
      HandRank.straightFlush: 9,
    };
    List<Player> contenders =
        gameState.players.where((p) => !p.isFolded).toList();

    if (contenders.length == 1) {
      print(
          '${contenders[0].name} is the only player left, they win by default!');
      return contenders[0]; // If only one player is left, they win by default
    }

    for (Player contender in contenders) {
      contender.handRank = cardEvaluator
          .bestOfSeven([...contender.hand, ...gameState.communityCards]);
      print(
          '${contender.name} has a ${contender.handRank.toString()} with hand: ${contender.hand}');
    }

    contenders.sort((a, b) =>
        handranksToInts[b.handRank]!.compareTo(handranksToInts[a.handRank]!));
    Player winner =
        contenders.first; // The first player in the sorted list is the winner
    print('Winner is ${winner.name} with a ${winner.handRank.toString()}!');
    return winner; // Return the winner
  }

  Future<int> showSlider() async {
    final completer = Completer<int>();
    int selectedValue = gameState.players[playerIndex].getCallAmount(gameRef);

    if (!gameRef.overlays.isActive('RaiseSlider')) {
      gameRef.overlays.addEntry(
        'RaiseSlider',
        (context, game) => Center(
          child: Container(
            width: gameRef.size.x * 0.4,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A)
                  .withOpacity(0.95), // Dark border color
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Select Raise Amount',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF1E4C3), // Light title
                  ),
                ),
                const SizedBox(height: 20),
                RaiseSlider(
                  minRaise:
                      gameState.players[playerIndex].getCallAmount(gameRef),
                  maxRaise: gameState.players[playerIndex].balance,
                  currentChips: gameState.players[playerIndex].balance,
                  onChanged: (int value) {
                    selectedValue = value;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3B8C2C), // Felt green
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                        foregroundColor: Color(0xFFF1E4C3), // Text
                      ),
                      onPressed: () {
                        int bet = gameState.players[playerIndex]
                            .placeBet(selectedValue);
                        hideRaiseSlider();
                        completer.complete(bet);
                      },
                      child: const Text('Confirm'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFFD48C2D)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        foregroundColor: Color(0xFFD48C2D),
                      ),
                      onPressed: () {
                        hideRaiseSlider();
                        completer.complete(0);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    gameRef.overlays.add('RaiseSlider');
    return completer.future;
  }

  void hideRaiseSlider() {
    // Remove the overlay when done
    gameRef.overlays.remove('RaiseSlider');
  }
}
