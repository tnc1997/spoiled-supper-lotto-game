import 'package:material_ui/material_ui.dart';

import 'card_aspect_ratio.dart';
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
    final onDraw = game.canDrawFromDrawPile ? notifier.drawFromDrawPile : null;

    return Semantics(
      container: true,
      excludeSemantics: true,
      button: true,
      enabled: onDraw != null,
      label: 'Draw pile, $countLabel',
      onTap: onDraw,
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
                  count == 0 ? const _EmptyPile() : const _CardBack(),
                  // Lies over the pile, so that its ink and focus highlight
                  // show on top of the card back rather than behind it.
                  Material(
                    type: MaterialType.transparency,
                    child: InkWell(onTap: onDraw),
                  ),
                ],
              ),
            ),
          ),
          Text(countLabel, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

/// The back of a card, framed like a card on the board, with a subtle
/// shadow and a thin outline.
///
/// It is an original design: the theme's primary container colour, with an
/// inset border and a place-setting icon.
class _CardBack extends StatelessWidget {
  const _CardBack();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: kElevationToShadow[2],
      ),
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

/// The space the draw pile takes once it is empty: a plain card-shaped
/// area, like an empty slot on a plate, labelled "Empty".
class _EmptyPile extends StatelessWidget {
  const _EmptyPile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          // Shrinks the label, rather than overflowing, at large text
          // scales.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('Empty', style: theme.textTheme.labelLarge),
          ),
        ),
      ),
    );
  }
}
