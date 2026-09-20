import 'package:game_engine/game_engine.dart';
import 'package:test/test.dart';

void main() {
  test('has one value per food-type card category', () {
    expect(Category.values, [
      Category.dessert,
      Category.vegetables,
      Category.main,
      Category.carbohydrates,
      Category.drink,
    ]);
  });
}
