import 'dart:math';

import 'package:material_ui/material_ui.dart';

/// Reveals that [child], a card, is Spoiled, by shaking it a few times
/// over [duration], settling as it ends, with a "Spoiled!" callout across
/// it in the `displaySmall` text style, which is reserved for it.
///
/// It shakes from when it's first shown, so show it as the card is
/// revealed. It doesn't shake if animations are disabled.
///
/// The callout is left out of the semantics tree, since it's only for
/// show, so whoever shows the card should announce that it's Spoiled.
class SpoiledReveal extends StatelessWidget {
  /// How long the card shakes for.
  final Duration duration;

  /// The card being revealed.
  final Widget child;

  /// Reveals that [child] is Spoiled, shaking it for [duration].
  const SpoiledReveal({
    super.key,
    required this.duration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration:
          MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration,
      builder: (context, value, child) {
        return Transform.translate(
          // Shakes a few times, settling as it ends.
          offset: Offset(sin(value * 4 * 2 * pi) * 8 * (1 - value), 0),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          child,
          ExcludeSemantics(
            // Lets the callout be wider than the card.
            child: OverflowBox(
              maxWidth: double.infinity,
              child: Transform.rotate(
                angle: -pi / 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      'Spoiled!',
                      // Keeps the callout from outgrowing the screen with a
                      // larger text size, since it's only for show.
                      textScaler: TextScaler.noScaling,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
