import 'package:flutter/foundation.dart';
import 'package:game_engine/game_engine.dart' as engine;

/// A way of playing the drawn card, chosen with
/// [GameNotifier.startPlayingDrawnCard].
enum DrawnCardPlay {
  /// Places the card in its slot on the current player's plate, replacing
  /// the card in it, if any.
  place,

  /// Discards the card onto the discard pile.
  discard,
}

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

  DrawnCardPlay? _drawnCardPlay;

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

  /// How the drawn card is being played, having been chosen with
  /// [startPlayingDrawnCard], while it's on its way to its slot on the
  /// current player's plate or to the discard pile, or `null` if it isn't
  /// being played.
  ///
  /// It goes back to `null` once the next move is made.
  DrawnCardPlay? get drawnCardPlay => _drawnCardPlay;

  /// Draws the top card of the draw pile, as
  /// [engine.GameController.drawFromDrawPile] does.
  void drawFromDrawPile() => _play(_controller.drawFromDrawPile);

  /// Draws the top card of the discard pile, as
  /// [engine.GameController.drawFromDiscardPile] does.
  void drawFromDiscardPile() => _play(_controller.drawFromDiscardPile);

  /// Starts playing the drawn card as [play], setting [drawnCardPlay], then
  /// notifies the listeners, so that the card can be shown going to its
  /// slot on the plate or to the discard pile before [placeDrawnCard] or
  /// [discardDrawnCard] plays it.
  ///
  /// Placing the card ends the turn, unless it completes the player's meal,
  /// so the current player's plate is usually no longer shown once it has
  /// been placed.
  ///
  /// A `DrawnCard` must be shown to finish playing the card, by calling
  /// [placeDrawnCard] or [discardDrawnCard] once it's there.
  ///
  /// Does nothing if the drawn card is already being played.
  ///
  /// Throws a [StateError] without notifying the listeners if the drawn
  /// card can't be played as [play], or if the notifier has been disposed.
  void startPlayingDrawnCard(DrawnCardPlay play) {
    _requireNotDisposed();

    // Ignores a second choice made before the actions hide, e.g. Place and
    // Discard tapped in the same frame.
    if (_drawnCardPlay != null) {
      return;
    }

    final canPlay = switch (play) {
      DrawnCardPlay.place => _controller.canPlaceDrawnCard,
      DrawnCardPlay.discard => _controller.canDiscardDrawnCard,
    };

    if (!canPlay) {
      throw StateError('The drawn card cannot be played as ${play.name}');
    }

    _drawnCardPlay = play;
    notifyListeners();
  }

  /// Places the drawn card on the current player's plate, as
  /// [engine.GameController.placeDrawnCard] does.
  void placeDrawnCard() => _play(_controller.placeDrawnCard);

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
    _drawnCardPlay = null;
    notifyListeners();
  }

  /// Throws a [StateError] if the notifier has been disposed.
  void _requireNotDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot make a move once the GameNotifier is disposed');
    }
  }
}
