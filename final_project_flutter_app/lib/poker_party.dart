import 'package:final_project_flutter_app/screens/game_screen.dart';
import 'package:final_project_flutter_app/src/game_state.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'screens/main_menu_screen.dart';
import 'screens/rules_screen.dart';
import 'src/components/components.dart';

class PokerParty extends FlameGame {
  late final RouterComponent router;
  late SpriteComponent background;

  final GameState gameState = GameState();

  double _gameTimer = 0.0;
  double _turnTimer = 0.0;

  @override
  Future<void> onLoad() async {
    super.onLoad();

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
      },
    );

    add(router);

    void goTo(String route) {
      router.pushNamed(route);
    }
  }
}
