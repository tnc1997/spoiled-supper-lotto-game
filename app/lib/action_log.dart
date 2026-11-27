import 'package:material_ui/material_ui.dart';

import 'game_notifier.dart';
import 'game_scope.dart';

/// Shows the most recent cards played in the game in the closest
/// [GameScope], newest first, e.g. "Alice placed Sausages", in the
/// `bodyMedium` text style.
///
/// It keeps space for [length] lines, even before that many cards have
/// been played, so that nothing around it moves as the log fills up.
///
/// Each card played is kept to one line, so that a long one doesn't wrap
/// and move what's around it, but is announced in full.
///
/// It isn't a live region, since a new card played usually passes the turn
/// too, so whoever shows whose turn it is should announce the newest card
/// played along with it, in the same announcement, from
/// [GameNotifier.playedCards]. The newest card is left out of the semantics
/// tree, so that it isn't read twice in a row.
class ActionLog extends StatelessWidget {
  /// How many of the most recent cards played are shown.
  static const length = 3;

  /// Shows the most recent cards played.
  const ActionLog({super.key});

  @override
  Widget build(BuildContext context) {
    final playedCards =
        GameScope.of(context).playedCards.reversed.take(length).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < length; i++)
          ExcludeSemantics(
            excluding: i == 0,
            child: Text(
              i < playedCards.length ? playedCards[i].description : '',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}
