import 'dart:async';

import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

class _Counter with Notifier {
  void increment() => notifyListeners();
}

void main() {
  group(
    'Notifier',
    () {
      late _Counter counter;
      late List<String> calls;

      setUp(
        () {
          counter = _Counter();
          calls = [];
        },
      );

      test(
        'calls each listener in the order they were added',
        () {
          counter
            ..addListener(() => calls.add('first'))
            ..addListener(() => calls.add('second'));

          counter.increment();

          expect(calls, ['first', 'second']);
        },
      );

      test(
        'calls a listener once for each time it was added',
        () {
          void listener() => calls.add('listener');
          counter
            ..addListener(listener)
            ..addListener(listener);

          counter.increment();

          expect(calls, ['listener', 'listener']);
        },
      );

      test(
        'stops calling a listener once for each time it was removed',
        () {
          void listener() => calls.add('listener');
          counter
            ..addListener(listener)
            ..addListener(listener)
            ..removeListener(listener);

          counter.increment();

          expect(calls, ['listener']);
        },
      );

      test(
        'does nothing when removing a listener that is not listening',
        () {
          counter.removeListener(() {});

          expect(counter.increment, returnsNormally);
        },
      );

      test(
        'does not call listeners added while notifying until next time',
        () {
          counter.addListener(
            () {
              calls.add('first');
              counter.addListener(() => calls.add('added'));
            },
          );

          counter.increment();

          expect(calls, ['first']);
        },
      );

      test(
        'still calls listeners removed while notifying until next time',
        () {
          void second() => calls.add('second');
          counter
            ..addListener(
              () {
                calls.add('first');
                counter.removeListener(second);
              },
            )
            ..addListener(second);

          counter.increment();

          expect(calls, ['first', 'second']);
        },
      );

      test(
        'reports an error thrown by a listener and calls the rest',
        () {
          final errors = <Object>[];
          final error = StateError('listener failed');
          counter
            ..addListener(() => throw error)
            ..addListener(() => calls.add('second'));

          runZonedGuarded(
            counter.increment,
            (error, stackTrace) => errors.add(error),
          );

          expect(errors, [error]);
          expect(calls, ['second']);
        },
      );
    },
  );
}
