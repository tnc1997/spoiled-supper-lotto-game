import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;

import 'card.dart';
import 'card_aspect_ratio.dart';
import 'card_frame.dart';

/// Shows a [card] face up in a [CardFrame], with a subtle shadow and a thin
/// outline, so that its edge stands out from the board behind it. Use this
/// wherever a card is shown face up on the board, e.g. on a plate or the
/// discard pile.
///
/// A `PlaceholderCard` and the player's own image of the card are framed
/// alike, so swapping one for the other doesn't change the card's look.
///
/// The card keeps its shape, [cardAspectRatio], and fills as much of the
/// space its parent allows as it can.
class FramedCard extends StatelessWidget {
  /// The card to show.
  final engine.Card card;

  /// Shows [card].
  const FramedCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return CardFrame(child: Card(card: card));
  }
}
