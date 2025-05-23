import 'dart:async';

import 'package:final_project_flutter_app/components/buttons/menu/add_bot_button.dart';
import 'package:final_project_flutter_app/components/buttons/menu/remove_bot_button.dart';
import 'package:final_project_flutter_app/components/buttons/menu/start_match_button.dart';
import 'package:final_project_flutter_app/components/components.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/game_state.dart';
import 'package:final_project_flutter_app/services/lobby_screen_service.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LobbyScreen extends Component with HasGameRef<PokerParty> {
  late TextComponent titleComponent;
  late TextComponent titleComponentFill;
  late TextComponent playersComponent, playersComponentFill;
  late Vector2 size;
  int playerCount = 0;

  late RemoveBotButton removeBotButton;

  final LobbyScreenService _lobbyService = LobbyScreenService();
  StreamSubscription<int>? _playerCountSubscription;
  StreamSubscription<GameState>? _gameStateSubscription;
  bool _navigatingToGame = false;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;

    // Ensure we start with a clean state
    resetLobby();

    // Set the initial player count based on the actual number of players
    playerCount = gameRef.gameState.players.length;
    print("Initial player count: $playerCount");

    // Force an update of the player count display after a short delay to ensure it's rendered
    Future.delayed(const Duration(milliseconds: 100), () {
      updatePlayerCount();
    });

    // Setup stream subscription for player count
    _playerCountSubscription =
        _lobbyService.streamPlayerCount().listen((count) {
      playerCount = count;
      updatePlayerCount();
    });

    // Setup stream subscription for game state to watch isLobbyActive
    _gameStateSubscription =
        _lobbyService.streamGameState().listen((gameState) {
      if (gameState.isLobbyActive && !_navigatingToGame) {
        _navigatingToGame = true; // Prevent multiple navigations
        print("Game is now active! Navigating to game screen...");
        _navigateToGameScreen();
      }
    });

    // Load background
    final rulesBackground = await Sprite.load('art/Lobby Screen.png');
    add(SpriteComponent(
      sprite: rulesBackground,
      size: size, // Make the image fill the screen
      position: Vector2(0, 0),
    ));

    // Add title
    titleComponent = TextComponent(
      text: 'Game Lobby',
      textRenderer: TextPaint(
        style: TextStyle(
          fontFamily: 'RedAlert',
          fontSize: 104,
          fontWeight: FontWeight.bold,
          foreground: Paint()
            ..style = PaintingStyle.stroke // Set to stroke
            ..strokeWidth = 7 // Adjust outline thickness as needed
            ..color = const Color.fromARGB(230, 118, 161, 93),
        ),
      ),
    );
    titleComponent.position = Vector2(
      gameRef.size.x / 2 - titleComponent.width / 2,
      gameRef.size.y * 0.15,
    );

    titleComponentFill = TextComponent(
      text: 'Game Lobby',
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: 'RedAlert',
          color: Color.fromARGB(255, 70, 130, 50),
          fontSize: 104,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    titleComponentFill.position = Vector2(
      gameRef.size.x / 2 - titleComponentFill.width / 2,
      gameRef.size.y * 0.15,
    );
    add(titleComponent);
    add(titleComponentFill);

    String playerCountText = 'Players: $playerCount/4';
    // Add player counter
    playersComponent = TextComponent(
      text: playerCountText,
      textRenderer: TextPaint(
        style: TextStyle(
          fontFamily: 'RedAlert',
          fontSize: 64,
          foreground: Paint()
            ..style = PaintingStyle.stroke // Set to stroke
            ..strokeWidth = 7 // Adjust outline thickness as needed
            ..color = const Color.fromARGB(230, 118, 161, 93),
        ),
      ),
    );
    playersComponent.position = Vector2(
      gameRef.size.x / 2 - playersComponent.width / 2,
      gameRef.size.y * 0.3,
    );
    add(playersComponent);

    // Force a position update after adding to ensure correct positioning
    playersComponent.position = Vector2(
      gameRef.size.x / 2 - playersComponent.width / 2,
      gameRef.size.y * 0.3,
    );

    // Add Bot button
    final addBotButton = AddBotButton(
      position: Vector2(gameRef.size.x / 2 - 210, gameRef.size.y * 0.45),
      onTap: addBot,
    );
    add(addBotButton);

    // Remove Bot button
    removeBotButton = RemoveBotButton(
      position: Vector2(gameRef.size.x / 2 + 10, gameRef.size.y * 0.45),
      onTap: removeBot,
      isEnabled: playerCount > 1, // Only enable if there are bots to remove
    );
    add(removeBotButton);

    playersComponentFill = TextComponent(
      text: playerCountText,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: 'RedAlert', // pixel font
          fontSize: 64,
          color: Color.fromARGB(255, 70, 130, 50), // Fill color
        ),
      ),
    );
    playersComponentFill.position = Vector2(
      gameRef.size.x / 2 - playersComponent.width / 2,
      gameRef.size.y * 0.3,
    );
    add(playersComponentFill);

    // Add start match button - positioned halfway between bot buttons and bottom
    final startMatchButton = StartMatchButton(
      playerCount: playerCount,
      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.65),
    );
    add(startMatchButton);
    
    // Force button to respect its position after adding
    startMatchButton.position = Vector2(gameRef.size.x / 2, gameRef.size.y * 0.65);

    // Adjusted main menu button position to be at the bottom of the screen
    final MainMenuButton mainMenuButton = MainMenuButton()
      ..size = Vector2(gameRef.size.x / 6, gameRef.size.y / 6)
      ..position = Vector2(
          gameRef.size.x / 2 - gameRef.size.x / 12, gameRef.size.y * 0.8);

    add(mainMenuButton);
  }

  // Method to navigate to game screen
  void _navigateToGameScreen() {
    Future.delayed(const Duration(milliseconds: 500), () {
      gameRef.router.pushNamed('game');
    });
  }

  @override
  void onRemove() {
    super.onRemove();
    // Reset game state when leaving the lobby
    resetLobby();
    _playerCountSubscription?.cancel();
    _gameStateSubscription?.cancel();
  }

  // Method to unsubscribe when leaving the lobby
  Future<void> leaveLobby() async {
    await _lobbyService.removeFromLobby();
    _playerCountSubscription?.cancel();
    _gameStateSubscription?.cancel();
    resetLobby();
  }

  // Reset the lobby state
  void resetLobby() {
    // Clear all players except the human player
    if (gameRef.gameState.players.isNotEmpty) {
      // Find the human player
      Player? humanPlayer;
      for (var player in gameRef.gameState.players) {
        if (player.isAI != true) {
          humanPlayer = player;
          break;
        }
      }

      // Clear all players
      gameRef.gameState.players.clear();

      // Add back just the human player if found
      if (humanPlayer != null) {
        gameRef.gameState.players.add(humanPlayer);
      } else {
        // Create a new human player if none was found
        Player newHumanPlayer = Player(
          id: "player_1",
          name: "Player_1",
          balance: 1000,
          isAI: false,
          isCurrentTurn: false,
          hasPlayedThisRound: false,
          isFolded: false,
          handRank: null,
          isAllIn: false,
        );
        gameRef.gameState.players.add(newHumanPlayer);
      }

      // Reset game state
      gameRef.gameState.isLobbyActive = false;
      gameRef.gameState.isGameOver = false;

      // Update the player count to match the actual number of players (should be 1)
      playerCount = gameRef.gameState.players.length;

      print(
          "Lobby reset: All bots removed, only human player remains. Player count: $playerCount");
    } else {
      // If no players exist, create a human player
      Player newHumanPlayer = Player(
        id: "player_1",
        name: "Player_1",
        balance: 1000,
        isAI: false,
        isCurrentTurn: false,
        hasPlayedThisRound: false,
        isFolded: false,
        handRank: null,
        isAllIn: false,
      );
      gameRef.gameState.players.add(newHumanPlayer);

      // Set player count to 1
      playerCount = 1;

      print("Created new human player. Player count: $playerCount");
    }
  }

  void updatePlayerCount() {
    // Ensure player count matches the actual number of players in the game state
    playerCount = gameRef.gameState.players.length;

    // Update the display
    String playerCountText = 'Players: $playerCount/4';
    playersComponent.text = playerCountText;
    playersComponentFill.text = playerCountText;

    // Update start match button
    children.whereType<StartMatchButton>().forEach((button) {
      button.playerCount = playerCount;
    });

    // Update remove bot button state
    removeBotButton.setEnabled(playerCount > 1);

    print("Updated player count: $playerCount");
  }

  void addBot() {
    // Check if we can add more bots (max 4 players total)
    if (gameRef.gameState.players.length <
        gameRef.gameState.table.totalCapacity) {
      // Create a new AI player
      int botIndex = gameRef.gameState.players.length;
      Player botPlayer = Player(
        id: "ai_$botIndex",
        name: "AI_Player_$botIndex",
        balance: 1000,
        isAI: true,
        isCurrentTurn: false,
        hasPlayedThisRound: false,
        isFolded: false,
        handRank: null,
        isAllIn: false,
      );

      // Add the bot to the game state
      gameRef.gameState.players.add(botPlayer);

      // Update player count
      playerCount = gameRef.gameState.players.length;
      updatePlayerCount();

      print("Added bot: ${botPlayer.name}");
    } else {
      print("Cannot add more bots. Table is full.");
    }
  }

  void removeBot() {
    // Check if there are any bots to remove (keep at least 1 player - the human)
    if (gameRef.gameState.players.length > 1) {
      // Find the last bot in the list
      for (int i = gameRef.gameState.players.length - 1; i >= 0; i--) {
        if (gameRef.gameState.players[i].isAI == true) {
          // Remove this bot
          Player removedBot = gameRef.gameState.players.removeAt(i);
          print("Removed bot: ${removedBot.name}");
          break;
        }
      }

      // Update player count
      playerCount = gameRef.gameState.players.length;
      updatePlayerCount();
    } else {
      print("No bots to remove. At least one player is required.");
    }
  }
}
