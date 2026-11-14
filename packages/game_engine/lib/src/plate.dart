import 'card.dart';
import 'card_type.dart';
import 'category.dart';
import 'notifier.dart';

/// A player's place-setting board, with one slot per [Category].
///
/// Listeners are notified whenever a card is placed.
class Plate with Notifier {
  final Map<Category, Card?> _slots;

  Plate({
    Card? dessert,
    Card? vegetable,
    Card? main,
    Card? carbohydrate,
    Card? drink,
  }) : _slots = {
          Category.dessert: dessert,
          Category.vegetable: vegetable,
          Category.main: main,
          Category.carbohydrate: carbohydrate,
          Category.drink: drink,
        };

  /// The card occupying [category]'s slot, or `null` if it's empty.
  Card? operator [](Category category) => _slots[category];

  /// Places [card] into the slot matching its category, replacing any card
  /// already there.
  ///
  /// Returns the card that was replaced, or `null` if the slot was empty.
  Card? place(Card card) {
    final replaced = _slots[card.category];
    _slots[card.category] = card;
    notifyListeners();
    return replaced;
  }

  /// Whether every slot has a [CardType.standard] card, i.e. the meal is
  /// complete. A [CardType.spoiled] card keeps its slot from counting.
  bool get isFull =>
      _slots.values.every((card) => card?.type == CardType.standard);
}
