import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Player',
    () {
      test('exposes its name and an empty plate by default', () {
        final player = Player(name: 'Alice');

        expect(player.name, 'Alice');
        expect(player.isAi, isFalse);
        expect(player.plate.isFull, isFalse);
      });

      test('can be marked as a computer opponent', () {
        final player = Player(name: 'Computer', isAi: true);

        expect(player.isAi, isTrue);
      });

      test('can be given a plate that already has cards on it', () {
        const card = Card(
          id: '1',
          type: CardType.standard,
          category: Category.main,
          name: 'Sausages',
        );
        final plate = Plate(main: card);

        final player = Player(name: 'Alice', plate: plate);

        expect(player.plate[Category.main], card);
      });
    },
  );
}
