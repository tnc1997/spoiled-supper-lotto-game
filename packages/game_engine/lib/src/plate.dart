import 'card.dart';
import 'card_type.dart';
import 'category.dart';
import 'game_controller.dart';

/// A read-only view of a player's place-setting board, with one slot per
/// [Category].
///
/// Like `UnmodifiableListView`, this reflects later changes to the map it
/// wraps, but can't be used to change it. A game's plates are changed only
/// by its [GameController], so read them from the game each time they're
/// needed, such as on each build, rather than holding on to them.
class Plate {
  final Map<Category, Card> _cards;

  /// Creates a view of [cards], which maps each category to the card in its
  /// slot. A category without an entry is an empty slot.
  Plate(Map<Category, Card> cards) : _cards = cards;

  /// The card occupying [category]'s slot, or `null` if it's empty.
  Card? operator [](Category category) => _cards[category];

  /// Whether every slot has a [CardType.standard] card, i.e. the meal is
  /// complete. A [CardType.spoiled] card keeps its slot from counting.
  bool get isFull => Category.values
      .every((category) => _cards[category]?.type == CardType.standard);
}
