import 'package:flutter/widgets.dart';
import 'package:game_engine/game_engine.dart';

/// Exposes a [GameController] to the widgets below it, rebuilding the ones
/// that depend on it whenever the game changes.
///
/// Read the game and make moves on it with `GameScope.of(context)`. Since
/// the controller notifies its listeners of every change, including a card
/// placed directly on a player's plate, dependents rebuild however the game
/// is changed, e.g. by a tap, a computer opponent or the server.
class GameScope extends InheritedNotifier<_GameControllerListenable> {
  /// Exposes [controller] to [child].
  ///
  /// Pass a different controller, e.g. to start a new game, and dependents
  /// rebuild with it.
  GameScope({
    super.key,
    required GameController controller,
    required super.child,
  }) : super(notifier: _GameControllerListenable(controller));

  /// Returns the game of the closest [GameScope] above [context], and
  /// rebuilds [context] whenever the game changes.
  ///
  /// Throws a [FlutterError] if there is no [GameScope] above [context].
  static GameController of(BuildContext context) {
    final controller = maybeOf(context);

    if (controller == null) {
      throw FlutterError(
        'GameScope.of() called with a context that does not contain a '
        'GameScope.',
      );
    }

    return controller;
  }

  /// Returns the game of the closest [GameScope] above [context], or `null`
  /// if there isn't one, and rebuilds [context] whenever the game changes.
  static GameController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<GameScope>()
        ?.notifier
        ?.controller;
  }
}

/// Adapts a [GameController]'s listeners to a [Listenable], since the
/// engine is pure Dart and can't implement Flutter's interface itself.
///
/// Adapters for the same controller are equal, so rebuilding a [GameScope]
/// with the same controller doesn't rebuild its dependents.
class _GameControllerListenable implements Listenable {
  final GameController controller;

  const _GameControllerListenable(this.controller);

  @override
  void addListener(VoidCallback listener) {
    controller.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    controller.removeListener(listener);
  }

  @override
  bool operator ==(Object other) {
    return other is _GameControllerListenable &&
        identical(other.controller, controller);
  }

  @override
  int get hashCode => identityHashCode(controller);
}
