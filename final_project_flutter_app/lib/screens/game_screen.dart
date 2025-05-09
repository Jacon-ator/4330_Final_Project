import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/components/buttons/gameplay/end_lobby_button.dart';
import 'package:final_project_flutter_app/components/buttons/gameplay/play_next_round_button.dart';
import 'package:final_project_flutter_app/components/buttons/gameplay/raise_slider.dart';
import 'package:final_project_flutter_app/components/components.dart';
import 'package:final_project_flutter_app/config.dart';
import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/card_evaluator.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/calculator.dart';
import 'package:final_project_flutter_app/services/game_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameScreen extends Component with HasGameRef<PokerParty> {
  // This class will handle the game logic and UI for the game screen.
  // It will include methods to start the game, update the game state,
  // and render the game UI.

  List<ActionButton>? actionButtons;

  late GameState gameState = gameRef.gameState; // Reference to the game state
  CardEvaluator cardEvaluator = CardEvaluator();
  final SFXManager _sfxManager = SFXManager();
  StreamSubscription<DocumentSnapshot>? _gameStateSubscription;
  String tableSkinImage = 'art/Base Poker Table.png';
  String cardSkinImage = 'art/cards/Black Card Back.png';

  // Store direct references to frequently accessed components to avoid race conditions
  late HandArea handArea;
  late CommunityCardArea communityCardArea;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Initialize and play the in-play theme
    print('[AUDIO] GameScreen: Initializing audio...');
    await gameRef.audioManager.initialize();
    await gameRef.audioManager.playInPlayTheme();
    print('[AUDIO] GameScreen: Audio initialized and in-play theme started');

    // Play the riffle shuffle sound
    print('[SFX] GameScreen: Playing riffle shuffle sound...');
    await _sfxManager.playRiffleShuffle();
    print('[SFX] GameScreen: Riffle shuffle sound played');

    gameState = gameRef.gameState; // Get the game state from the game reference

    await loadUserTableSkin(); // Load the table skin based on the user's preferences
    await loadUserCardSkin(); // Load card skins

    await gameRef.images.loadAll([
      AssetPaths.cardFronts,
      AssetPaths.cardBacks,
    ]);

    // Load sprites
    final cardSprite = await gameRef.loadSprite(cardSkinImage);
    final tableSprite = await gameRef.loadSprite(tableSkinImage);
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

    // Adds the player profile icon
    final ProfilePicture profilePicture = ProfilePicture()
      ..size = Vector2(20 * 5.2, 27 * 5.76)
      ..position = Vector2(1150, 523);

    // Create left card sprites (left side of the table)
    final leftCardSprite1 = SpriteComponent()
      ..sprite = cardSprite
      ..size = Vector2(50, 80)
      ..position = Vector2(150, tableHeight / 2 - 50)
      ..angle = 0.75
      ..priority = 1;

    final leftCardSprite2 = SpriteComponent()
      ..sprite = cardSprite
      ..size = Vector2(50, 80)
      ..position = Vector2(150, tableHeight / 2 + 10)
      ..angle = 1.35
      ..priority = 1;

    // Create top card sprites (top side of the table)
    final topCardSprite1 = SpriteComponent()
      ..sprite = cardSprite
      ..size = Vector2(50, 80)
      ..position = Vector2(tableWidth / 2 - 30, 30)
      ..angle = 0.5
      ..priority = 1;

    final topCardSprite2 = SpriteComponent()
      ..sprite = cardSprite
      ..size = Vector2(50, 80)
      ..position = Vector2(tableWidth / 2 + 20, 30)
      ..angle = -0.5
      ..priority = 1;

    // Create right card sprites (right side of the table)
    final rightCardSprite1 = SpriteComponent()
      ..sprite = cardSprite
      ..size = Vector2(50, 80)
      ..position = Vector2(tableWidth - 120, tableHeight / 2 - 40)
      ..angle = 1.2
      ..priority = 1;

    final rightCardSprite2 = SpriteComponent()
      ..sprite = cardSprite
      ..size = Vector2(50, 80)
      ..position = Vector2(tableWidth - 120, tableHeight / 2 + 15)
      ..angle = 0.75
      ..priority = 1;

    // Create bottom card sprites (bottom side of the table)
    final bottomCardSprite1 = SpriteComponent()
      ..sprite = cardSprite
      ..size = Vector2(50, 80)
      ..position = Vector2(tableWidth / 2 - 60,
          tableHeight - 100) // Position at the bottom center
      ..angle = -0.75 // Adjust the angle to make it appear flipped
      ..priority = 1;

    final bottomCardSprite2 = SpriteComponent()
      ..sprite = cardSprite
      ..size = Vector2(50, 80)
      ..position = Vector2(tableWidth / 2 + 30,
          tableHeight - 100) // Position next to the first card
      ..angle = 0.2 // Adjust the angle to make it appear flipped
      ..priority = 1;

    late final EndLobbyButton endLobbyButton;
    endLobbyButton = EndLobbyButton(
      spriteSrcPosition:
          Vector2(137 * 5, 62 * 5), // Replace with appropriate values
      spriteSrcSize: Vector2(80 * 5, 13 * 5), // Replace with appropriate values
      position: Vector2(gameRef.size.x * 3 / 4 + 15, gameRef.size.y / 2 + 70),
      spriteScale: 0.70,
      () async {
        gameState.isLobbyActive = false; // Set the lobby state to inactive
        await updateGameStateInFirebase();
        gameRef.gameState.reset();
        gameRef.router.popUntilNamed("menu"); // Navigate to the lobby screen
      },
    ); // Add the components
    add(pokerTable);
    add(chatMenu);
    add(endLobbyButton); // Add the button to the screen
    add(playerUI);
    add(profilePicture);
    add(topCardSprite1);
    add(topCardSprite2);
    add(leftCardSprite1);
    add(leftCardSprite2);
    add(rightCardSprite1);
    add(rightCardSprite2);
    add(bottomCardSprite1);
    add(bottomCardSprite2);

    // Initialize HandArea and CommunityCardArea as class members to avoid race conditions
    handArea = HandArea();
    communityCardArea = CommunityCardArea();

    // Add them to the component tree
    await add(handArea);
    await add(communityCardArea);

    // Initial game setup
  }

  @override
  Future<void> onMount() async {
    super.onMount();
    await initializePlayers();
    await startGame();
    setupFirebaseListener();
  }

  Future<void> initializePlayers() async {
    print("Initializing players...");
    if (isOffline) {
      gameState.initializePlayers();
    } else {
      await gameState.initializePlayersFromLobby(FirebaseFirestore.instance);
    }
    await updateGameStateInFirebase();
  }

  void setupFirebaseListener() {
    if (isOffline) return;

    // Clear any existing subscription to avoid duplicates
    _gameStateSubscription?.cancel();

    // Listen for game state changes from other players
    _gameStateSubscription = FirebaseFirestore.instance
        .collection('games')
        .doc('primary_game')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        // Only update if it's not this player's turn
        final currentPlayerId = FirebaseAuth.instance.currentUser?.uid;
        final remoteGameState = GameState.fromJson(snapshot.data()!);

        if (remoteGameState.isGameOver) {
          gameState.removePlayer(currentPlayerId!);
          gameRef.router.pushNamed("menu");
        }

        // Find current player in the remote game state
        final currentPlayer = remoteGameState.players.firstWhere(
          (p) => p.id == currentPlayerId,
        );

        // If it's not this player's turn, update the local game state
        if (!currentPlayer.isCurrentTurn!) {
          gameState = remoteGameState;
          // updateUI();
        }
      }
    });
  }

  Future<void> startGame() async {
    gameState.resetGame();
    await updateGameStateInFirebase();
    gameState.dealerIndex = (gameState.dealerIndex + 1) %
        gameState.players.length; // Move to the next dealer

    // Use the class member variables directly instead of searching for them
    handArea.clearCards();
    communityCardArea.clearCards();

    await dealCards();
    await blinds(); // Place the blinds for the game

    gameState.playerIndex = gameState.dealerIndex;

    await updateGameStateInFirebase();
    await playerTurn();
  }

  Future<void> dealCards() async {
    // gameState.deck.shuffleDeck();

    for (Player player in gameState.players) {
      player.receiveCard(gameState.deck.dealCard());
      player.receiveCard(gameState.deck.dealCard());

      print("Community cards dealt: ${gameState.communityCards.toString()}");
      print(
          '${player.name} received cards: ${player.hand![0].toString()} and ${player.hand![1].toString()}');
    }

    await updateGameStateInFirebase();
  }

  Future<void> nextPlayer() async {
    // move to next player

    bool potRight = checkPotIsRight(gameState.players);

    if (potRight) {
      gameState.round++;
      await roundBasedDealing(gameState.round);
      gameState.playerIndex =
          (gameState.playerIndex + 1) % gameState.players.length;
      gameState.players[gameState.playerIndex].isCurrentTurn = true;
    } else {
      gameState.playerIndex =
          (gameState.playerIndex + 1) % gameState.players.length;
      gameState.players[gameState.playerIndex].isCurrentTurn = true;
    }
    if (gameState.isGameOver) {
      await updateGameStateInFirebase();
      return;
    }
    print('Next player is ${gameState.players[gameState.playerIndex].name}');
    await updateGameStateInFirebase();
    await playerTurn();
  }

  Future<void> playerTurn() async {
    Player currentPlayer = gameState.players[gameState.playerIndex];
    // Set the first player as current turn

    // This method will be called to start the player's turn.
    // It will show the action buttons and wait for player input.
    if (currentPlayer.isFolded! || currentPlayer.isAllIn!) {
      print(
          '${currentPlayer.name} has folded or cannot bet any more money. Skipping turn.');
      currentPlayer.isCurrentTurn = false; // End the current player's turn
      await updateGameStateInFirebase();
      await nextPlayer(); // Skip to the next player if current player has folded
      return;
    }

    currentPlayer.isCurrentTurn = true; // Set current player turn to true

    print(
        'Current player: ${currentPlayer.name} balance: ${currentPlayer.balance},amount to call: ${currentPlayer.getCallAmount(gameRef)}');

    if (currentPlayer.isAI!) {
      // If it's an AI player's turn, handle AI logic here
      print('AI Player ${currentPlayer.name}\'s turn.');
      if (!await endRoundIfFolded(currentPlayer)) {
        int amountToCall = currentPlayer.getCallAmount(gameRef);
        int amount = await currentPlayer.makeAIDecision(gameRef);
        currentPlayer.hasPlayedThisRound = true; // Mark as played this round
        if (amount > amountToCall) {
          await resetTurnsOnRaise(currentPlayer);
        }
        gameRef.gameState.pot += amount; // Add the bet to the pot
        currentPlayer.isCurrentTurn = false; // End AI turn after decision
        await updateGameStateInFirebase();
        await endRoundIfFolded(currentPlayer);

        await nextPlayer(); // Move to the next player
      }
    } else {
      await updateGameStateInFirebase();
      showPlayerActions(currentPlayer);
    }
  }

  void showPlayerActions(Player player) {
    // Only update hand UI if the player has cards
    if (player.hand != null && player.hand!.length >= 2) {
      updateHandUI(player, 0); // Update the hand UI for the current player
      updateHandUI(player, 1); // Update the hand UI for the second card
    }

    print('Showing player actions...');
    print(
        'Current player: ${gameState.players[gameState.playerIndex].name}, amount to call: ${player.getCallAmount(gameRef)}');

    // Set the base position for the first button
    children.whereType<ActionButton>().forEach((button) {
      remove(button); // Remove any existing action buttons
    });
    Vector2 basePosition = Vector2(50, gameRef.size.y - 140);

    final double exportScale = 5; // your export scale factor

    final checkButton = ActionButton('Check', () async {
      if (!gameState.isGameOver && player.isCurrentTurn!) {
        print('${player.name} checked!');
        player.hasPlayedThisRound = true; // Mark as played this round

        player.isCurrentTurn = false;
        await updateGameStateInFirebase();
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
        if (!gameState.isGameOver && player.isCurrentTurn!) {
          print('${player.name} called!');
          int bet = player.call(gameRef);
          gameState.pot += bet; // Add the bet to the pot
          player.hasPlayedThisRound = true; // Mark as played this round

          player.isCurrentTurn = false;
          await updateGameStateInFirebase();
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
        if (!gameState.isGameOver && player.isCurrentTurn!) {
          print('${player.name} folded!');
          player.fold();
          player.hasPlayedThisRound = true; // Mark as played this round

          player.isCurrentTurn = false;
          await updateGameStateInFirebase();
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
      // Optionally use the previous button's position to auto-layout.
      position: basePosition + Vector2(150, 0),
    );
    add(foldButton);

    // Third button - Raise button (adjust coordinates accordingly)
    final raiseButton = ActionButton(
      'Raise',
      () async {
        if (!gameState.isGameOver && player.isCurrentTurn!) {
          int bet = await showSlider();
          print('${player.name} raised to $bet!');
          gameState.pot += bet; // Add the bet to the pot
          await resetTurnsOnRaise(player);
          hideRaiseSlider();
          player.isCurrentTurn = false;
          await updateGameStateInFirebase();
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

  Future<void> resetTurnsOnRaise(Player player) async {
    player.hasPlayedThisRound = true; // Mark as played this round
    for (var p in gameState.players.where((p) => p != player)) {
      p.hasPlayedThisRound =
          false; // reset for all other players since the raise allows them to decide to raise again or
    }
    await updateGameStateInFirebase();
  }

  Future<void> blinds() async {
    // This method will handle the blinds for the game.
    // It will deduct the small and big blinds from the players' balances.
    if (gameState.players.length < 2) {
      print('Not enough players to place blinds.');
      return;
    }

    Player smallBlindPlayer = gameState
        .players[(gameState.dealerIndex + 1) % gameState.players.length];
    Player bigBlindPlayer = gameState
        .players[(gameState.dealerIndex + 2) % gameState.players.length];

    smallBlindPlayer.placeBet(gameState.smallBlind);
    bigBlindPlayer.placeBet(gameState.bigBlind);

    print(
        '${smallBlindPlayer.name} placed small blind of ${gameState.smallBlind}');
    print('${bigBlindPlayer.name} placed big blind of ${gameState.bigBlind}');
    await updateGameStateInFirebase();
  }

  void updateUI() {
    // Update the UI based on the current game state
    // Clear existing UI elements
    children.whereType<ActionButton>().forEach(remove);

    // Update hand display
    handArea.clearCards();

    // Display the current player's cards
    final currentPlayerId = FirebaseAuth.instance.currentUser?.uid;
    Player currentPlayer = gameState.players.firstWhere(
      (p) => p.id == currentPlayerId,
    );

    if (currentPlayer.hand != null) {
      updateHandUI(currentPlayer, 0);
      updateHandUI(currentPlayer, 1);
    }

    // Update community cards
    communityCardArea.clearCards();

    for (int i = 0; i < gameState.communityCards.length; i++) {
      communityCardArea.addCard(gameState.communityCards[i], i, gameRef);
    }

    // If it's the current player's turn, show action buttons
    if (currentPlayer.isCurrentTurn!) {
      showPlayerActions(currentPlayer);
    }
  }

  void updateHandUI(Player player, int index) {
    print('Updating hand UI for player: ${player.name}, card index: $index');
    if (index >= player.hand!.length) {
      print('Error: Card index out of bounds');
      return;
    }

    // Create the card component
    final cardComponent = CardComponent(
      card: player.hand![index],
    );

    // Add the card to the HandArea using the class member reference
    handArea.addCard(player, cardComponent, index);
  }

  int checkFolds() {
    int foldCount = 0;
    for (Player player in gameState.players) {
      if (player.isFolded!) {
        foldCount++;
      }
    }
    return foldCount;
  }

  Future<bool> endRoundIfFolded(Player currentPlayer) async {
    int foldCount = checkFolds();
    if (foldCount == gameState.players.length - 1) {
      Player winner = determineWinner();
      winner.balance += gameState.pot; // Add the pot to the winner's balance
      gameState.isGameOver = true; // Set the game state to over
      if (checkFolds() == gameState.players.length - 1) {
        print('${winner.name} wins by default!');
        winner.balance += gameState.pot; // Add the pot to the winner's balance
      } else {
        print('${winner.name} wins the game with a ${winner.hand.toString()}!');
      }

      // Show the play again button
      late final PlayNextRoundButton playAgainButton;
      playAgainButton = PlayNextRoundButton(
        spriteSrcPosition:
            Vector2(137 * 5, 48 * 5), // Replace with appropriate values
        spriteSrcSize:
            Vector2(80 * 5, 13 * 5), // Replace with appropriate values
        position: Vector2(gameRef.size.x * 3 / 4 + 15, gameRef.size.y / 2),
        spriteScale: 0.73,
        () async {
          remove(playAgainButton); // Remove the button from the screen
          await startGame(); // Start a new game
        },
      );
      cleanupEndGameButtons();
      add(playAgainButton);
      await updateGameStateInFirebase();
      return true; // Exit the turn
    }
    return false;
  }

  bool checkPotIsRight(List<Player> players) {
    List<Player> activePlayers = players.where((p) => !p.isFolded!).toList();
    if (activePlayers.length == 1) {
      return true;
    }
    for (var player in activePlayers) {
      if (player.hasPlayedThisRound == false) {
        print('${player.name} has not played this round. Pot is not right.');
        return false; // If any player has not played this round, pot is not right
      }
      if (player.getCallAmount(gameRef) != 0) {
        print('${player.name} has not called yet. Pot is not right.');
        return false; // If any player has not called, pot is not right
      }
    }
    print('Pot is right!');
    return true;
  }

  Future<void> roundBasedDealing(int round) async {
    // Use the class member directly instead of searching for it
    for (var player in gameState.players) {
      player.hasPlayedThisRound =
          false; // Reset the played status for all players
    }
    await updateGameStateInFirebase();

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

          communityCardArea.addCard(
              card, i, gameRef); // Add the card to the community area
        }
        await updateGameStateInFirebase();
        break;
      case 2: // Turn
        print('Turn round, showing 1 community card.');
        gameState.deck.dealCard(); // Burn a card
        for (int i = 3; i < 4; i++) {
          PlayingCard card = gameState.deck.dealCard();
          gameState.communityCards.add(card);

          communityCardArea.addCard(
              card, i, gameRef); // Add the card to the community area
        }
        await updateGameStateInFirebase();
        break;
      case 3: // River
        print('River round, showing 1 community card.');
        gameState.deck.dealCard(); // Burn a card
        for (int i = 4; i < 5; i++) {
          PlayingCard card = gameState.deck.dealCard();
          gameState.communityCards.add(card);

          communityCardArea.addCard(
              card, i, gameRef); // Add the card to the community area
        }
        await updateGameStateInFirebase();
        break;
      case 4: // Showdown
        if (!gameState.isGameOver) {
          Player winner = determineWinner();
          winner.balance +=
              gameState.pot; // Add the pot to the winner's balance
          gameState.isGameOver = true; // Set the game state to over
          if (checkFolds() == gameState.players.length - 1) {
            print('${winner.name} wins by default!');
            winner.balance +=
                gameState.pot; // Add the pot to the winner's balance
          } else {
            print(
                '${winner.name} wins the game with a ${winner.hand.toString()}!');
          }

          // Show the play again button
          late final PlayNextRoundButton playAgainButton;
          playAgainButton = PlayNextRoundButton(
            spriteSrcPosition:
                Vector2(137 * 5, 48 * 5), // Replace with appropriate values
            spriteSrcSize:
                Vector2(80 * 5, 13 * 5), // Replace with appropriate values
            position: Vector2(gameRef.size.x * 3 / 4 + 15, gameRef.size.y / 2),
            spriteScale: 0.73,
            () async {
              remove(playAgainButton); // Remove the button from the screen
              await startGame(); // Start a new game
            },
          );
          cleanupEndGameButtons();
          add(playAgainButton);
          await updateGameStateInFirebase();
        }
        break;
      default:
        break; // End of game
    }
  }

  void cleanupEndGameButtons() {
    // Remove all PlayNextRoundButton instances
    children.whereType<PlayNextRoundButton>().toList().forEach((button) {
      remove(button);
    });
  }

  Player determineWinner() {
    List<Player> contenders =
        gameState.players.where((p) => !p.isFolded!).toList();

    if (contenders.length == 1) {
      print(
          '${contenders[0].name} is the only player left, they win by default!');
      return contenders[0]; // If only one player is left, they win by default
    }
    Player bestcontender = contenders.first;

    for (Player contender in contenders) {
      int result = comparePokerHands(
          hand1: bestcontender.convertHandToEvaluate(bestcontender.hand!),
          hand2: contender.convertHandToEvaluate(contender.hand!),
          communityCards:
              gameState.convertHandToEvaluate(gameState.communityCards));
      if (result == 1) {
        bestcontender = bestcontender;
      }
      if (result == -1) {
        bestcontender = contender;
      }
      if (result == 0) {
        // If hands are equal, compare balances
        if (contender.balance > bestcontender.balance) {
          bestcontender = contender;
        } else {
          bestcontender = bestcontender;
        }
      }
    }
    return bestcontender;
  }

  Future<int> showSlider() async {
    final completer = Completer<int>();
    int selectedValue =
        gameState.players[gameState.playerIndex].getCallAmount(gameRef);

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
                  minRaise: gameState.players[gameState.playerIndex]
                      .getCallAmount(gameRef),
                  maxRaise: gameState.players[gameState.playerIndex].balance,
                  balance: gameState.players[gameState.playerIndex].balance,
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
                        _sfxManager.playButtonSelect();
                        int bet = gameState.players[gameState.playerIndex]
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
                        _sfxManager.playButtonSelect();
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

// FIREBASE FUNCTIONS

  Future<void> updateGameStateInFirebase() async {
    if (isOffline) {
      return; // Skip Firebase update if offline
    }
    try {
      final jsonResult = gameState.toJson();
      await FirebaseFirestore.instance
          .collection('games')
          .doc('primary_game')
          .set(jsonResult);
      print("Game state updated in Firebase");
    } catch (e) {
      print("Error updating game state: $e");
    }
  }

  Future<void> loadUserCardSkin() async {
    final currentPlayerEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentPlayerEmail == null) {
      print('No current user email available');
      return;
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentPlayerEmail) // Use the email as the document ID
        .get();

    if (userDoc.exists) {
      bool ownMagicCardSkin = userDoc['ownMagicCardSkin'] ?? false;
      bool ownPokemonCardSkin = userDoc['ownPokemonCardSkin'] ?? false;

      if (ownMagicCardSkin) {
        cardSkinImage =
            'art/cards/Magic Card Back.png'; // Magic card skin image
      } else if (ownPokemonCardSkin) {
        cardSkinImage =
            'art/cards/Pokemon Card Back.png'; // Pokemon card skin image
      } else {
        cardSkinImage =
            'art/cards/Black Card Back.png'; // Default card skin image
      }

      print("flutter: Card skin loaded: $cardSkinImage");
    } else {
      print('flutter: User document not found.');
      cardSkinImage =
          'art/cards/Black Card Back.png'; // Default card skin if not found
    }
  }

  Future<void> loadUserTableSkin() async {
    // Get the current user's email
    final currentPlayerEmail = FirebaseAuth.instance.currentUser?.email;

    if (currentPlayerEmail == null) {
      print('No current user email available');
      return;
    }

    // Fetch the user's data from Firestore using the email as the document ID
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentPlayerEmail) // Use the email as the document ID
        .get();

    if (userDoc.exists) {
      // Retrieve the 'ownPurpleTableSkin' and 'ownRedTableSkin' values from the user's data
      bool ownPurpleTableSkin = userDoc['ownPurpleTableSkin'] ?? false;
      bool ownRedTableSkin = userDoc['ownRedTableSkin'] ?? false;

      // Choose the correct table image based on the user's purchases
      if (ownPurpleTableSkin) {
        tableSkinImage =
            'art/Purple Poker Table.png'; // Purple table skin image
      } else if (ownRedTableSkin) {
        tableSkinImage = 'art/Red Poker Table.png'; // Red table skin image
      } else {
        tableSkinImage = 'art/Base Poker Table.png'; // Default table image
      }

      print("flutter: Table skin loaded: $tableSkinImage");
    } else {
      print('flutter: User document not found.');
      tableSkinImage =
          'art/Base Poker Table.png'; // Default table skin if not found
    }
  }
}
