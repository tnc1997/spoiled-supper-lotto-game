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
    },
  );
}
