import 'package:game_engine/game_engine.dart';

/// The name of each [Category] as shown to players.
extension CategoryLabel on Category {
  /// The name of this category, e.g. `Dessert`.
  String get label => switch (this) {
        Category.dessert => 'Dessert',
        Category.vegetable => 'Vegetable',
        Category.main => 'Main',
        Category.carbohydrate => 'Carbohydrate',
        Category.drink => 'Drink',
      };
}
