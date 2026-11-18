import 'package:material_ui/material_ui.dart';

import 'card_aspect_ratio.dart';
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
    final theme = Theme.of(context);
    final notifier = GameScope.of(context);
    final game = notifier.game;
    final count = game.drawPile.length;
    final countLabel = count == 1 ? '1 card' : '$count cards';
    final onDraw = game.canDrawFromDrawPile
        ? () {
            // Checks again, since a second tap can land before the pile
            // rebuilds to disable itself, once a card has been drawn.
            if (notifier.game.canDrawFromDrawPile) {
              notifier.drawFromDrawPile();
            }
          }
        : null;

    // Makes the pile one button, which takes on the focus state and tap
    // action of its InkWell, so a screen reader announces it as it gains
    // keyboard focus.
    return Semantics(
      container: true,
      button: true,
      enabled: onDraw != null,
      label: 'Draw pile, $countLabel',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SizedBox(
            width: cardWidth,
            child: AspectRatio(
              aspectRatio: cardAspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Leaves the label to say what the pile shows.
                  ExcludeSemantics(
                    child: count == 0
                        ? const EmptySlot(label: 'Empty')
                        : const CardFrame(child: _CardBack()),
                  ),
                  // Lies over the pile, so that its ink and focus highlight
                  // show on top of the card back rather than behind it.
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: onDraw,
                      // Skips the pile with the keyboard while it is
                      // disabled.
                      canRequestFocus: onDraw != null,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ExcludeSemantics(
            child: Text(countLabel, style: theme.textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}

/// The back of a card, to show in a [CardFrame].
///
/// It is an original design: the theme's primary container colour, with an
/// inset border and a place-setting icon.
class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.onPrimaryContainer, width: 2),
          ),
          child: Center(
            // Scales the icon with the card.
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: FittedBox(
                child: Icon(
                  Icons.restaurant,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
