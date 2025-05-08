import 'dart:async';

import 'package:final_project_flutter_app/components/buttons/menu/start_match_button.dart';
import 'package:final_project_flutter_app/components/components.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/lobby_screen_service.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LobbyScreen extends Component with HasGameRef<PokerParty> {
  late TextComponent titleComponent;
  late TextComponent playersComponent;
  int playerCount = 0;

  final LobbyScreenService _lobbyService = LobbyScreenService();
  StreamSubscription<int>? _playerCountSubscription;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Setup stream subscription for player count
    _playerCountSubscription =
        _lobbyService.streamPlayerCount().listen((count) {
      playerCount = count;
      updatePlayerCount();
    });

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

    final MainMenuButton mainMenuButton = MainMenuButton()
      ..size = Vector2(gameRef.size.x / 6, gameRef.size.y / 6)
      ..position = Vector2(
          gameRef.size.x / 2 - gameRef.size.x / 12, gameRef.size.y * 0.65);

    add(mainMenuButton);
  }

  @override
  void onRemove() {
    // Clean up the subscription when the component is removed
    super.onRemove();
    updatePlayerCount();
  }

  // Also add a method to unsubscribe when leaving the lobby
  Future<void> leaveLobby() async {
    await _lobbyService.removeFromLobby(gameRef);
    _playerCountSubscription?.cancel();
  }

  void updatePlayerCount() {
    playersComponent.text = 'Players: $playerCount/4';
    children.whereType<StartMatchButton>().forEach((button) {
      button.playerCount = playerCount;
    });
  }
}
