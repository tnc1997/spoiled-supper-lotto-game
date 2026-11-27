import 'package:game_engine/game_engine.dart' as engine;

import 'game_notifier.dart';

/// A drawn card that a player has placed or discarded, as recorded in
/// [GameNotifier.playedCards].
class PlayedCard {
  /// The player who played the card.
  final engine.Player player;

  /// The card that was played.
  final engine.Card card;

  /// How the card was played.
  final DrawnCardPlay play;

  /// Records that [player] played [card] as [play].
  const PlayedCard({
    required this.player,
    required this.card,
    required this.play,
  });

  /// What happened, e.g. `Alice placed Sausages` or
  /// `Alice discarded Fish Bone`.
  String get description {
    final verb = switch (play) {
      DrawnCardPlay.place => 'placed',
      DrawnCardPlay.discard => 'discarded',
    };

    return '${player.name} $verb ${card.name}';
  }
}
