import 'package:final_project_flutter_app/audio/audio_manager.dart';
import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/screens/game_screen.dart';
import 'package:final_project_flutter_app/screens/lobby_screen.dart';
import 'package:final_project_flutter_app/screens/shop_screen.dart';
import 'package:final_project_flutter_app/services/game_state.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'screens/main_menu_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/support_screen.dart';

class PokerParty extends FlameGame {
  late CameraComponent cameraComponent = CameraComponent();
  late final RouterComponent router;
  late SpriteComponent background;

  final AudioManager audioManager = AudioManager();
  bool _audioInitialized = false;

  late GameState gameState = GameState();

  final double _gameTimer = 0.0;
  final double _turnTimer = 0.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Initialize audio only if not already initialized
    if (!_audioInitialized) {
      await audioManager.initialize();
      await audioManager.playMainTheme();
      _audioInitialized = true;
    }

    // Initialize SFX
    print('[SFX] Initializing SFX in PokerParty...');
    await SFXManager().initialize();
    print('[SFX] SFX initialized in PokerParty');

    // Setup a fixed resolution viewport
    cameraComponent = CameraComponent.withFixedResolution(
      width: 2570,
      height: 1190,
    );
    add(cameraComponent);
    cameraComponent.viewfinder.anchor = Anchor.center;

    // add(cameraComponent);
    /*
      Initializes the router component with an initial route and a map of routes.
      The initial route is 'menu', which will display the MainMenuScreen.
      Additional routes can be added as needed, such as 'rules' for the RulesScreen. Make
      sure that each screen is a Component, but that could be changed to widgets if we'd like
      later on.
    */
    router = RouterComponent(
      initialRoute: 'menu',
      routes: {
        'menu': Route(MainMenuScreen.new),
        'lobby': Route(LobbyScreen.new),
        'rules': Route(RulesScreen.new),
        'game': Route(GameScreen.new),
        'support': Route(SupportScreen.new),
        'shop': Route(ShopScreen.new),
      },
    );

    add(router);
  }

  void goTo(String route) async {
    print('Navigating to route: $route');

    // Reset game state when going back to main menu
    if (route == 'menu') {
      resetGameState();
    }
    
    // Handle theme switching based on route
    switch (route) {
      case 'shop':
        print('Switching to shop theme');
        await audioManager.playShopTheme();
        print('Shop theme started successfully');
        break;
      case 'menu':
        print('Switching to main theme');
        await audioManager.playMainTheme();
        print('Main theme started successfully');
        break;
      case 'game':
        print('Switching to in-play theme');
        await audioManager.playInPlayTheme();
        print('In-play theme started successfully');
        break;
      case 'lobby':
        // For lobby, ensure game state is clean
        resetGameState();
        print('Preparing lobby with clean state');
        break;
      default:
        // For other routes (rules, support), keep the current theme
        print('No theme change for route: $route');
        break;
    }

    // For lobby route, completely rebuild it by removing and re-adding it
    if (route == 'lobby') {
      // First remove any existing lobby screen
      router.routes.remove('lobby');
      // Re-add the lobby route
      router.routes['lobby'] = Route(() => LobbyScreen());
      print('Lobby screen route rebuilt');
    }

    // Only change route after audio is set up
    router.pushNamed(route);
  }
  
  // Reset the game state to initial values
  void resetGameState() {
    print('Resetting game state');
    
    // Reset game state flags
    gameState.isLobbyActive = false;
    gameState.isGameOver = false;
    
    // Keep only the human player
    if (gameState.players.isNotEmpty) {
      // Find the human player
      Player? humanPlayer;
      for (var player in gameState.players) {
        if (player.isAI != true) {
          humanPlayer = player;
          break;
        }
      }
      
      // Clear all players
      gameState.players.clear();
      
      // Add back just the human player if found
      if (humanPlayer != null) {
        // Reset player state
        humanPlayer.resetHand();
        humanPlayer.isCurrentTurn = false;
        humanPlayer.hasPlayedThisRound = false;
        humanPlayer.isFolded = false;
        humanPlayer.isAllIn = false;
        
        gameState.players.add(humanPlayer);
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
        gameState.players.add(newHumanPlayer);
      }
      
      print("Game state reset: All bots removed, only human player remains. Player count: ${gameState.players.length}");
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
      gameState.players.add(newHumanPlayer);
      
      print("Created new human player. Player count: ${gameState.players.length}");
    }
    
    // Reset other game state variables
    gameState.pot = 0;
    gameState.round = 0;
    gameState.communityCards = [];
    gameState.deck.resetDeck();
  }

  @override
  void onRemove() async {
    await audioManager.stopAll();
    super.onRemove();
  }

  int getCurrentPlayerBalance() {
    // Assuming you have a method to get the current player
    Player currentPlayer = gameState.getCurrentPlayer();
    return currentPlayer.balance;
  }
}
