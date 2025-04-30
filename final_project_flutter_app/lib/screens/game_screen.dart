import 'package:final_project_flutter_app/components/components.dart';
import 'package:final_project_flutter_app/config.dart';
import 'package:final_project_flutter_app/models/card.dart';
import 'package:final_project_flutter_app/models/player.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/game_state.dart';
import 'package:flame/components.dart';

class GameScreen extends Component with HasGameRef<PokerParty> {
  // This class will handle the game logic and UI for the game screen.
  // It will include methods to start the game, update the game state,
  // and render the game UI.

  List<ActionButton>? actionButtons;
  int playerIndex = 0;
  int dealerIndex = 0;
  late GameState gameState;

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

    print("Starting game...");
    gameState.initializePlayers();
    await startGame();
  }

  Future<void> startGame() async {
    gameState.resetGame();

    children.whereType<HandArea>().forEach(remove);
    children.whereType<CommunityCardArea>().forEach(remove);

    add(HandArea());
    add(CommunityCardArea());
    await dealCards();

    showCommunityCards(gameState.round);

    playerIndex = 0;
    await playerTurn();
  }

  Future<void> dealCards() async {
    gameState.deck.shuffleDeck();

    for (Player player in gameState.players) {
      player.receiveCard(gameState.deck.dealCard());
      player.receiveCard(gameState.deck.dealCard());

      if (!player.isAI) {
        updateHandUI(player, 0);
        updateHandUI(player, 1);
      }

      print("Community cards dealt: ${gameState.communityCards.toString()}");
      print(
          '${player.name} received cards: ${player.hand[0].toString()} and ${player.hand[1].toString()}');
    }
  }

  Future<void> nextPlayer() async {
    // move to next player
    playerIndex = (playerIndex + 1) % gameState.players.length;

    gameState.players[playerIndex].isCurrentTurn = true;

    if (playerIndex == dealerIndex) {
      gameState.round++;
      await showCommunityCards(gameState.round);
    }

    await playerTurn();
    print('Next player is ${gameState.players[playerIndex].name}');
  }

  Future<void> playerTurn() async {
    List<Player> playerList = gameRef.gameState.players;

    // Set the first player as current turn
    Player currentPlayer = playerList[playerIndex];

    // This method will be called to start the player's turn.
    // It will show the action buttons and wait for player input.
    if (currentPlayer.isFolded) {
      print('${currentPlayer.name} has folded. Skipping turn.');
      await nextPlayer(); // Skip to the next player if current player has folded
      return;
    }

    currentPlayer.isCurrentTurn = true; // Set current player turn to true
    if (currentPlayer.isAI) {
      // If it's an AI player's turn, handle AI logic here
      print('AI Player ${currentPlayer.name}\'s turn.');
      endRoundIfFolded(currentPlayer);
      currentPlayer.makeAIDecision();
      currentPlayer.isCurrentTurn = false; // End AI turn after decision
      endRoundIfFolded(currentPlayer);

      await nextPlayer(); // Move to the next player
    } else {
      showPlayerActions(currentPlayer);
      print('It is ${currentPlayer.name}\'s turn.');
    }
  }

  void showPlayerActions(Player player) {
    updateHandUI(player, 0); // Update the hand UI for the current player
    updateHandUI(player, 1); // Update the hand UI for the second card
    print('Showing player actions...');
    print('Current player: ${gameState.players[playerIndex].name}');

    // Set the base position for the first button
    Vector2 basePosition = Vector2(50, gameRef.size.y - 140);

    final double exportScale = 5; // your export scale factor

    // First button - Call button region from the spritesheet.
    final callButton = ActionButton(
      'Call',
      () async {
        if (player.isCurrentTurn) {
          print('${player.name} called!');
          player.call(gameState.bigBlind);
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
    add(callButton);

    // Second button - Fold button (adjust these coordinates as needed).
    final foldButton = ActionButton(
      'Fold',
      () async {
        if (player.isCurrentTurn) {
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
      () {
        // Raise action
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

  void updateHandUI(Player player, int index) {
    print('Updating hand UI for player: ${player.name}, card index: $index');
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
      gameState.isGameOver = true; // End the game
      return; // Exit the turn
    }
  }

  Future<void> showCommunityCards(int round) async {
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
        Player winnner = determineWinner();

        await startGame();
        break;
      default:
        print('Invalid round number: $round');
        break;
    }
  }

  Player determineWinner() {
    Player pLACEHOLDERWINNER = gameState.players[0];
    return pLACEHOLDERWINNER;
  }
}
