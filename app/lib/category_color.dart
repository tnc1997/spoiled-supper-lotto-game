import 'package:game_engine/game_engine.dart';
import 'package:material_ui/material_ui.dart';

/// The colour that represents each [Category] throughout the UI, e.g. on
/// placeholder cards and plate slots.
extension CategoryColor on Category {
  /// The base colour for this category, chosen to hint at the food.
  Color get color => switch (this) {
        Category.dessert => Colors.pink,
        Category.vegetable => Colors.green,
        Category.main => Colors.purple,
        Category.carbohydrate => Colors.yellow,
        Category.drink => Colors.blue,
      };
}
