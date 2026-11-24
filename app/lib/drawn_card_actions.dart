import 'package:material_ui/material_ui.dart';

import 'game_scope.dart';

/// Offers the current player, from the closest [GameScope], a choice of how
/// to play the card they have drawn: to place it, replacing the card in its
/// slot on their plate, or to discard it.
///
/// The player only has a choice for a standard card whose slot is already
/// filled, until they choose to place or discard it, which starts it on its
/// way to their plate or the discard pile. The rest of the time, the
/// actions keep their space, hidden and disabled, so that nothing around
/// them moves when they show.
class DrawnCardActions extends StatelessWidget {
  /// Shows the actions for the drawn card.
  const DrawnCardActions({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = GameScope.of(context);
    final game = notifier.game;
    final hasChoice = game.canPlaceDrawnCard &&
        game.canDiscardDrawnCard &&
        !notifier.isPlacingDrawnCard &&
        !notifier.isDiscardingDrawnCard;

    return Visibility(
      visible: hasChoice,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          // Disabled while hidden, so that they can't be focused.
          FilledButton(
            onPressed: hasChoice ? notifier.startPlacingDrawnCard : null,
            child: const Text('Place'),
          ),
          OutlinedButton(
            onPressed: hasChoice ? notifier.startDiscardingDrawnCard : null,
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
