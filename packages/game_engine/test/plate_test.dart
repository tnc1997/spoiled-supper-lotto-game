import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Plate',
    () {
      Card standard(Category category) => Card(
            id: category.name,
            type: CardType.standard,
            category: category,
            name: category.name,
          );

      group(
        'Plate.new',
        () {
          test(
            'throws if two cards share a category',
            () {
              expect(
                () => Plate([standard(Category.main), standard(Category.main)]),
                throwsArgumentError,
              );
            },
          );

          test(
            'is not changed by later changes to the given cards',
            () {
              final cards = [standard(Category.main)];
              final plate = Plate(cards);

              cards.add(standard(Category.drink));

              expect(plate[Category.drink], isNull);
            },
          );
        },
      );

      group(
        'cards',
        () {
          test(
            'is empty by default',
            () {
              final plate = Plate();

              expect(plate.cards, isEmpty);
            },
          );

          test(
            'contains the given cards',
            () {
              final main = standard(Category.main);
              final drink = standard(Category.drink);
              final plate = Plate([main, drink]);

              expect(plate.cards, unorderedEquals([main, drink]));
            },
          );
        },
      );

      group(
        'operator []',
        () {
          test(
            'returns null for every slot by default',
            () {
              final plate = Plate();

              for (final category in Category.values) {
                expect(plate[category], isNull);
              }
            },
          );

          test(
            'returns the card in the slot for its category',
            () {
              final main = standard(Category.main);
              final plate = Plate([main, standard(Category.drink)]);

              expect(plate[Category.main], main);
            },
          );

          test(
            'returns null for a slot with no given card',
            () {
              final plate = Plate([
                standard(Category.main),
                standard(Category.drink),
              ]);

              expect(plate[Category.dessert], isNull);
            },
          );
        },
      );

      group(
        'isFull',
        () {
          test(
            'is false until every slot has a card',
            () {
              final cards = <Card>[];

              for (final category in Category.values) {
                expect(Plate(cards).isFull, isFalse);
                cards.add(standard(category));
              }
            },
          );

          test(
            'is true when every slot has a standard card',
            () {
              final plate = Plate([
                for (final category in Category.values) standard(category),
              ]);

              expect(plate.isFull, isTrue);
            },
          );

          test(
            'is false while a slot has a spoiled card',
            () {
              final plate = Plate([
                for (final category in Category.values)
                  Card(
                    id: category.name,
                    type: category == Category.main
                        ? CardType.spoiled
                        : CardType.standard,
                    category: category,
                    name: category.name,
                  ),
              ]);

              expect(plate.isFull, isFalse);
            },
          );
        },
      );

      group(
        'operator ==',
        () {
          test(
            'is true for a plate with the same cards in a different order',
            () {
              final main = standard(Category.main);
              final drink = standard(Category.drink);

              expect(Plate([main, drink]), Plate([drink, main]));
            },
          );

          test(
            'is false for a plate with different cards',
            () {
              final main = standard(Category.main);
              final drink = standard(Category.drink);

              expect(Plate([main]), isNot(Plate([main, drink])));
            },
          );

          test(
            'is true for two empty plates',
            () {
              expect(Plate(), Plate());
            },
          );
        },
      );

      group(
        'hashCode',
        () {
          test(
            'is the same for plates with the same cards in a different order',
            () {
              final main = standard(Category.main);
              final drink = standard(Category.drink);

              expect(
                Plate([main, drink]).hashCode,
                Plate([drink, main]).hashCode,
              );
            },
          );
        },
      );
    },
  );
}
