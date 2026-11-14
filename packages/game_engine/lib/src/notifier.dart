import 'dart:async';

import 'package:meta/meta.dart';

/// Lets listeners be told whenever an object changes.
///
/// This is a pure Dart counterpart to Flutter's `ChangeNotifier`, so the
/// engine can be listened to by the Flutter client and the server alike.
mixin Notifier {
  final List<void Function()> _listeners = [];

  /// Calls [listener] whenever this object changes.
  ///
  /// Adding the same listener more than once means it's called once per
  /// time it was added.
  void addListener(void Function() listener) {
    _listeners.add(listener);
  }

  /// Stops calling [listener] when this object changes, once for each time
  /// it was added.
  ///
  /// Does nothing if [listener] isn't listening.
  void removeListener(void Function() listener) {
    _listeners.remove(listener);
  }

  /// Calls every listener, in the order they were added.
  ///
  /// A listener added or removed while the listeners are being called
  /// doesn't change which ones are called this time. An error thrown by a
  /// listener is reported to the current [Zone] rather than rethrown, so
  /// the other listeners are still called and the change that's being
  /// notified isn't treated as having failed.
  @protected
  void notifyListeners() {
    for (final listener in List.of(_listeners)) {
      try {
        listener();
      } catch (error, stackTrace) {
        Zone.current.handleUncaughtError(error, stackTrace);
      }
    }
  }
}
