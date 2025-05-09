import 'package:final_project_flutter_app/config.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/lobby_screen_service.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';

class StartMatchButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  int playerCount;
  late TextComponent textComponent;

  StartMatchButton({
    required this.playerCount,
    required Vector2 position,
  }) : super(position: position, size: Vector2(200, 60));

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // It's good practice to call super.onLoad()
    Sprite?
        loadedSprite; // Renamed to avoid confusion with the SpriteComponent's sprite property
    double exportScale = 5; // Adjust this value based on your export scale

    final image =
        await gameRef.images.load("art/buttons/Master Button Sheet.png");
    loadedSprite = Sprite(
      image,
      srcPosition: Vector2(69 * exportScale,
          62 * exportScale), // multiplied original coordinates
      srcSize: Vector2(335, 65), // change width and height as needed
    );

    size = loadedSprite.srcSize; // Set the size of the StartMatchButton
    anchor = Anchor.center;
    // Don't override the position that was set in the constructor

    // Create a SpriteComponent and add it as a child
    final spriteComponent = SpriteComponent(
      sprite: loadedSprite,
      size: size, // Make the SpriteComponent the same size as the button
    );
    add(spriteComponent);
  }

  // In StartMatchButton class
  @override
  Future<void> onTapUp(TapUpEvent event) async {
    super.onTapUp(event);
    if (isOffline) {
      gameRef.router.pushNamed("game");
    } else {
      final lobbyService = LobbyScreenService();

      // Start the lobby which will set isLobbyActive=true
      await lobbyService.startLobby();
    }
  }
}
