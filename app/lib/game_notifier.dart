import 'package:flutter/foundation.dart';
import 'package:game_engine/game_engine.dart' as engine;

/// Wraps a [engine.GameController] so the UI is told whenever a move is made.
///
/// Read the game through [game], and make moves through this notifier's
/// methods, such as [drawFromDrawPile], which notify its listeners. A move
/// that throws, because it isn't allowed, leaves the game as it was and
/// doesn't notify them.
///
/// Whoever creates the notifier, typically the top-level `StatefulWidget`
/// that sets up the game, is responsible for calling [dispose].
class GameNotifier extends ChangeNotifier {
  final engine.GameController _controller;

  bool _isDisposed = false;

  bool _isPlacingDrawnCard = false;

  bool _isDiscardingDrawnCard = false;

  /// Wraps [controller], which should then only be changed through this
  /// notifier.
  GameNotifier(engine.GameController controller) : _controller = controller;

  /// The game, for reading its state.
  ///
  /// This is the game's current state, so read it from here each time it's
  /// needed, such as on each build, rather than holding on to it or what it
  /// returns. Don't cast it back to the [engine.GameController] to make a move,
  /// since only moves made through this notifier notify its listeners.
  engine.Game get game => _controller;

  /// Whether the drawn card is on its way to its slot on the current
  /// player's plate, having been chosen to be placed with
  /// [startPlacingDrawnCard], but isn't placed yet.
  ///
  /// It goes back to `false` once the next move is made.
  bool get isPlacingDrawnCard => _isPlacingDrawnCard;

  /// Whether the drawn card is on its way to the discard pile, having been
  /// chosen to be discarded with [startDiscardingDrawnCard], but isn't
  /// discarded yet.
  ///
  /// It goes back to `false` once the next move is made.
  bool get isDiscardingDrawnCard => _isDiscardingDrawnCard;

  /// Draws the top card of the draw pile, as
  /// [engine.GameController.drawFromDrawPile] does.
  void drawFromDrawPile() => _play(_controller.drawFromDrawPile);

  /// Draws the top card of the discard pile, as
  /// [engine.GameController.drawFromDiscardPile] does.
  void drawFromDiscardPile() => _play(_controller.drawFromDiscardPile);

  /// Starts placing the drawn card on the current player's plate, setting
  /// [isPlacingDrawnCard], then notifies the listeners, so that the card
  /// can be shown going to its slot before [placeDrawnCard] places it.
  ///
  /// Placing the card ends the turn, unless it completes the player's meal,
  /// so the current player's plate is usually no longer shown once it has
  /// been placed.
  ///
  /// A `DrawnCard` must be shown to finish placing the card, by calling
  /// [placeDrawnCard] once it's in its slot.
  ///
  /// Throws a [StateError] without notifying the listeners if the drawn
  /// card can't be placed, or if the notifier has been disposed.
  void startPlacingDrawnCard() {
    _requireNotDisposed();

    if (!_controller.canPlaceDrawnCard) {
      throw StateError('The drawn card cannot be placed');
    }

    _isPlacingDrawnCard = true;
    notifyListeners();
  }

  /// Places the drawn card on the current player's plate, as
  /// [engine.GameController.placeDrawnCard] does.
  void placeDrawnCard() => _play(_controller.placeDrawnCard);

  /// Starts discarding the drawn card, setting [isDiscardingDrawnCard],
  /// then notifies the listeners, so that the card can be shown going to
  /// the discard pile before [discardDrawnCard] discards it.
  ///
  /// A `DrawnCard` must be shown to finish discarding the card, by calling
  /// [discardDrawnCard] once it's on the discard pile.
  ///
  /// Throws a [StateError] without notifying the listeners if the drawn
  /// card can't be discarded, or if the notifier has been disposed.
  void startDiscardingDrawnCard() {
    _requireNotDisposed();

    if (!_controller.canDiscardDrawnCard) {
      throw StateError('The drawn card cannot be discarded');
    }

    _isDiscardingDrawnCard = true;
    notifyListeners();
  }

  /// Discards the drawn card, as [engine.GameController.discardDrawnCard] does.
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
    _requireNotDisposed();

    move();
    _isPlacingDrawnCard = false;
    _isDiscardingDrawnCard = false;
    notifyListeners();
  }

  /// Throws a [StateError] if the notifier has been disposed.
  void _requireNotDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot make a move once the GameNotifier is disposed');
    }
  }
}
