import 'package:material_ui/material_ui.dart';

import 'card_aspect_ratio.dart';

/// Frames a card-shaped [child] with a subtle shadow and a thin outline, so
/// that its edge stands out from the board behind it, even when its colour
/// is close to the board's. The outline keeps the edge visible on a dark
/// board, where the shadow barely shows. Its corners are square, like the
/// physical cards'.
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
        // Draws the outline over the card, which would otherwise hide it.
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
