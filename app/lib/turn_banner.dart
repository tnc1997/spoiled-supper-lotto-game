import 'package:material_ui/material_ui.dart';

import 'game_scope.dart';
import 'heading.dart';

/// Shows whose turn it is in the game of the closest [GameScope], e.g.
/// "Sam's turn", above every player's name in turn order, with the current
/// player's name highlighted.
///
/// The text is in the theme's `headlineSmall` style, and is marked as a
/// header and a live region, so that a screen reader announces it whenever
/// the turn passes to the next player. The current player's name is
/// announced as selected.
class TurnBanner extends StatelessWidget {
  /// Shows whose turn it is.
  const TurnBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final game = GameScope.of(context).game;
    final currentPlayer = game.currentPlayer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 12,
      children: [
        Semantics(
          liveRegion: true,
          child: Heading(
            "${currentPlayer.name}'s turn",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final player in game.players)
              _PlayerName(
                name: player.name,
                isCurrent: identical(player, currentPlayer),
              ),
          ],
        ),
      ],
    );
  }
}

/// A player's name in a [TurnBanner], highlighted while it is their turn.
class _PlayerName extends StatelessWidget {
  /// The name of the player.
  final String name;

  /// Whether it is the player's turn.
  final bool isCurrent;

  /// Shows [name], highlighted if [isCurrent].
  const _PlayerName({required this.name, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      selected: isCurrent,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: isCurrent ? colorScheme.primaryContainer : null,
          shape: StadiumBorder(
            side: BorderSide(
              color: isCurrent ? colorScheme.primary : colorScheme.outline,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            name,
            style: theme.textTheme.labelLarge?.copyWith(
              color: isCurrent
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
