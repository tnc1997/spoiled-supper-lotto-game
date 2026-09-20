import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Category',
    () {
      test('has one value per food-type card category', () {
        expect(
          Category.values,
          [
            Category.dessert,
            Category.vegetable,
            Category.main,
            Category.carbohydrate,
            Category.drink,
          ],
        );
      });
    },
  );
}
