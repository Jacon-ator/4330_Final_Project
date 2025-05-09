import 'package:final_project_flutter_app/config.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/lobby_screen_service.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

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
    // Add a background for the button
    final buttonBackground = RectangleComponent(
      size: size,
      paint: Paint()..color = Color(0xFF104810),
    );
    add(buttonBackground);

    // Add text to the button
    textComponent = TextComponent(
      text: 'Start Match',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    textComponent.position = Vector2(
      size.x / 2 - textComponent.width / 2,
      size.y / 2 - textComponent.height / 2,
    );
    add(textComponent);
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
