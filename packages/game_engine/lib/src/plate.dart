import 'card.dart';
import 'category.dart';

/// A player's place-setting board, with one slot per [Category].
class Plate {
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

  /// Places [card] into the slot matching its category, overwriting any card
  /// already there.
  void place(Card card) => _slots[card.category] = card;

  /// Whether every slot has a card, i.e. the meal is complete.
  bool get isFull => _slots.values.every((card) => card != null);
}
