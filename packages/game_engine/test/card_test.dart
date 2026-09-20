import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Card',
    () {
      test('exposes its id, type, category, and name', () {
        const card = Card(
          id: '1',
          type: CardType.standard,
          category: Category.main,
          name: 'Sausages',
        );

        expect(card.id, '1');
        expect(card.type, CardType.standard);
        expect(card.category, Category.main);
        expect(card.name, 'Sausages');
      });

      test('category applies to spoiled cards too', () {
        const card = Card(
          id: '2',
          type: CardType.spoiled,
          category: Category.main,
          name: 'Fish Bone',
        );

        expect(card.type, CardType.spoiled);
        expect(card.category, Category.main);
      });

      test('two cards with the same fields are equal', () {
        const a = Card(
          id: '1',
          type: CardType.standard,
          category: Category.main,
          name: 'Sausages',
        );
        const b = Card(
          id: '1',
          type: CardType.standard,
          category: Category.main,
          name: 'Sausages',
        );

        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('two cards with different ids are not equal', () {
        const a = Card(
          id: '1',
          type: CardType.standard,
          category: Category.main,
          name: 'Sausages',
        );
        const b = Card(
          id: '2',
          type: CardType.standard,
          category: Category.main,
          name: 'Sausages',
        );

        expect(a, isNot(b));
      });
    },
  );
}
