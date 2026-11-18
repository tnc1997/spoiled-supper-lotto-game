import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

import 'card_aspect_ratio.dart';
import 'category_color.dart';
import 'category_label.dart';
import 'framed_card.dart';
import 'game_scope.dart';

/// Shows a [player]'s place-setting board, from the closest [GameScope],
/// with a slot for each category that shows the card in it, or that the
/// slot is empty.
///
/// Like the physical board, the slots sit in one row: the dessert, the
/// vegetable, the main, the carbohydrate and the drink, so that the main
/// is in the middle with its two sides either side of it.
class Plate extends StatelessWidget {
  static const _gap = 16.0;

  /// The categories of the slots, from left to right.
  static const _categories = [
    engine.Category.dessert,
    engine.Category.vegetable,
    engine.Category.main,
    engine.Category.carbohydrate,
    engine.Category.drink,
  ];

  /// The player whose plate to show.
  final engine.Player player;

  /// The width of each slot, in logical pixels.
  final double cardWidth;

  /// Shows [player]'s plate, with each slot [cardWidth] logical pixels wide.
  const Plate({super.key, required this.player, this.cardWidth = 120});

  @override
  Widget build(BuildContext context) {
    final plate = GameScope.of(context).game.plateOf(player);

    Widget slot(engine.Category category) {
      final card = plate[category];

      return SizedBox(
        width: cardWidth,
        child: card == null
            ? _EmptySlot(category: category)
            : FramedCard(card: card),
      );
    }

    return Semantics(
      container: true,
      label: "${player.name}'s plate",
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: _gap,
        children: [
          for (final category in _categories) slot(category),
        ],
      ),
    );
  }
}

/// The empty slot for [category]: a card-shaped outline in the category's
/// colour, labelled with the category.
class _EmptySlot extends StatelessWidget {
  final engine.Category category;

  const _EmptySlot({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category.color;

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '${category.label}, empty',
      child: AspectRatio(
        aspectRatio: cardAspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            // Darkens the outline so that it stands out from a light board,
            // even for the paler colours, like yellow.
            border: Border.all(
              color: HSLColor.fromColor(color).withLightness(0.4).toColor(),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              // Shrinks the label, rather than overflowing, at large text
              // scales.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  category.label,
                  style: theme.textTheme.labelLarge,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
