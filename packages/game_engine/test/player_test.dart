import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Player',
    () {
      test(
        'exposes its name',
        () {
          final player = Player(name: 'Alice');

          expect(player.name, 'Alice');
        },
      );

      test(
        'defaults to not being a computer opponent',
        () {
          final player = Player(name: 'Alice');

          expect(player.isAi, isFalse);
        },
      );

      test(
        'can be marked as a computer opponent',
        () {
          final player = Player(name: 'Computer', isAi: true);

          expect(player.isAi, isTrue);
        },
      );
    },
  );
}
