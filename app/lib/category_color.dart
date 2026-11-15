import 'package:game_engine/game_engine.dart' as engine;
import 'package:material_ui/material_ui.dart';

/// The colour that represents each [engine.Category] throughout the UI, e.g. on
/// placeholder cards and plate slots.
extension CategoryColor on engine.Category {
  /// The base colour for this category, chosen to hint at the food.
  Color get color => switch (this) {
        engine.Category.dessert => Colors.pink,
        engine.Category.vegetable => Colors.green,
        engine.Category.main => Colors.purple,
        engine.Category.carbohydrate => Colors.yellow,
        engine.Category.drink => Colors.blue,
      };
}
