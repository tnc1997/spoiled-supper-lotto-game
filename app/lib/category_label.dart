import 'package:game_engine/game_engine.dart' as engine;

/// The name of each [engine.Category] as shown to players.
extension CategoryLabel on engine.Category {
  /// The name of this category, e.g. `Dessert`.
  String get label => switch (this) {
        engine.Category.dessert => 'Dessert',
        engine.Category.vegetable => 'Vegetable',
        engine.Category.main => 'Main',
        engine.Category.carbohydrate => 'Carbohydrate',
        engine.Category.drink => 'Drink',
      };
}
