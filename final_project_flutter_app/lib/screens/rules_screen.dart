import 'package:final_project_flutter_app/components/components.dart';
import 'package:flame/components.dart';

class RulesScreen extends Component with HasGameRef {
  late Vector2 size;
  @override
  Future<void> onLoad() async {
    size = gameRef.size;
    super.onLoad();

    // Load the background image
    final rulesBackground = await Sprite.load(
        'art/Rules Page.png'); // Assuming the image is named 'rules_page.png' and is in the assets/images folder
    add(SpriteComponent(
      sprite: rulesBackground,
      size: size, // Make the image fill the screen
      position: Vector2(0, 0),
    ));

    final MainMenuButton mainMenuButton = MainMenuButton()
      ..size = Vector2(size.x / 6, size.y / 6)
      ..position = Vector2(size.x / 2 - size.x / 12, size.y * 0.8);

    add(mainMenuButton);
  }
}
