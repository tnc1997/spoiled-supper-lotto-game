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

      test(
        'has an empty slot for every category without a card',
        () {
          final plate = Plate({});

          for (final category in Category.values) {
            expect(plate[category], isNull);
          }
        },
      );

      test(
        'shows the card in each filled slot',
        () {
          final main = standard(Category.main);
          final plate = Plate({Category.main: main});

          expect(plate[Category.main], main);
          expect(plate[Category.dessert], isNull);
        },
      );

      test(
        'reflects later changes to the cards it views',
        () {
          final cards = <Category, Card>{};
          final plate = Plate(cards);
          final drink = standard(Category.drink);

          cards[Category.drink] = drink;

          expect(plate[Category.drink], drink);
        },
      );

      test(
        'is not full until every slot has a card',
        () {
          final cards = <Category, Card>{};
          final plate = Plate(cards);

          for (final category in Category.values) {
            expect(plate.isFull, isFalse);
            cards[category] = standard(category);
          }

          expect(plate.isFull, isTrue);
        },
      );

      test(
        'is not full while a slot has a spoiled card',
        () {
          final plate = Plate({
            for (final category in Category.values)
              category: Card(
                id: category.name,
                type: category == Category.main
                    ? CardType.spoiled
                    : CardType.standard,
                category: category,
                name: category.name,
              ),
          });

          expect(plate.isFull, isFalse);
        },
      );
    },
  );
}
