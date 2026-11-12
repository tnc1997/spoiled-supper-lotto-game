/// Whether a [Card] is a regular food card or a Spoiled card.
enum CardType {
  /// A food or drink card that completes a place on the plate.
  standard,

  /// A Spoiled card, which can only be placed into an empty slot, and keeps
  /// the meal incomplete until a food card replaces it.
  spoiled,
}
