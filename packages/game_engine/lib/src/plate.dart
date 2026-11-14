import 'card.dart';
import 'card_type.dart';
import 'category.dart';

/// A player's place-setting board, with one slot per [Category].
///
/// A plate can't be changed once it's built. When a card is placed, the
/// game gives the player a new plate, so a plate that's held on to keeps
/// showing the cards it was built with.
class Plate {
  final Map<Category, Card> _slots;

  /// Creates a plate with each of [cards] in the slot for its category, and
  /// every other slot empty.
  ///
  /// Throws an [ArgumentError] if two of [cards] share a category, since a
  /// slot holds one card.
  Plate([Iterable<Card> cards = const []]) : _slots = _slotsOf(cards);

  /// The cards on this plate, in no particular order.
  Iterable<Card> get cards => _slots.values;

  /// The card occupying [category]'s slot, or `null` if it's empty.
  Card? operator [](Category category) => _slots[category];

  /// Whether every slot has a [CardType.standard] card, i.e. the meal is
  /// complete. A [CardType.spoiled] card keeps its slot from counting.
  bool get isFull => Category.values
      .every((category) => _slots[category]?.type == CardType.standard);

  /// Whether [other] is a plate with the same card in every slot.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Plate &&
          Category.values
              .every((category) => this[category] == other[category]);

  @override
  int get hashCode => Object.hashAll(Category.values.map((c) => this[c]));

  /// Returns [cards] keyed by category.
  ///
  /// Throws an [ArgumentError] if two of the cards share a category.
  static Map<Category, Card> _slotsOf(Iterable<Card> cards) {
    final slots = <Category, Card>{};

    for (final card in cards) {
      if (slots.containsKey(card.category)) {
        throw ArgumentError.value(
          card.name,
          'cards',
          'Must not have two ${card.category.name} cards',
        );
      }

      slots[card.category] = card;
    }

    return Map.unmodifiable(slots);
  }
}
