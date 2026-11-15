import 'package:game_engine/game_engine.dart';

/// The file a player names their own image of each card, keyed by
/// [Card.id], e.g. `fish-fingers.png` for Fish Fingers.
///
/// Players can show their own images of the cards, e.g. scanned from a copy
/// they own and cropped with `tools/crop-cards.sh`, by placing files with
/// these names in a local folder. A card without such a file is shown as a
/// `PlaceholderCard`.
///
/// Each filename is fixed here rather than derived from [Card.name], so that
/// rewording a card's name doesn't stop a player's existing image from being
/// found. Once released, a filename should never change.
///
/// Every filename is lowercase, with words separated by hyphens and a `.png`
/// extension, so it is the same on every platform's file system.
const assetSlots = <String, String>{
  '1310ab58-8b89-4f70-bd68-347cdaeb7b71': 'fruit-salad.png',
  '986542ea-6353-407d-9d53-daad2cbf3ac9': 'ice-cream.png',
  '482625fa-aa08-4ca3-a388-a2810cb77d4f': 'jelly.png',
  '12d00074-f4fa-4be7-a67f-8af918a58002': 'strawberries.png',
  'badb0150-97aa-4659-9ef5-5eddeaeccc05': 'baked-beans.png',
  '874cd11e-001c-4fbc-a266-1cc6473d079e': 'carrots.png',
  '6a2532eb-2041-41f9-9de7-ff891242ca67': 'peas.png',
  '010dfe29-2ad0-4213-baa2-5dbefba4ca8c': 'tomatoes.png',
  '0d78745d-a48f-4412-a32e-d81e2911ae8b': 'fish-fingers.png',
  'aa3dd15d-c501-4781-81c0-800fb0a99891': 'lamb-chops.png',
  'b2590d89-4580-40c7-8b33-3c92fc6b347d': 'sausages.png',
  '07052827-80dd-4b67-b52a-cfdd1efbe4c2': 'steak-pie.png',
  '52093ec1-989b-4fe6-afaa-5482339e5d79': 'baked-potato.png',
  'e28dc998-bbf9-4eef-b0e2-0cf93678951b': 'boiled-potatoes.png',
  'd9134a51-0a46-4b83-b415-87cbd14b749c': 'chips.png',
  '9b7a2054-b704-4028-aa72-cd2981c464d8': 'mashed-potato.png',
  '9c50c52b-f825-49b8-a711-0b8db36dceb4': 'grape-soda.png',
  '8c1effeb-cb21-40bd-9232-014490c639c8': 'milk.png',
  '739daf3a-2df3-4aaa-9e2b-3154f5f691f9': 'orange-soda.png',
  '8104dec3-ae72-492c-a310-80ff2d5b9d17': 'water.png',
  '382584f7-3ae8-4dea-b256-41f8dd660e1d': 'apple-core.png',
  'e67b07fc-f48e-4424-aabb-c4a2cdde911f': 'banana-skin.png',
  '1c76b18e-8985-4adf-88d5-8c7d688f2854': 'dandelions.png',
  '85f44a37-1024-4812-be5f-ff79c832837c': 'mouldy-lettuce.png',
  '22407c27-1682-4fca-b9b9-015208b86f18': 'fish-bone.png',
  '4d83670e-8428-497a-b29f-8e94813b77d7': 'leather-boot.png',
  'd31b5b5c-a78a-4803-a61e-3ddd82f4c866': 'mouldy-potato.png',
  'e821e21f-16d7-4a89-871c-49ad3679fbb5': 'potato-peelings.png',
  '43b3489f-d940-4980-8df5-bb669c751c3b': 'bug-soda.png',
  '04c69c46-f6e4-4fde-aa98-5ca02b2c46de': 'pond-water.png',
};

/// The local override filename of each [Card].
extension AssetSlot on Card {
  /// The name of the file that holds the player's own image of this card,
  /// e.g. `fish-fingers.png`, or `null` if it isn't one of the cards in the
  /// deck.
  String? get overrideFilename => assetSlots[id];
}
