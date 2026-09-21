import 'card.dart';
import 'card_type.dart';
import 'category.dart';

/// The standard cards confirmed against the maintainer's physical 1983 copy
/// (see Appendix A of `SPECIFICATION.md`), 4 per [Category].
const _standardCardNames = {
  Category.dessert: [
    'Fruit Salad',
    'Ice Cream',
    'Jelly',
    'Strawberries',
  ],
  Category.vegetable: [
    'Baked Beans',
    'Carrots',
    'Peas',
    'Tomatoes',
  ],
  Category.main: [
    'Fish Fingers',
    'Lamb Chops',
    'Sausages',
    'Steak Pie',
  ],
  Category.carbohydrate: [
    'Baked Potato',
    'Boiled Potatoes',
    'Chips',
    'Mashed Potato',
  ],
  Category.drink: [
    'Grape Soda',
    'Milk',
    'Orange Soda',
    'Water',
  ],
};

/// The Spoiled cards confirmed against the maintainer's physical 1983 copy
/// (see Appendix A of `SPECIFICATION.md`), 2 per [Category].
const _spoiledCardNames = {
  Category.dessert: [
    'Apple Core',
    'Banana Skin',
  ],
  Category.vegetable: [
    'Dandelions',
    'Mouldy Lettuce',
  ],
  Category.main: [
    'Fish Bone',
    'Leather Boot',
  ],
  Category.carbohydrate: [
    'Mouldy Potato',
    'Potato Peelings',
  ],
  Category.drink: [
    'Bug Soda',
    'Pond Water',
  ],
};

/// Builds the full 30-card deck confirmed against the maintainer's physical
/// 1983 copy (see Appendix A of `SPECIFICATION.md`): 20 standard cards and 10
/// Spoiled cards, 4 and 2 per [Category] respectively.
///
/// Each card is given a unique, stable id derived from its type, category,
/// and name, e.g. `standard-dessert-fruit-salad`.
List<Card> buildDeck() => [
      for (final entry in _standardCardNames.entries)
        for (final name in entry.value)
          _buildCard(CardType.standard, entry.key, name),
      for (final entry in _spoiledCardNames.entries)
        for (final name in entry.value)
          _buildCard(CardType.spoiled, entry.key, name),
    ];

Card _buildCard(CardType type, Category category, String name) => Card(
      id: '${type.name}-${category.name}-${_slugify(name)}',
      type: type,
      category: category,
      name: name,
    );

String _slugify(String name) =>
    name.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-');
