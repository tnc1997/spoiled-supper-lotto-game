import 'package:flutter/widgets.dart';
import 'package:game_engine/game_engine.dart';

/// Exposes a [GameController] to the widgets below it, rebuilding the ones
/// that depend on it after each move.
///
/// Read the game's state with `GameScope.of(context).controller`, and make
/// moves through the [GameScopeState] methods, such as
/// [GameScopeState.drawFromDrawPile], rather than on the controller itself,
/// since only moves made through the scope rebuild its dependents.
class GameScope extends StatefulWidget {
  /// The game whose state is exposed to [child].
  ///
  /// Pass a different controller, e.g. to start a new game, and dependents
  /// rebuild with it.
  final GameController controller;

  /// The widget below this one in the tree.
  final Widget child;

  const GameScope({
    super.key,
    required this.controller,
    required this.child,
  });

  /// Returns the state of the closest [GameScope] above [context], and
  /// rebuilds [context] whenever the game changes.
  ///
  /// Throws a [FlutterError] if there is no [GameScope] above [context].
  static GameScopeState of(BuildContext context) {
    final state = maybeOf(context);

    if (state == null) {
      throw FlutterError(
        'GameScope.of() called with a context that does not contain a '
        'GameScope.',
      );
    }

    return state;
  }

  /// Returns the state of the closest [GameScope] above [context], or
  /// `null` if there isn't one, and rebuilds [context] whenever the game
  /// changes.
  static GameScopeState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_GameInheritedScope>()
        ?.state;
  }

  @override
  State<GameScope> createState() => GameScopeState();
}

/// The state of a [GameScope], through which moves are made so that the
/// widgets depending on it rebuild.
///
/// A move that throws, because it isn't allowed, leaves the game as it was
/// and doesn't rebuild anything.
class GameScopeState extends State<GameScope> {
  int _revision = 0;

  /// The game, for reading its state.
  ///
  /// Make moves through this state's methods instead of on the controller,
  /// or dependents won't rebuild.
  GameController get controller => widget.controller;

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

  @override
  Widget build(BuildContext context) {
    return _GameInheritedScope(
      state: this,
      controller: controller,
      revision: _revision,
      child: widget.child,
    );
  }

  /// Makes [move] and, once it has succeeded, rebuilds the dependents.
  void _play(VoidCallback move) {
    move();
    setState(() => _revision++);
  }
}

/// Notifies the dependents of a [GameScope] when its controller is
/// replaced or a move is made through it.
class _GameInheritedScope extends InheritedWidget {
  final GameScopeState state;
  final GameController controller;
  final int revision;

  const _GameInheritedScope({
    required this.state,
    required this.controller,
    required this.revision,
    required super.child,
  });

  @override
  bool updateShouldNotify(_GameInheritedScope oldWidget) {
    return controller != oldWidget.controller || revision != oldWidget.revision;
  }
}
