import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Plate',
    () {
      test(
        'starts with every slot empty',
        () {
          final plate = Plate();

          for (final category in Category.values) {
            expect(plate[category], isNull);
          }
        },
      );

      test(
        'can be constructed with cards already in some slots',
        () {
          const main = Card(
            id: '1',
            type: CardType.standard,
            category: Category.main,
            name: 'Sausages',
          );

          final plate = Plate(main: main);

          expect(plate[Category.main], main);
          expect(plate[Category.dessert], isNull);
        },
      );

      test(
        'can be constructed with every slot already filled',
        () {
          const dessert = Card(
            id: '1',
            type: CardType.standard,
            category: Category.dessert,
            name: 'Jelly',
          );
          const vegetable = Card(
            id: '2',
            type: CardType.standard,
            category: Category.vegetable,
            name: 'Carrots',
          );
          const main = Card(
            id: '3',
            type: CardType.standard,
            category: Category.main,
            name: 'Sausages',
          );
          const carbohydrate = Card(
            id: '4',
            type: CardType.standard,
            category: Category.carbohydrate,
            name: 'Chips',
          );
          const drink = Card(
            id: '5',
            type: CardType.standard,
            category: Category.drink,
            name: 'Milk',
          );

          final plate = Plate(
            dessert: dessert,
            vegetable: vegetable,
            main: main,
            carbohydrate: carbohydrate,
            drink: drink,
          );

          expect(plate[Category.dessert], dessert);
          expect(plate[Category.vegetable], vegetable);
          expect(plate[Category.main], main);
          expect(plate[Category.carbohydrate], carbohydrate);
          expect(plate[Category.drink], drink);
          expect(plate.isFull, isTrue);
        },
      );

      test(
        'places a card into the slot matching its category',
        () {
          const card = Card(
            id: '1',
            type: CardType.standard,
            category: Category.dessert,
            name: 'Jelly',
          );

          final plate = Plate();
          plate.place(card);

          expect(plate[Category.dessert], card);
        },
      );

      test(
        'placing a card overwrites any card already in that slot',
        () {
          const first = Card(
            id: '1',
            type: CardType.standard,
            category: Category.drink,
            name: 'Milk',
          );
          const second = Card(
            id: '2',
            type: CardType.spoiled,
            category: Category.drink,
            name: 'Pond Water',
          );

          final plate = Plate()
            ..place(first)
            ..place(second);

          expect(plate[Category.drink], second);
        },
      );

      test(
        'is not full until every slot has a card',
        () {
          final plate = Plate();

          expect(plate.isFull, isFalse);

          for (final category in Category.values) {
            plate.place(
              Card(
                id: category.name,
                type: CardType.standard,
                category: category,
                name: category.name,
              ),
            );
          }

          expect(plate.isFull, isTrue);
        },
      );
    },
  );
}
