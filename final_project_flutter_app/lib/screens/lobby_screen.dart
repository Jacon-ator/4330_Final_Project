import 'package:final_project_flutter_app/components/buttons/menu/back_button.dart'
    as backbutton;
import 'package:final_project_flutter_app/components/buttons/menu/start_match_button.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LobbyScreen extends Component with HasGameRef<PokerParty> {
  late TextComponent titleComponent;
  late TextComponent playersComponent;
  int playerCount = 1; // Start with 1 player (the human player)

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Load background
    final background = RectangleComponent(
        size: gameRef.size, paint: Paint()..color = const Color(0xFF1E6C3C));

    add(background);

    // Add title
    titleComponent = TextComponent(
      text: 'Game Lobby',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    titleComponent.position = Vector2(
      gameRef.size.x / 2 - titleComponent.width / 2,
      gameRef.size.y * 0.15,
    );
    add(titleComponent);

    // Add player counter
    playersComponent = TextComponent(
      text: 'Players: $playerCount/4',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
        ),
      ),
    );
    playersComponent.position = Vector2(
      gameRef.size.x / 2 - playersComponent.width / 2,
      gameRef.size.y * 0.3,
    );
    add(playersComponent);

    // Add start match button
    final startMatchButton = StartMatchButton(
      playerCount: playerCount,
      position: Vector2(gameRef.size.x / 2 - 100, gameRef.size.y * 0.7),
    );
    add(startMatchButton);

    // Add back button
    final backButton = backbutton.BackButton(
      position: Vector2(50, gameRef.size.y - 50),
    );
    add(backButton);
  }

  void updatePlayerCount() {
    playersComponent.text = 'Players: $playerCount/4';
    children.whereType<StartMatchButton>().forEach((button) {
      button.playerCount = playerCount;
    });
  }
}
