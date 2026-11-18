import 'package:material_ui/material_ui.dart';

import 'card_aspect_ratio.dart';

/// Frames a card-shaped [child] with a subtle shadow, so that it sits on
/// the board behind it. Like the physical cards, it has no outline, so
/// that cards side by side join up into one picture, and its corners are
/// square.
///
/// Use this for anything shown as a card on the board, face up or face
/// down, so that every card there is framed alike, e.g.
/// `CardFrame(child: Card(card: card))` for a card face up. A
/// `PlaceholderCard` and the player's own image of a card are framed alike,
/// so swapping one for the other doesn't change the card's look.
///
/// The frame keeps the card's shape, [cardAspectRatio], and fills as much
/// of the space its parent allows as it can.
class CardFrame extends StatelessWidget {
  /// The card to frame, e.g. its face or its back.
  final Widget child;

  /// Frames [child].
  const CardFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: cardAspectRatio,
      // Casts the shadow behind the card.
      child: DecoratedBox(
        decoration: BoxDecoration(boxShadow: kElevationToShadow[2]),
        child: child,
      ),
    );
  }
}
