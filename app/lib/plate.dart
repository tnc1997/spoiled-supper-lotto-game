import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart' hide Card;

import 'card.dart';
import 'card_aspect_ratio.dart';
import 'card_frame.dart';
import 'category_label.dart';
import 'empty_slot.dart';
import 'game_scope.dart';
import 'plate_aspect_ratio.dart';

/// Shows a [player]'s place-setting board, from the closest [GameScope],
/// with a slot for each category that shows the card in it, or that the
/// slot is empty.
///
/// Like the physical board, the slots sit edge to edge in one row, split by
/// thin dividers: the dessert, the vegetable, the main, the carbohydrate and
/// the drink, so that the main is in the middle with its two sides either
/// side of it. The row runs the full width of a plain board, centred from
/// top to bottom, in the physical board's shape, [plateAspectRatio].
class Plate extends StatelessWidget {
  /// The width of the dividers between neighbouring slots, in logical
  /// pixels.
  static const _dividerWidth = 1.0;

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
    final colorScheme = Theme.of(context).colorScheme;
    final plate = GameScope.of(context).game.plateOf(player);

    Widget slot(engine.Category category) {
      final card = plate[category];

      return SizedBox(
        width: cardWidth,
        child: card == null
            ? _EmptySlot(category: category)
            : CardFrame(child: Card(card: card)),
      );
    }

    final divider = SizedBox(
      width: _dividerWidth,
      height: cardWidth / cardAspectRatio,
      child: ColoredBox(color: colorScheme.outlineVariant),
    );

    // The row of slots runs the board's full width.
    final width = _categories.length * cardWidth +
        (_categories.length - 1) * _dividerWidth;

    return Semantics(
      container: true,
      label: "${player.name}'s plate",
      child: Container(
        width: width,
        height: width / plateAspectRatio,
        color: colorScheme.surfaceContainer,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (index, category) in _categories.indexed) ...[
              if (index > 0) divider,
              slot(category),
            ],
          ],
        ),
      ),
    );
  }
}

/// The empty slot for [category], labelled with the category.
class _EmptySlot extends StatelessWidget {
  final engine.Category category;

  const _EmptySlot({required this.category});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '${category.label}, empty',
      child: EmptySlot(label: category.label),
    );
  }
}
