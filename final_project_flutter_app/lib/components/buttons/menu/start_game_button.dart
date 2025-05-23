import 'package:final_project_flutter_app/audio/sfx_manager.dart';
import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/database_service.dart';
import 'package:final_project_flutter_app/services/lobby_screen_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class StartGameButton extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  final String label = 'Single';
  final SFXManager _sfxManager = SFXManager();
  final LobbyScreenService lobbyScreenService = LobbyScreenService();

  StartGameButton({label});
  Sprite? sprite;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    double exportScale = 5; // Adjust this value based on your export scale
    double yPositionOffset = 75; // Adjust this value based on your export scale

    final image =
        await gameRef.images.load("art/buttons/Master Button Sheet.png");
    sprite = Sprite(
      image,
      srcPosition: Vector2(137 * exportScale,
          76 * exportScale), // multiplied original coordinates
      srcSize: Vector2(335, 65), // change width and height as needed
    );

    // Optionally, adjust the size based on your asset's dimensions.
    if (sprite != null) {
      size = sprite!.srcSize;

      position = Vector2(
        gameRef.size.x / 2 - size.x / 2,
        (gameRef.size.y / 2 - size.y / 2) + yPositionOffset,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (sprite != null) {
      sprite!.renderRect(canvas, size.toRect());
    }
  }

  @override
  Future<void> onTapDown(TapDownEvent event) async {
    final userData = await DatabaseService().getUserData();

    if (userData != null || FirebaseAuth.instance.currentUser == null) {
      super.onTapDown(event);
      _sfxManager.playButtonSelect();
      // Navigate to the lobby screen when the button is tapped
      bool success = await lobbyScreenService.addToLobby();
      if (success) {
        gameRef.router.pushNamed('lobby');
      } else {
        print("Failed to add player to lobby.");
      }
    } else {
      print("User data is null. Cannot start game.");
    }
  }
}
