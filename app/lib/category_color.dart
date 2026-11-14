import 'package:game_engine/game_engine.dart';
import 'package:material_ui/material_ui.dart';

/// The colour that represents each [Category] throughout the UI, e.g. on
/// placeholder cards and plate slots.
extension CategoryColor on Category {
  /// The base colour for this category, chosen to hint at the food.
  Color get color => switch (this) {
        Category.dessert => const Color(0xFFF48FB1),
        Category.vegetable => const Color(0xFF81C784),
        Category.main => const Color(0xFFE57373),
        Category.carbohydrate => const Color(0xFFFFD54F),
        Category.drink => const Color(0xFF64B5F6),
      };
}
