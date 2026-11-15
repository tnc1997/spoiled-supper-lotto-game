import 'package:flutter_test/flutter_test.dart';
import 'package:game_engine/game_engine.dart';
import 'package:spoiled_supper_lotto_game/asset_slots.dart';

void main() {
  group(
    'assetSlots',
    () {
      final deck = buildDeck();

      test(
        'has a slot for every card in the deck',
        () {
          expect(
            assetSlots.keys,
            unorderedEquals(deck.map((card) => card.id)),
          );
        },
      );

      test(
        'gives every card a different filename',
        () {
          expect(
            assetSlots.values.toSet(),
            hasLength(assetSlots.length),
          );
        },
      );

      test(
        'names every file in lowercase words separated by hyphens',
        () {
          expect(
            assetSlots.values,
            everyElement(matches(RegExp(r'^[a-z]+(-[a-z]+)*\.png$'))),
          );
        },
      );
    },
  );

  group(
    'AssetSlot',
    () {
      group(
        'overrideFilename',
        () {
          test(
            'returns the filename of a card in the deck',
            () {
              final fishFingers = buildDeck().singleWhere(
                (card) => card.name == 'Fish Fingers',
              );

              expect(fishFingers.overrideFilename, 'fish-fingers.png');
            },
          );

          test(
            'returns null for a card not in the deck',
            () {
              const card = Card(
                id: '1',
                type: CardType.standard,
                category: Category.main,
                name: 'Sausages',
              );

              expect(card.overrideFilename, isNull);
            },
          );
        },
      );
    },
  );
}
