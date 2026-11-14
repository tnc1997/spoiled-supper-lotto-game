import 'package:flutter/foundation.dart';
import 'package:game_engine/game_engine.dart';

/// Wraps a [GameController] so the UI is told whenever a move is made.
///
/// Read the game through [game], and make moves through this notifier's
/// methods, such as [drawFromDrawPile], which notify its listeners. A move
/// that throws, because it isn't allowed, leaves the game as it was and
/// doesn't notify them.
///
/// Whoever creates the notifier, typically the top-level `StatefulWidget`
/// that sets up the game, is responsible for calling [dispose].
class GameNotifier extends ChangeNotifier {
  final GameController _controller;

  bool _isDisposed = false;

  /// Wraps [controller], which should then only be changed through this
  /// notifier.
  GameNotifier(GameController controller) : _controller = controller;

  /// The game, for reading its state.
  ///
  /// This is the game's current state, so read it from here each time it's
  /// needed, such as on each build, rather than holding on to it or what it
  /// returns. Don't cast it back to the [GameController] to make a move,
  /// since only moves made through this notifier notify its listeners.
  Game get game => _controller;

  /// Draws the top card of the draw pile, as
  /// [GameController.drawFromDrawPile] does.
  void drawFromDrawPile() => _play(_controller.drawFromDrawPile);

  /// Draws the top card of the discard pile, as
  /// [GameController.drawFromDiscardPile] does.
  void drawFromDiscardPile() => _play(_controller.drawFromDiscardPile);

  /// Places the drawn card on the current player's plate, as
  /// [GameController.placeDrawnCard] does.
  void placeDrawnCard() => _play(_controller.placeDrawnCard);

  /// Discards the drawn card, as [GameController.discardDrawnCard] does.
  void discardDrawnCard() => _play(_controller.discardDrawnCard);

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Makes [move] and, once it has succeeded, notifies the listeners.
  ///
  /// Throws a [StateError] without making the move if the notifier has been
  /// disposed, so a move can't be made and then fail to notify.
  void _play(VoidCallback move) {
    if (_isDisposed) {
      throw StateError('Cannot make a move once the GameNotifier is disposed');
    }

    move();
    notifyListeners();
  }
}
