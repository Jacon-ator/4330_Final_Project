import 'package:final_project_flutter_app/poker_party.dart';
import 'package:flame/components.dart';

class InfoButton extends SpriteComponent with HasGameRef<PokerParty> {
  InfoButton() : super(priority: 1);

  @override
  Future<void> onLoad() async {
    sprite = Sprite(
      game.images.fromCache('Master Button Sheet.png'),
      srcPosition: Vector2(170, 0),
      srcSize: Vector2(13, 12),
    );
  }

  void handleTap(Vector2 tapPosition) {
    if (toRect().contains(tapPosition.toOffset())) {
      gameRef.router.pushNamed('rules');
    }
  }
}

