/// The shape of every card, as its width divided by its height.
///
/// Matches the 5:8 shape of the 260x416px card template that card images
/// are cropped to by `tools/crop-cards.sh`, so that a placeholder and a
/// player's own image take up the same space, and swapping one for the
/// other doesn't change the card's size.
const cardAspectRatio = 5 / 8;
