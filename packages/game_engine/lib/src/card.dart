import 'card_type.dart';
import 'category.dart';

/// A single card from the draw or discard pile.
class Card {
  /// Uniquely identifies this card among all cards in play.
  final String id;

  /// Whether this is a food card or a Spoiled card.
  final CardType type;

  /// The type of food (or drink) this card belongs to.
  ///
  /// Applies to both [CardType.standard] and [CardType.spoiled] cards.
  final Category category;

  /// The maintainer's original description of the card's imagery, e.g.
  /// `Fish Fingers` or `Mouldy Potato`.
  final String name;

  const Card({
    required this.id,
    required this.type,
    required this.category,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Card &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          category == other.category &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, type, category, name);

  @override
  String toString() =>
      'Card(id: $id, type: $type, category: $category, name: $name)';
}
