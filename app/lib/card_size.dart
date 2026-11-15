import 'dart:ui';

import 'card_aspect_ratio.dart';

/// The size, in logical pixels, that every card is laid out at, before it
/// is scaled, keeping its shape, to fit the space its parent allows.
///
/// In an unbounded parent, a card shows at this size. Both a placeholder
/// and a player's own image use it, so that swapping one for the other
/// doesn't change the card's size.
///
/// Has the shape of every card, [cardAspectRatio]. The placeholder's
/// padding and text are sized for a card 100 logical pixels wide.
const cardSize = Size(100, 100 / cardAspectRatio);
