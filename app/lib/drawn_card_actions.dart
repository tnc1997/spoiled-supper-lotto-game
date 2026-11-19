import 'package:material_ui/material_ui.dart';

import 'card_flip_duration.dart';
import 'game_scope.dart';

/// Offers the current player, from the closest [GameScope], a choice of how
/// to play the card they have drawn: to place it, replacing the card in its
/// slot on their plate, or to discard it.
///
/// The player only has a choice for a standard card whose slot is already
/// filled. The actions show once the `DrawnCard` has turned face up, after
/// [cardFlipDuration], and keep their space, hidden and disabled, the rest
/// of the time, so that nothing around them moves when they show.
class DrawnCardActions extends StatelessWidget {
  /// Shows the actions for the drawn card.
  const DrawnCardActions({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = GameScope.of(context);
    final game = notifier.game;
    final card = game.drawnCard;
    final hasChoice =
        card != null && game.canPlaceDrawnCard && game.canDiscardDrawnCard;

    Widget actions({required bool visible}) {
      return Visibility(
        visible: visible,
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
              onPressed: visible ? notifier.placeDrawnCard : null,
              child: const Text('Place'),
            ),
            OutlinedButton(
              onPressed: visible ? notifier.discardDrawnCard : null,
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    }

    if (!hasChoice || MediaQuery.disableAnimationsOf(context)) {
      return actions(visible: hasChoice);
    }

    // Waits for the card to turn face up before showing the actions.
    return TweenAnimationBuilder<double>(
      key: ObjectKey(card),
      tween: Tween(begin: 0, end: 1),
      duration: cardFlipDuration,
      builder: (context, progress, child) => actions(visible: progress == 1),
    );
  }
}
