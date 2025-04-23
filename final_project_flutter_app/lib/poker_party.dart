import 'package:final_project_flutter_app/screens/game_screen.dart';
import 'package:final_project_flutter_app/screens/shop_screen.dart';
import 'package:final_project_flutter_app/src/game_state.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/camera.dart';

import 'screens/main_menu_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/support_screen.dart';

class PokerParty extends FlameGame {
  late CameraComponent cameraComponent = CameraComponent();
  late final RouterComponent router;
  late SpriteComponent background;

  final GameState gameState = GameState();

  final double _gameTimer = 0.0;
  final double _turnTimer = 0.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Setup a fixed resolution viewport
    cameraComponent = CameraComponent.withFixedResolution(
      width: 2570,
      height: 1190,
    );
    add(cameraComponent);

    // add(cameraComponent);
    /*
      Initializes the router component with an initial route and a map of routes.
      The initial route is 'menu', which will display the MainMenuScreen.
      Additional routes can be added as needed, such as 'rules' for the RulesScreen. Make
      sure that each screen is a Component, but that could be changed to widgets if we'd like
      later on.
    */
    router = RouterComponent(
      initialRoute: 'menu',
      routes: {
        'menu': Route(MainMenuScreen.new),
        'rules': Route(RulesScreen.new),
        'game': Route(GameScreen.new),
        'support': Route(SupportScreen.new),
        'shop': Route(ShopScreen.new),
      },
    );

    add(router);

    void goTo(String route) {
      router.pushNamed(route);
    }
  }
}
