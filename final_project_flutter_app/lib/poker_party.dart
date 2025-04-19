import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'screens/main_menu_screen.dart';
import 'screens/rules_screen.dart';
import 'src/components/components.dart';

class PokerParty extends FlameGame {
  late final RouterComponent router;
  late SpriteComponent background;

  /* This implementation will probably be changed or deleted, just messing around
     and trying to get an image to be drawn in the window. Just wanted to get basic 
     drawing of sprites and flame syntax working
  */

  @override
  Future<void> onLoad() async {
    super.onLoad();

    router = RouterComponent(
      initialRoute: 'menu',
      routes: {
        'menu': Route(MainMenuScreen.new),

        'rules': Route(RulesScreen.new),
        // 'profile': Route(() => ProfilePage()),
      },
    );

    add(router);

    // Adds button to screen
    add(MainMenuButton());

    void goTo(String route) {
      router.pushNamed(route);
    }
  }
}
