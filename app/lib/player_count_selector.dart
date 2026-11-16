import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

/// Lets the players choose how many of them are playing, from
/// [engine.GameController.minPlayers] to [engine.GameController.maxPlayers].
class PlayerCountSelector extends StatelessWidget {
  /// The number of players currently chosen.
  final int playerCount;

  /// Called with the newly chosen number of players, or `null` to disable
  /// the selector.
  final ValueChanged<int>? onChanged;

  /// Shows [playerCount] as chosen, calling [onChanged] when another number
  /// of players is chosen.
  const PlayerCountSelector({
    super.key,
    required this.playerCount,
    this.onChanged,
  }) : assert(
          playerCount >= engine.GameController.minPlayers &&
              playerCount <= engine.GameController.maxPlayers,
        );

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;

    return Semantics(
      label: 'Number of players',
      container: true,
      child: SegmentedButton<int>(
        segments: [
          for (var count = engine.GameController.minPlayers;
              count <= engine.GameController.maxPlayers;
              count++)
            ButtonSegment(
              value: count,
              label: Text('$count players'),
              enabled: onChanged != null,
            ),
        ],
        selected: {playerCount},
        onSelectionChanged: onChanged == null
            ? null
            : (selection) => onChanged(selection.single),
      ),
    );
  }
}
