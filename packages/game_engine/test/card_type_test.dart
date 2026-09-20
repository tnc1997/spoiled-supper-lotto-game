import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'CardType',
    () {
      test('has one value per card type', () {
        expect(
          CardType.values,
          [
            CardType.food,
            CardType.spoiled,
          ],
        );
      });
    },
  );
}
