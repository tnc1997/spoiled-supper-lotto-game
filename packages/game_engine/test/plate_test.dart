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
        'starts with every slot empty',
        () {
          final plate = Plate();

          expect(plate.cards, isEmpty);

          for (final category in Category.values) {
            expect(plate[category], isNull);
          }
        },
      );

      test(
        'puts each card in the slot for its category',
        () {
          final main = standard(Category.main);
          final drink = standard(Category.drink);
          final plate = Plate([main, drink]);

          expect(plate[Category.main], main);
          expect(plate[Category.drink], drink);
          expect(plate[Category.dessert], isNull);
          expect(plate.cards, unorderedEquals([main, drink]));
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
        'is not full until every slot has a card',
        () {
          final cards = <Card>[];

          for (final category in Category.values) {
            expect(Plate(cards).isFull, isFalse);
            cards.add(standard(category));
          }

          expect(Plate(cards).isFull, isTrue);
        },
      );

      test(
        'is not full while a slot has a spoiled card',
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

      test(
        'equals a plate with the same card in every slot',
        () {
          final main = standard(Category.main);
          final drink = standard(Category.drink);

          expect(Plate([main, drink]), Plate([drink, main]));
          expect(
            Plate([main, drink]).hashCode,
            Plate([drink, main]).hashCode,
          );
          expect(Plate([main]), isNot(Plate([main, drink])));
          expect(Plate(), Plate());
        },
      );
    },
  );
}
