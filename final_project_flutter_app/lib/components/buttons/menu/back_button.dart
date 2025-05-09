import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/lobby_screen_service.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class BackButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  final LobbyScreenService lobbyScreenService = LobbyScreenService();

  BackButton({
    required Vector2 position,
  }) : super(position: position, size: Vector2(100, 40));

  @override
  Future<void> onLoad() async {
    // Add a background for the button
    final buttonBackground = RectangleComponent(
      size: size,
      paint: Paint()..color = Color(0xFF303030),
    );
    add(buttonBackground);

    // Add text to the button
    final textComponent = TextComponent(
      text: 'Back',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );
    textComponent.position = Vector2(
      size.x / 2 - textComponent.width / 2,
      size.y / 2 - textComponent.height / 2,
    );
    add(textComponent);
  }

  @override
  Future<void> onTapDown(TapDownEvent event) async {
    super.onTapDown(event);
    await lobbyScreenService.removeFromLobby();
    gameRef.router.pop();
  }
}
