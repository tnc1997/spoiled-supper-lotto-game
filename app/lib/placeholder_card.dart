import 'package:game_engine/game_engine.dart';
import 'package:material_ui/material_ui.dart' hide Card;

import 'category_color.dart';
import 'category_label.dart';

/// The default, original artwork for a [card]: a plain card in its
/// category's colour, with its name and category as text.
///
/// Spoiled cards use a muted version of the colour and are tagged
/// "Spoiled", so they can be told apart without relying on colour alone.
///
/// The card is laid out at [size] and then scaled, keeping its shape, to
/// fit the space its parent allows. In an unbounded parent it shows at
/// [size].
///
/// The text follows the system text scale until it fills the card, and is
/// then shrunk to fit.
class PlaceholderCard extends StatelessWidget {
  /// The size the card is laid out at, before it is scaled to fit.
  static const size = Size(100, 140);

  static const _border = 2.5;

  static const _padding = 8.0;

  /// The card to show.
  final Card card;

  /// Shows [card].
  const PlaceholderCard({super.key, required this.card});

  bool get _isSpoiled => card.type == CardType.spoiled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    var base = HSLColor.fromColor(card.category.color);
    if (_isSpoiled) {
      base = base.withSaturation(base.saturation * 0.6);
    }

    final background = Color.lerp(Colors.white, base.toColor(), 0.35)!;
    final border = base.withLightness(0.35).toColor();
    final foreground = base.withLightness(0.2).toColor();

    final caption = textTheme.labelSmall?.copyWith(
      color: foreground,
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: [
        card.name,
        card.category.label,
        if (_isSpoiled) 'Spoiled',
      ].join(', '),
      // Scales the whole card to fit its parent.
      child: FittedBox(
        child: Container(
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.all(_padding),
          decoration: BoxDecoration(
            color: background,
            border: Border.all(color: border, width: _border),
            borderRadius: BorderRadius.circular(8),
          ),
          // Shrinks the text only if it doesn't fit, e.g. at a large system
          // text scale.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              // The container's padding includes its border.
              width: size.width - 2 * (_border + _padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSpoiled) Text('SPOILED', style: caption),
                  Text(
                    card.name,
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                  Text(card.category.label, style: caption),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
