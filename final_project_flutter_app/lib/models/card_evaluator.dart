import 'package:final_project_flutter_app/models/card.dart';

enum HandRank {
  highCard,
  onePair,
  twoPair,
  threeOfAKind,
  straight,
  flush,
  fullHouse,
  fourOfAKind,
  straightFlush,
}
//use the poker package to evaluate the hand

class CardEvaluator {
  // List<PlayingCard> cards = [];

  // void evaluateHand(List<PlayingCard> communityCards, List<Player> players) {
  //   // Convert PlayingCard to poker.Card
  //   //turn the list of PlayingCards into ImmutableCardSet
  //   List<poker.Card> pokerCommunityCards =
  //       communityCards.map((card) => card.toPokerCard()).toList();

  //   Set<poker.CardPair> playerHands = {};
  //   List<poker.HandRange> handRanges = [];
  //   for (Player player in players) {
  //     // Convert PlayingCard to poker.CardPair
  //     poker.CardPair pair = poker.CardPair(
  //         player.hand[0].toPokerCard(), player.hand[1].toPokerCard());
  //     playerHands.add(pair);
  //     handRanges.add(poker.HandRange(playerHands));
  //     playerHands.clear();
  //   }
  //   poker.ImmutableCardSet commCards =
  //       poker.ImmutableCardSet.from(pokerCommunityCards);

  //   // Use the poker package to evaluate the hand
  //   var result = poker.ExhaustiveEvaluator(
  //           communityCards: commCards, players: handRanges)
  //       .evaluate();

  //   // Return the rank of the hand
  //   return result.rank.index;
  // }

  // Create my own evaluator

  HandRank evaluateHand(List<PlayingCard> hand) {
    assert(hand.length == 5);

    final ranks = hand.map((c) => c.rank).toList()..sort();
    final suits = hand.map((c) => c.suit).toList();

    final rankCounts = <int, int>{};
    for (var r in ranks) {
      rankCounts[r] = (rankCounts[r] ?? 0) + 1;
    }

    final isFlush = suits.toSet().length == 1;
    final isStraight = () {
      for (int i = 1; i < ranks.length; i++) {
        if (ranks[i] != ranks[i - 1] + 1) return false;
      }
      return true;
    }();

    if (isStraight && isFlush) return HandRank.straightFlush;
    if (rankCounts.containsValue(4)) return HandRank.fourOfAKind;
    if (rankCounts.containsValue(3) && rankCounts.containsValue(2))
      return HandRank.fullHouse;
    if (isFlush) return HandRank.flush;
    if (isStraight) return HandRank.straight;
    if (rankCounts.containsValue(3)) return HandRank.threeOfAKind;
    if (rankCounts.values.where((v) => v == 2).length == 2)
      return HandRank.twoPair;
    if (rankCounts.containsValue(2)) return HandRank.onePair;

    return HandRank.highCard;
  }

  HandRank bestOfSeven(List<PlayingCard> cards) {
    assert(cards.length == 7);
    HandRank best = HandRank.highCard;

    // Try all 5-card combinations (21 in total)
    for (int i = 0; i < cards.length; i++) {
      for (int j = i + 1; j < cards.length; j++) {
        final fiveCardHand = [
          for (int k = 0; k < cards.length; k++)
            if (k != i && k != j) cards[k]
        ];
        final rank = evaluateHand(fiveCardHand);
        if (rank.index > best.index) {
          best = rank;
        }
      }
    }

    return best;
  }
}
