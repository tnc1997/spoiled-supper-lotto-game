import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Card',
    () {
      const card = Card(
        id: '1',
        type: CardType.standard,
        category: Category.main,
        name: 'Sausages',
      );

      group(
        'id',
        () {
          test(
            'is the id it was created with',
            () {
              expect(card.id, '1');
            },
          );
        },
      );

      group(
        'type',
        () {
          test(
            'is the type it was created with',
            () {
              expect(card.type, CardType.standard);
            },
          );

          test(
            'can be spoiled',
            () {
              const spoiled = Card(
                id: '2',
                type: CardType.spoiled,
                category: Category.main,
                name: 'Fish Bone',
              );

              expect(spoiled.type, CardType.spoiled);
            },
          );
        },
      );

      group(
        'category',
        () {
          test(
            'is the category it was created with',
            () {
              expect(card.category, Category.main);
            },
          );

          test(
            'applies to spoiled cards too',
            () {
              const spoiled = Card(
                id: '2',
                type: CardType.spoiled,
                category: Category.main,
                name: 'Fish Bone',
              );

              expect(spoiled.category, Category.main);
            },
          );
        },
      );

      group(
        'name',
        () {
          test(
            'is the name it was created with',
            () {
              expect(card.name, 'Sausages');
            },
          );
        },
      );

      group(
        'operator ==',
        () {
          test(
            'is true for a card with the same fields',
            () {
              const other = Card(
                id: '1',
                type: CardType.standard,
                category: Category.main,
                name: 'Sausages',
              );

              expect(card, other);
            },
          );

          test(
            'is false for a card with a different id',
            () {
              const other = Card(
                id: '2',
                type: CardType.standard,
                category: Category.main,
                name: 'Sausages',
              );

              expect(card, isNot(other));
            },
          );

          test(
            'is false for a card with a different type',
            () {
              const other = Card(
                id: '1',
                type: CardType.spoiled,
                category: Category.main,
                name: 'Sausages',
              );

              expect(card, isNot(other));
            },
          );

          test(
            'is false for a card with a different category',
            () {
              const other = Card(
                id: '1',
                type: CardType.standard,
                category: Category.dessert,
                name: 'Sausages',
              );

              expect(card, isNot(other));
            },
          );

          test(
            'is false for a card with a different name',
            () {
              const other = Card(
                id: '1',
                type: CardType.standard,
                category: Category.main,
                name: 'Steak Pie',
              );

              expect(card, isNot(other));
            },
          );

          test(
            'is true for the same card',
            () {
              expect(card, card);
            },
          );

          test(
            'is false for a non-Card object',
            () {
              expect(card, isNot('1'));
            },
          );
        },
      );

      group(
        'hashCode',
        () {
          test(
            'is the same for cards with the same fields',
            () {
              const other = Card(
                id: '1',
                type: CardType.standard,
                category: Category.main,
                name: 'Sausages',
              );

              expect(card.hashCode, other.hashCode);
            },
          );
        },
      );

      group(
        'toString',
        () {
          test(
            'includes id, type, category, and name',
            () {
              expect(
                card.toString(),
                'Card(id: 1, type: CardType.standard, category: Category.main, '
                'name: Sausages)',
              );
            },
          );
        },
      );
    },
  );
}
