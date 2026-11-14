import 'dart:async';

/// The listeners to be told whenever an object changes.
///
/// An object keeps this privately and exposes only `addListener` and
/// `removeListener`, so only the object itself can notify its listeners.
/// This is internal to the engine and isn't exported, which keeps the
/// engine free of dependencies, including Flutter's `ChangeNotifier`.
class Listeners {
  final List<void Function()> _listeners = [];

  /// Calls [listener] on every [notify].
  ///
  /// Adding the same listener more than once means it's called once per
  /// time it was added.
  void add(void Function() listener) {
    _listeners.add(listener);
  }

  /// Stops calling [listener] on [notify], once for each time it was added.
  ///
  /// Does nothing if [listener] isn't listening.
  void remove(void Function() listener) {
    _listeners.remove(listener);
  }

  /// Calls every listener, in the order they were added.
  ///
  /// A listener added or removed while the listeners are being called
  /// doesn't change which ones are called this time. An error thrown by a
  /// listener is reported to the current [Zone] rather than rethrown, so
  /// the other listeners are still called and the change that's being
  /// notified isn't treated as having failed.
  void notify() {
    for (final listener in List.of(_listeners)) {
      try {
        listener();
      } catch (error, stackTrace) {
        Zone.current.handleUncaughtError(error, stackTrace);
      }
    }
  }
}
