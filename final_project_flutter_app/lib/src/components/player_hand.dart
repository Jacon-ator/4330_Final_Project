import 'package:final_project_flutter_app/src/components/card_component.dart';
import 'package:final_project_flutter_app/src/config.dart';
import 'package:flame/components.dart';

class PlayerHand extends PositionComponent {
  PlayerHand({
    super.position,
  }) : super(size: Vector2(cardWidth, cardHeight));

  final List<CardComponent> _cards = [];

  void addCard(CardComponent card) {
    assert(_cards.length <= 2, "Cannot add more than 2 cards to the hand.");
    card.position = position;
    _cards.add(card);
  }
}
