import 'package:flutter/widgets.dart';
import 'package:game_engine/game_engine.dart' as engine;

import 'game_notifier.dart';

/// Exposes a [GameNotifier] to the widgets below it, rebuilding the ones
/// that depend on it whenever a move is made through it.
///
/// Read the game with `GameScope.of(context).game`, and make moves
/// with the [GameNotifier] methods, such as [GameNotifier.drawFromDrawPile].
///
/// A widget that only shows part of the game can read just that part, with
/// e.g. [plateOf] or [currentPlayerOf], and is then only rebuilt when that
/// part changes, rather than after every move.
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
      throw _noGameScopeError('of');
    }

    return notifier;
  }

  /// Returns the notifier of the closest [GameScope] above [context], or
  /// `null` if there isn't one, and rebuilds [context] whenever a move is
  /// made through it.
  static GameNotifier? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<GameScope>()?.notifier;
  }

  /// Returns the plate of [player] in the game of the closest [GameScope]
  /// above [context], and rebuilds [context] only when that plate changes.
  ///
  /// Throws a [FlutterError] if there is no [GameScope] above [context], or
  /// an [ArgumentError] if [player] isn't playing in its game.
  static engine.Plate plateOf(BuildContext context, engine.Player player) {
    return _select(context, _PlateAspect(player), 'plateOf');
  }

  /// Returns the player whose turn it is in the game of the closest
  /// [GameScope] above [context], and rebuilds [context] only when the turn
  /// passes to another player.
  ///
  /// Throws a [FlutterError] if there is no [GameScope] above [context].
  static engine.Player currentPlayerOf(BuildContext context) {
    return _select(context, const _CurrentPlayerAspect(), 'currentPlayerOf');
  }

  /// Returns [aspect] of the game of the closest [GameScope] above [context],
  /// and rebuilds [context] only when it changes.
  ///
  /// Throws a [FlutterError], naming [method], if there is no [GameScope]
  /// above [context].
  static T _select<T>(
    BuildContext context,
    _Aspect<T> aspect,
    String method,
  ) {
    final scope = context.dependOnInheritedWidgetOfExactType<GameScope>(
      aspect: aspect,
    );

    if (scope == null) {
      throw _noGameScopeError(method);
    }

    return aspect.select(scope.notifier!.game);
  }

  static FlutterError _noGameScopeError(String method) {
    return FlutterError(
      'GameScope.$method() called with a context that does not contain a GameScope.',
    );
  }

  @override
  InheritedElement createElement() => _GameScopeElement(this);
}

/// A part of the game that a widget can depend on, so that it is only
/// rebuilt when that part changes.
///
/// Equal aspects must select the same part, so that a widget that reads the
/// same part on every build depends on it once.
sealed class _Aspect<T> {
  const _Aspect();

  /// Returns this part of [game], which is compared with `==` to the part
  /// as it was to tell whether it has changed.
  T select(engine.Game game);
}

/// The plate of [player].
final class _PlateAspect extends _Aspect<engine.Plate> {
  final engine.Player player;

  const _PlateAspect(this.player);

  @override
  engine.Plate select(engine.Game game) => game.plateOf(player);

  @override
  bool operator ==(Object other) =>
      other is _PlateAspect && identical(other.player, player);

  @override
  int get hashCode => identityHashCode(player);
}

/// The player whose turn it is.
final class _CurrentPlayerAspect extends _Aspect<engine.Player> {
  const _CurrentPlayerAspect();

  @override
  engine.Player select(engine.Game game) => game.currentPlayer;

  @override
  bool operator ==(Object other) => other is _CurrentPlayerAspect;

  @override
  int get hashCode => (_CurrentPlayerAspect).hashCode;
}

/// The parts of the game that a dependent depends on, each with its value
/// as of when the dependent last read or was rebuilt for it.
///
/// A dependent with [isWhole] set depends on the whole game, and is rebuilt
/// after every move.
class _Dependencies {
  bool isWhole = false;

  final Map<_Aspect<Object?>, Object?> values = {};
}

/// The element of a [GameScope], which listens to its notifier like an
/// [InheritedNotifier]'s, but only rebuilds a dependent that read aspects
/// of the game when one of them changes.
class _GameScopeElement extends InheritedElement {
  bool _isDirty = false;

  _GameScopeElement(GameScope super.widget) {
    _notifier.addListener(_handleUpdate);
  }

  GameNotifier get _notifier => (widget as GameScope).notifier!;

  @override
  void update(GameScope newWidget) {
    final oldNotifier = _notifier;
    final newNotifier = newWidget.notifier!;

    if (oldNotifier != newNotifier) {
      oldNotifier.removeListener(_handleUpdate);
      newNotifier.addListener(_handleUpdate);
    }

    super.update(newWidget);
  }

  @override
  Widget build() {
    if (_isDirty) {
      notifyClients(widget as GameScope);
    }

    return super.build();
  }

  @override
  void notifyClients(GameScope oldWidget) {
    super.notifyClients(oldWidget);
    _isDirty = false;
  }

  @override
  void updateDependencies(Element dependent, Object? aspect) {
    final dependencies =
        getDependencies(dependent) as _Dependencies? ?? _Dependencies();

    if (aspect == null) {
      dependencies.isWhole = true;
    } else {
      aspect as _Aspect<Object?>;
      dependencies.values[aspect] = aspect.select(_notifier.game);
    }

    setDependencies(dependent, dependencies);
  }

  @override
  void notifyDependent(GameScope oldWidget, Element dependent) {
    final dependencies = getDependencies(dependent) as _Dependencies?;

    if (dependencies == null) {
      return;
    }

    if (dependencies.isWhole) {
      dependent.didChangeDependencies();
      return;
    }

    // A new notifier is a new game, which the old aspects may not be part
    // of, e.g. the plate of a player who isn't playing in it, so they are
    // forgotten, and the dependent depends again on what it reads as it
    // rebuilds.
    if (oldWidget.notifier != _notifier) {
      dependencies.values.clear();
      dependent.didChangeDependencies();
      return;
    }

    final game = _notifier.game;
    var hasChanged = false;

    for (final aspect in dependencies.values.keys.toList()) {
      final value = aspect.select(game);

      if (value != dependencies.values[aspect]) {
        dependencies.values[aspect] = value;
        hasChanged = true;
      }
    }

    if (hasChanged) {
      // Forgets what the dependent read, which it reads again as it
      // rebuilds, so that it stops depending on what it no longer reads.
      dependencies.values.clear();
      dependent.didChangeDependencies();
    }
  }

  void _handleUpdate() {
    _isDirty = true;
    markNeedsBuild();
  }

  @override
  void unmount() {
    _notifier.removeListener(_handleUpdate);
    super.unmount();
  }
}
