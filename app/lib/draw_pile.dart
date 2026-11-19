import 'package:material_ui/material_ui.dart';

import 'card_back.dart';
import 'game_scope.dart';
import 'pile.dart';

/// Shows the draw pile, from the closest [GameScope], face down, with the
/// number of cards left in it below.
///
/// Tapping the pile draws its top card, while the current player can draw
/// from it. Once the pile is empty, it shows as a plain card-shaped area
/// that can't be drawn from. The game refills it from the discard pile at
/// the end of the play that empties it, so it only stays empty while the
/// discard pile has 1 card or none.
class DrawPile extends StatelessWidget {
  /// The width of the pile, in logical pixels.
  final double cardWidth;

  /// Shows the draw pile, [cardWidth] logical pixels wide.
  const DrawPile({super.key, this.cardWidth = 120});

  @override
  Widget build(BuildContext context) {
    final notifier = GameScope.of(context);
    final game = notifier.game;
    final count = game.drawPile.length;

    return Pile(
      label: 'Draw pile',
      count: count,
      card: count == 0 ? null : const CardBack(),
      onTap: game.canDrawFromDrawPile ? notifier.drawFromDrawPile : null,
      cardWidth: cardWidth,
    );
  }
}
