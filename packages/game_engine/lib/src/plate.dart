import 'card.dart';
import 'card_type.dart';
import 'category.dart';
import 'listeners.dart';

/// A player's place-setting board, with one slot per [Category].
///
/// Listeners are notified whenever a card is placed.
class Plate {
  final Map<Category, Card?> _slots;
  final _listeners = Listeners();

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

  /// Calls [listener] whenever a card is placed.
  ///
  /// Adding the same listener more than once means it's called once per
  /// time it was added.
  void addListener(void Function() listener) => _listeners.add(listener);

  /// Stops calling [listener] when a card is placed, once for each time it
  /// was added.
  void removeListener(void Function() listener) => _listeners.remove(listener);

  /// The card occupying [category]'s slot, or `null` if it's empty.
  Card? operator [](Category category) => _slots[category];

  /// Places [card] into the slot matching its category, replacing any card
  /// already there.
  ///
  /// Returns the card that was replaced, or `null` if the slot was empty.
  Card? place(Card card) {
    final replaced = _slots[card.category];
    _slots[card.category] = card;
    _listeners.notify();
    return replaced;
  }

  /// Whether every slot has a [CardType.standard] card, i.e. the meal is
  /// complete. A [CardType.spoiled] card keeps its slot from counting.
  bool get isFull =>
      _slots.values.every((card) => card?.type == CardType.standard);
}
