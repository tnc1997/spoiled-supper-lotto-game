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
        'defaults to an empty plate',
        () {
          final player = Player(name: 'Alice');

          expect(player.plate.isFull, isFalse);
        },
      );

      test(
        'can be marked as a computer opponent',
        () {
          final player = Player(name: 'Computer', isAi: true);

          expect(player.isAi, isTrue);
        },
      );

      test(
        'each player gets its own independent default plate',
        () {
          final alice = Player(name: 'Alice');
          final bob = Player(name: 'Bob');

          alice.plate.place(
            const Card(
              id: '1',
              type: CardType.standard,
              category: Category.main,
              name: 'Sausages',
            ),
          );

          expect(alice.plate[Category.main], isNotNull);
          expect(bob.plate[Category.main], isNull);
          expect(identical(alice.plate, bob.plate), isFalse);
        },
      );

      test(
        'can be given a plate that already has cards on it',
        () {
          const card = Card(
            id: '1',
            type: CardType.standard,
            category: Category.main,
            name: 'Sausages',
          );
          final plate = Plate(main: card);

          final player = Player(name: 'Alice', plate: plate);

          expect(player.plate[Category.main], card);
        },
      );
    },
  );
}
