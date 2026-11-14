import 'package:flutter/widgets.dart';

import 'game_notifier.dart';

/// Exposes a [GameNotifier] to the widgets below it, rebuilding the ones
/// that depend on it whenever a move is made through it.
///
/// Read the game with `GameScope.of(context).controller`, and make moves
/// with the [GameNotifier] methods, such as [GameNotifier.drawFromDrawPile].
class GameScope extends InheritedNotifier<GameNotifier> {
  /// Exposes [notifier] to [child].
  ///
  /// Pass a different notifier, e.g. to start a new game, and dependents
  /// rebuild with it.
  const GameScope({
    super.key,
    required GameNotifier super.notifier,
    required super.child,
  });

  /// Returns the notifier of the closest [GameScope] above [context], and
  /// rebuilds [context] whenever a move is made through it.
  ///
  /// Throws a [FlutterError] if there is no [GameScope] above [context].
  static GameNotifier of(BuildContext context) {
    final notifier = maybeOf(context);

    if (notifier == null) {
      throw FlutterError(
        'GameScope.of() called with a context that does not contain a GameScope.',
      );
    }

    return notifier;
  }

  /// Returns the notifier of the closest [GameScope] above [context], or
  /// `null` if there isn't one, and rebuilds [context] whenever a move is
  /// made through it.
  static GameNotifier? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GameScope>()?.notifier;
  }
}
