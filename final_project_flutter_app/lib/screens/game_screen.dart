import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/src/components/card_component.dart';
import 'package:final_project_flutter_app/src/components/components.dart';
import 'package:final_project_flutter_app/src/components/hand_area.dart';
import 'package:flame/components.dart';

class GameScreen extends Component with HasGameRef<PokerParty> {
  // This class will handle the game logic and UI for the game screen.
  // It will include methods to start the game, update the game state,
  // and render the game UI.

  List<ActionButton>? actionButtons;
  bool waitingForPlayerInput = false;
  int playerIndex = 0;

  void showPlayerActions() {
    waitingForPlayerInput = true;
    print('Showing player actions...');
    print('Current player: ${gameRef.gameState.players[playerIndex].name}');

    add(ActionButton('Call', () {
      if (gameRef.gameState.players[playerIndex].isCurrentTurn) {
        gameRef.gameState.players[playerIndex]
            .call(gameRef.gameState.players[playerIndex].bet); // Call the bet
        print('Player ${gameRef.gameState.players[playerIndex].name} called.');
        nextPlayer(); // Move to the next player
        playerTurn(); // Start the next player's turn
      } else {
        print('It is not your turn!');
      }
    }, Colors.green));
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    //load all images
    try {
      await gameRef.images.load('art/cards/Cards Mock Up.png');
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
    await startGame();
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
      position: Vector2.zero(), // Position will be determined by HandArea
      imagePath: '',
    );

    // Add the card to the HandArea instead of directly to the screen
    handArea.addCard(player, cardComponent, index, gameRef);
  }

  Future<void> startGame() async {
    gameRef.gameState.resetGame(); // Reset the game state
    gameRef.gameState.initializePlayers([
      'Player 1', // Human player
      'AI Player 1', // AI player
      'AI Player 2', // AI player
      'AI Player 3' // AI player
    ]);
    add(HandArea());
    await dealCards(); // Deal cards to players
  }

  Future<void> dealCards() async {
    // Shuffle the deck before dealing cards
    for (Player player in gameRef.gameState.players) {
      player.receiveCard(
          gameRef.gameState.deck.dealCard()); // Deal one card to each player
      updateHandUI(player, 0);
      // await Future.delayed(Duration(milliseconds: 500)); // Delay for better UX
      player.receiveCard(gameRef.gameState.deck.dealCard());
      updateHandUI(player, 1); // Deal one card to each player
      // await Future.delayed(Duration(milliseconds: 500)); // Delay for better UX
      print(
          'Player ${player.name} received cards: ${player.hand[0].toString()} and ${player.hand[1].toString()}');
    }
  }

  void nextPlayer() {
    playerIndex = (playerIndex + 1) %
        gameRef.gameState.players.length; // Move to the next player
    gameRef.gameState.players[playerIndex].isCurrentTurn =
        true; // Set the next player as current turn
  }

  void playerTurn() {
    List<Player> playerList = gameRef
        .gameState.players; // Get the list of players from the game state
    playerList[playerIndex].isCurrentTurn = true;
    Player currentPlayer =
        playerList[playerIndex]; // Set the first player as current turn
    // This method will be called to start the player's turn.
    // It will show the action buttons and wait for player input.
    if (currentPlayer.isAI) {
      // If it's an AI player's turn, handle AI logic here
      currentPlayer.makeAIDecision();
      currentPlayer.isCurrentTurn = false; // End AI turn after decision
      nextPlayer(); // Move to the next player
    } else
      showPlayerActions();
  }
}
