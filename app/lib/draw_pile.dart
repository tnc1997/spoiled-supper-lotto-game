import 'package:material_ui/material_ui.dart';

import 'card_back.dart';
import 'card_frame.dart';
import 'empty_slot.dart';
import 'game_scope.dart';

/// Shows the draw pile, from the closest [GameScope], face down, with the
/// number of cards left in it below.
///
/// Tapping the pile draws its top card, while the current player can draw
/// from it. Once the pile is empty, it shows as a plain card-shaped area,
/// and drawing from it refills it from the discard pile, as the game's
/// rules do.
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
    final countLabel = count == 1 ? '1 card' : '$count cards';
    final onDraw = game.canDrawFromDrawPile ? notifier.drawFromDrawPile : null;

    // Makes the pile one button, which takes on the focus state and tap
    // action of its InkWell, so a screen reader announces it as it gains
    // keyboard focus, and the count below it, e.g. "Draw pile", "1 card".
    return Semantics(
      container: true,
      button: true,
      enabled: onDraw != null,
      label: 'Draw pile',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SizedBox(
            width: cardWidth,
            // Takes its size, in the card's shape, from the pile.
            child: Stack(
              children: [
                // Leaves the label and count to say what the pile shows,
                // rather than the empty slot's "Empty".
                ExcludeSemantics(
                  child: count == 0
                      ? const EmptySlot(label: 'Empty')
                      : const CardFrame(child: CardBack()),
                ),
                // Lies over the pile, so that its ink and focus highlight
                // show on top of the card back rather than behind it.
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(onTap: onDraw),
                  ),
                ),
              ],
            ),
          ),
          Text(countLabel, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
