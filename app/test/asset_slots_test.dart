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
        'keeps every name that has been released',
        () {
          // Players name their files to match these, so changing one stops
          // their image from being found. Only add to this list.
          expect(
            assetSlots,
            const {
              '1310ab58-8b89-4f70-bd68-347cdaeb7b71': 'fruit-salad',
              '986542ea-6353-407d-9d53-daad2cbf3ac9': 'ice-cream',
              '482625fa-aa08-4ca3-a388-a2810cb77d4f': 'jelly',
              '12d00074-f4fa-4be7-a67f-8af918a58002': 'strawberries',
              'badb0150-97aa-4659-9ef5-5eddeaeccc05': 'baked-beans',
              '874cd11e-001c-4fbc-a266-1cc6473d079e': 'carrots',
              '6a2532eb-2041-41f9-9de7-ff891242ca67': 'peas',
              '010dfe29-2ad0-4213-baa2-5dbefba4ca8c': 'tomatoes',
              '0d78745d-a48f-4412-a32e-d81e2911ae8b': 'fish-fingers',
              'aa3dd15d-c501-4781-81c0-800fb0a99891': 'lamb-chops',
              'b2590d89-4580-40c7-8b33-3c92fc6b347d': 'sausages',
              '07052827-80dd-4b67-b52a-cfdd1efbe4c2': 'steak-pie',
              '52093ec1-989b-4fe6-afaa-5482339e5d79': 'baked-potato',
              'e28dc998-bbf9-4eef-b0e2-0cf93678951b': 'boiled-potatoes',
              'd9134a51-0a46-4b83-b415-87cbd14b749c': 'chips',
              '9b7a2054-b704-4028-aa72-cd2981c464d8': 'mashed-potato',
              '9c50c52b-f825-49b8-a711-0b8db36dceb4': 'grape-soda',
              '8c1effeb-cb21-40bd-9232-014490c639c8': 'milk',
              '739daf3a-2df3-4aaa-9e2b-3154f5f691f9': 'orange-soda',
              '8104dec3-ae72-492c-a310-80ff2d5b9d17': 'water',
              '382584f7-3ae8-4dea-b256-41f8dd660e1d': 'apple-core',
              'e67b07fc-f48e-4424-aabb-c4a2cdde911f': 'banana-skin',
              '1c76b18e-8985-4adf-88d5-8c7d688f2854': 'dandelions',
              '85f44a37-1024-4812-be5f-ff79c832837c': 'mouldy-lettuce',
              '22407c27-1682-4fca-b9b9-015208b86f18': 'fish-bone',
              '4d83670e-8428-497a-b29f-8e94813b77d7': 'leather-boot',
              'd31b5b5c-a78a-4803-a61e-3ddd82f4c866': 'mouldy-potato',
              'e821e21f-16d7-4a89-871c-49ad3679fbb5': 'potato-peelings',
              '43b3489f-d940-4980-8df5-bb669c751c3b': 'bug-soda',
              '04c69c46-f6e4-4fde-aa98-5ca02b2c46de': 'pond-water',
            },
          );
        },
      );

      test(
        'gives every card a different name',
        () {
          expect(
            assetSlots.values.toSet(),
            hasLength(assetSlots.length),
          );
        },
      );

      test(
        'writes every name in lowercase words separated by hyphens',
        () {
          expect(
            assetSlots.values,
            everyElement(matches(RegExp(r'^[a-z]+(-[a-z]+)*$'))),
          );
        },
      );
    },
  );

  group(
    'CardImageName',
    () {
      group(
        'imageName',
        () {
          test(
            'returns the name of a card in the deck',
            () {
              final fishFingers = buildDeck().singleWhere(
                (card) => card.id == '0d78745d-a48f-4412-a32e-d81e2911ae8b',
              );

              expect(fishFingers.imageName, 'fish-fingers');
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

              expect(card.imageName, isNull);
            },
          );
        },
      );
    },
  );
}
