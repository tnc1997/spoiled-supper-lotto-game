import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Player',
    () {
      group(
        'name',
        () {
          test(
            'is the name it was created with',
            () {
              final player = Player(name: 'Alice');

              expect(player.name, 'Alice');
            },
          );
        },
      );

      group(
        'isAi',
        () {
          test(
            'defaults to false',
            () {
              final player = Player(name: 'Alice');

              expect(player.isAi, isFalse);
            },
          );

          test(
            'is true when marked as a computer opponent',
            () {
              final player = Player(name: 'Computer', isAi: true);

              expect(player.isAi, isTrue);
            },
          );
        },
      );
    },
  );
}
