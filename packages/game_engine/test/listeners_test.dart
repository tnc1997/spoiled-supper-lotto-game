import 'dart:async';

import 'package:game_engine/src/listeners.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Listeners',
    () {
      late Listeners listeners;
      late List<String> calls;

      setUp(
        () {
          listeners = Listeners();
          calls = [];
        },
      );

      test(
        'calls each listener in the order they were added',
        () {
          listeners
            ..add(() => calls.add('first'))
            ..add(() => calls.add('second'));

          listeners.notify();

          expect(calls, ['first', 'second']);
        },
      );

      test(
        'calls a listener once for each time it was added',
        () {
          void listener() => calls.add('listener');
          listeners
            ..add(listener)
            ..add(listener);

          listeners.notify();

          expect(calls, ['listener', 'listener']);
        },
      );

      test(
        'stops calling a listener once for each time it was removed',
        () {
          void listener() => calls.add('listener');
          listeners
            ..add(listener)
            ..add(listener)
            ..remove(listener);

          listeners.notify();

          expect(calls, ['listener']);
        },
      );

      test(
        'does nothing when removing a listener that is not listening',
        () {
          listeners.remove(() {});

          expect(listeners.notify, returnsNormally);
        },
      );

      test(
        'does not call listeners added while notifying until next time',
        () {
          listeners.add(
            () {
              calls.add('first');
              listeners.add(() => calls.add('added'));
            },
          );

          listeners.notify();

          expect(calls, ['first']);
        },
      );

      test(
        'still calls listeners removed while notifying until next time',
        () {
          void second() => calls.add('second');
          listeners
            ..add(
              () {
                calls.add('first');
                listeners.remove(second);
              },
            )
            ..add(second);

          listeners.notify();

          expect(calls, ['first', 'second']);
        },
      );

      test(
        'reports an error thrown by a listener and calls the rest',
        () {
          final errors = <Object>[];
          final error = StateError('listener failed');
          listeners
            ..add(() => throw error)
            ..add(() => calls.add('second'));

          runZonedGuarded(
            listeners.notify,
            (error, stackTrace) => errors.add(error),
          );

          expect(errors, [error]);
          expect(calls, ['second']);
        },
      );
    },
  );
}
