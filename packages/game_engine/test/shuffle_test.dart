import 'dart:math';

import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'shuffle',
    () {
      test('shuffles in place, keeping the same list instance', () {
        final items = [1, 2, 3, 4, 5];

        shuffle(items, Random(0));

        expect(items, same(items));
      });

      test('preserves the same elements', () {
        final items = [1, 2, 3, 4, 5];

        shuffle(items, Random(0));

        expect(items, unorderedEquals([1, 2, 3, 4, 5]));
      });

      test('produces the same order for the same seed', () {
        final first = [1, 2, 3, 4, 5];
        final second = [1, 2, 3, 4, 5];

        shuffle(first, Random(42));
        shuffle(second, Random(42));

        expect(first, second);
      });

      test('produces a different order for a different seed', () {
        final items = List.generate(50, (i) => i);
        final unshuffled = List.of(items);

        shuffle(items, Random(1));

        expect(items, isNot(unshuffled));
      });

      test('does nothing to an empty list', () {
        final items = <int>[];

        shuffle(items, Random(0));

        expect(items, isEmpty);
      });

      test('does nothing to a single-element list', () {
        final items = [1];

        shuffle(items, Random(0));

        expect(items, [1]);
      });

      test('uses a new Random when none is provided', () {
        final items = [1, 2, 3, 4, 5];

        expect(() => shuffle(items), returnsNormally);
        expect(items, unorderedEquals([1, 2, 3, 4, 5]));
      });

      test('distributes each item roughly evenly across every position', () {
        const itemCount = 5;
        const trials = 20000;

        // positionCounts[item][position] tracks how often `item` landed on
        // `position` across all trials.
        final positionCounts = List.generate(
          itemCount,
          (_) => List.filled(itemCount, 0),
        );

        final random = Random(7);
        for (var trial = 0; trial < trials; trial++) {
          final items = List.generate(itemCount, (i) => i);

          shuffle(items, random);

          for (var position = 0; position < itemCount; position++) {
            positionCounts[items[position]][position]++;
          }
        }

        // With a uniform shuffle, every item lands on every position with
        // probability 1/itemCount. Allow generous slack around the expected
        // count to keep this sanity check from flaking.
        final expected = trials / itemCount;
        final tolerance = expected * 0.15;

        for (final counts in positionCounts) {
          for (final count in counts) {
            expect(
              count,
              closeTo(expected, tolerance),
            );
          }
        }
      });
    },
  );
}
