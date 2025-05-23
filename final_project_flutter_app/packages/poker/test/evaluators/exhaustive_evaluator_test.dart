import 'package:poker/src/evaluators/evaluator.dart';
import 'package:poker/src/evaluators/exhaustive_evaluator.dart';
import 'package:poker/src/models/hand_range.dart';
import 'package:poker/src/models/immutable_card_set.dart';
import 'package:test/test.dart';

void main() {
  group("ExhaustiveEvaluator", () {
    test("ExhaustiveEvaluator iterates Matchups", () {
      final evaluator = ExhaustiveEvaluator(
        communityCards: ImmutableCardSet.parse("3c6dTs"),
        players: [
          HandRange.parse("As3h"),
          HandRange.parse("8d8h"),
          HandRange.parse("AQs-ATsAKo-AJo44+"),
        ],
      );

      int length = 0;
      List<int> wins = [0, 0, 0];
      for (final matchup in evaluator) {
        for (final i in matchup.wonPlayerIndexes) {
          wins[i] += 1;
        }

        length += 1;
      }

      expect(length, equals(158928));
      expect(wins, equals([25412, 71028, 63894]));
    });

    test(
        "ExhaustiveEvaluator throws NoPossibleCombinationException when it found there's no possible combination while it iterates",
        () {
      final evaluator = ExhaustiveEvaluator(
        communityCards: ImmutableCardSet.parse("3c6dAs"),
        players: [
          HandRange.parse("AA"),
          HandRange.parse("AKs"),
          HandRange.parse("AJo+"),
        ],
      );

      expect(
        () => evaluator.take(1),
        throwsA(isA<NoPossibleCombinationException>()),
      );
    });
  });
}
