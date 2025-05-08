import 'package:final_project_flutter_app/poker_party.dart';
import 'package:final_project_flutter_app/services/lobby_screen_service.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends PositionComponent
    with TapCallbacks, HasGameRef<PokerParty> {
  final LobbyScreenService lobbyScreenService = LobbyScreenService();
  Sprite? sprite;
  @override
  Future<void> onLoad() async {
    double exportScale = 5;
    await super.onLoad();
    final image = await gameRef.images.load("art/Player Cards.png");
    sprite = Sprite(
      image,
      srcPosition: Vector2(
          0 * exportScale, 0 * exportScale), // multiplied original coordinates
      srcSize: Vector2(20 * exportScale,
          27 * exportScale), // change width and height as needed
    );

    if (sprite != null) {
      size = sprite!.srcSize;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (sprite != null) {
      sprite!.renderRect(canvas, size.toRect());
    }
  }
}
