import 'package:flutter/foundation.dart';
import 'package:game_engine/game_engine.dart';

/// Wraps a [GameController] so the UI is told whenever a move is made.
///
/// Make moves through this notifier's methods, such as [drawFromDrawPile],
/// rather than on the [controller] itself, since only moves made through
/// the notifier notify its listeners. A move that throws, because it isn't
/// allowed, leaves the game as it was and doesn't notify them.
///
/// Whoever creates the notifier, typically the top-level `StatefulWidget`
/// that sets up the game, is responsible for calling [dispose].
class GameNotifier extends ChangeNotifier {
  /// The game, for reading its state.
  ///
  /// Make moves through this notifier's methods instead of on the
  /// controller, or listeners won't be notified.
  final GameController controller;

  GameNotifier(this.controller);

  /// Draws the top card of the draw pile, as
  /// [GameController.drawFromDrawPile] does.
  void drawFromDrawPile() => _play(controller.drawFromDrawPile);

  /// Draws the top card of the discard pile, as
  /// [GameController.drawFromDiscardPile] does.
  void drawFromDiscardPile() => _play(controller.drawFromDiscardPile);

  /// Places the drawn card on the current player's plate, as
  /// [GameController.placeDrawnCard] does.
  void placeDrawnCard() => _play(controller.placeDrawnCard);

  /// Discards the drawn card, as [GameController.discardDrawnCard] does.
  void discardDrawnCard() => _play(controller.discardDrawnCard);

  /// Makes [move] and, once it has succeeded, notifies the listeners.
  ///
  /// In debug builds, asserts that the notifier hasn't been disposed before
  /// making the move, so a move can't be made and then fail to notify.
  void _play(VoidCallback move) {
    assert(ChangeNotifier.debugAssertNotDisposed(this));
    move();
    notifyListeners();
  }
}
