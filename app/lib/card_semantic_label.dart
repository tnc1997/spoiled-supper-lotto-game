import 'package:game_engine/game_engine.dart' as engine;

import 'category_label.dart';

/// What a screen reader announces for each [engine.Card].
extension CardSemanticLabel on engine.Card {
  /// The card's name and category, and whether it is Spoiled, e.g.
  /// `Fish Bone, Main, Spoiled`.
  ///
  /// Shared by the placeholder and the player's own image, so that a card
  /// is announced the same whichever is shown.
  String get semanticLabel => [
        name,
        category.label,
        if (type == engine.CardType.spoiled) 'Spoiled',
      ].join(', ');
}
