import 'package:material_ui/material_ui.dart';

import 'card_aspect_ratio.dart';

/// An empty card-shaped area on the board, labelled with [label], e.g. an
/// empty slot on a plate or an empty pile.
///
/// Like the physical board's plain white slots, it is the theme's lowest
/// container colour: white in a light theme, and the darkest surface in a
/// dark one.
///
/// It keeps a card's shape, [cardAspectRatio], and fills as much of the
/// space its parent allows as it can.
class EmptySlot extends StatelessWidget {
  /// The text shown in the slot, e.g. the category of the card that goes
  /// in it.
  final String label;

  /// Shows an empty slot labelled [label].
  const EmptySlot({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: cardAspectRatio,
      child: ColoredBox(
        color: theme.colorScheme.surfaceContainerLowest,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            // Shrinks the label, rather than overflowing, at large text
            // scales.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: theme.textTheme.labelLarge),
            ),
          ),
        ),
      ),
    );
  }
}
