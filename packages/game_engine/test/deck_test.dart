import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'buildDeck',
    () {
      test(
        'builds 30 cards in total',
        () {
          final deck = buildDeck();

          expect(deck, hasLength(30));
        },
      );

      test(
        'builds 20 standard cards and 10 Spoiled cards',
        () {
          final deck = buildDeck();

          expect(
            deck.where((card) => card.type == CardType.standard),
            hasLength(20),
          );
          expect(
            deck.where((card) => card.type == CardType.spoiled),
            hasLength(10),
          );
        },
      );

      test(
        'builds 4 standard cards and 2 Spoiled cards per category',
        () {
          final deck = buildDeck();

          for (final category in Category.values) {
            expect(
              deck.where(
                (card) =>
                    card.category == category && card.type == CardType.standard,
              ),
              hasLength(4),
            );
            expect(
              deck.where(
                (card) =>
                    card.category == category && card.type == CardType.spoiled,
              ),
              hasLength(2),
            );
          }
        },
      );

      test(
        'builds every card with a unique id',
        () {
          final deck = buildDeck();

          expect(deck.map((card) => card.id).toSet(), hasLength(deck.length));
        },
      );

      test(
        'builds every card with a fixed UUID id',
        () {
          final deck = buildDeck();
          final uuid = RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          );

          for (final card in deck) {
            expect(card.id, matches(uuid));
          }
        },
      );

      test(
        'assigns each card the same id on every call',
        () {
          final first = buildDeck();
          final second = buildDeck();

          final firstIdsByName = {
            for (final card in first) card.name: card.id,
          };
          final secondIdsByName = {
            for (final card in second) card.name: card.id,
          };

          expect(secondIdsByName, firstIdsByName);
        },
      );

      test(
        'includes the confirmed standard card names',
        () {
          final deck = buildDeck();
          final names = deck
              .where((card) => card.type == CardType.standard)
              .map((card) => card.name)
              .toSet();

          expect(
            names,
            {
              'Fruit Salad',
              'Ice Cream',
              'Jelly',
              'Strawberries',
              'Baked Beans',
              'Carrots',
              'Peas',
              'Tomatoes',
              'Fish Fingers',
              'Lamb Chops',
              'Sausages',
              'Steak Pie',
              'Baked Potato',
              'Boiled Potatoes',
              'Chips',
              'Mashed Potato',
              'Grape Soda',
              'Milk',
              'Orange Soda',
              'Water',
            },
          );
        },
      );

      test(
        'includes the confirmed Spoiled card names',
        () {
          final deck = buildDeck();
          final names = deck
              .where((card) => card.type == CardType.spoiled)
              .map((card) => card.name)
              .toSet();

          expect(
            names,
            {
              'Apple Core',
              'Banana Skin',
              'Dandelions',
              'Mouldy Lettuce',
              'Fish Bone',
              'Leather Boot',
              'Mouldy Potato',
              'Potato Peelings',
              'Bug Soda',
              'Pond Water',
            },
          );
        },
      );

      test(
        'builds a fresh deck on every call',
        () {
          final first = buildDeck();
          final second = buildDeck();

          expect(first, second);
          expect(identical(first, second), isFalse);
        },
      );
    },
  );
}
