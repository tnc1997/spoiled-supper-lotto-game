import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

import 'category_color.dart';
import 'category_label.dart';

/// The default, original artwork for a [card]: a plain card in its
/// category's colour, with its name and category as text.
///
/// Spoiled cards use a muted version of the colour and are tagged
/// "Spoiled", so they can be told apart without relying on colour alone.
///
/// The card keeps a playing-card shape ([aspectRatio]) and fills the width
/// its parent allows, scaling its text with it. Its parent must bound its
/// width or its height, e.g. with a [SizedBox] or [Expanded].
///
/// The text is sized by the card rather than by the system text scale, so
/// that it always fits on the card.
class PlaceholderCard extends StatelessWidget {
  /// The width of the card divided by its height.
  static const aspectRatio = 5 / 7;

  /// The card to show.
  final engine.Card card;

  /// Shows [card].
  const PlaceholderCard({super.key, required this.card});

  bool get _isSpoiled => card.type == engine.CardType.spoiled;

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

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: [
        card.name,
        card.category.label,
        if (_isSpoiled) 'Spoiled',
      ].join(', '),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final tagLetterSpacing = width * 0.01;
            final captionStyle = textTheme.labelSmall?.copyWith(
              color: foreground,
              fontSize: width * 0.09,
              fontWeight: FontWeight.w600,
            );

            return DecoratedBox(
              decoration: BoxDecoration(
                color: background,
                border: Border.all(color: border, width: width * 0.025),
                borderRadius: BorderRadius.circular(width * 0.08),
              ),
              child: Padding(
                padding: EdgeInsets.all(width * 0.08),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSpoiled)
                      // Letter spacing is also added after the last letter,
                      // so balance it on the left to keep the tag centred.
                      Padding(
                        padding: EdgeInsets.only(left: tagLetterSpacing),
                        child: Text(
                          'SPOILED',
                          textScaler: TextScaler.noScaling,
                          style: captionStyle?.copyWith(
                            letterSpacing: tagLetterSpacing,
                          ),
                        ),
                      ),
                    Text(
                      card.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      textScaler: TextScaler.noScaling,
                      style: textTheme.titleMedium?.copyWith(
                        color: foreground,
                        fontSize: width * 0.14,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      card.category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textScaler: TextScaler.noScaling,
                      style: captionStyle,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
