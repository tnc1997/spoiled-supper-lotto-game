import 'card.dart';
import 'card_type.dart';
import 'category.dart';

/// The full 30-card deck confirmed against the maintainer's physical 1983
/// copy: 20 [CardType.standard] cards and 10 [CardType.spoiled] cards, 4
/// and 2 per [Category] respectively.
///
/// Each card's [Card.id] is a fixed UUID assigned once and never
/// regenerated, so a card's identity stays stable even if its name is
/// later reworded.
const _deck = <Card>[
  Card(
    id: '1310ab58-8b89-4f70-bd68-347cdaeb7b71',
    type: CardType.standard,
    category: Category.dessert,
    name: 'Fruit Salad',
  ),
  Card(
    id: '986542ea-6353-407d-9d53-daad2cbf3ac9',
    type: CardType.standard,
    category: Category.dessert,
    name: 'Ice Cream',
  ),
  Card(
    id: '482625fa-aa08-4ca3-a388-a2810cb77d4f',
    type: CardType.standard,
    category: Category.dessert,
    name: 'Jelly',
  ),
  Card(
    id: '12d00074-f4fa-4be7-a67f-8af918a58002',
    type: CardType.standard,
    category: Category.dessert,
    name: 'Strawberries',
  ),
  Card(
    id: 'badb0150-97aa-4659-9ef5-5eddeaeccc05',
    type: CardType.standard,
    category: Category.vegetable,
    name: 'Baked Beans',
  ),
  Card(
    id: '874cd11e-001c-4fbc-a266-1cc6473d079e',
    type: CardType.standard,
    category: Category.vegetable,
    name: 'Carrots',
  ),
  Card(
    id: '6a2532eb-2041-41f9-9de7-ff891242ca67',
    type: CardType.standard,
    category: Category.vegetable,
    name: 'Peas',
  ),
  Card(
    id: '010dfe29-2ad0-4213-baa2-5dbefba4ca8c',
    type: CardType.standard,
    category: Category.vegetable,
    name: 'Tomatoes',
  ),
  Card(
    id: '0d78745d-a48f-4412-a32e-d81e2911ae8b',
    type: CardType.standard,
    category: Category.main,
    name: 'Fish Fingers',
  ),
  Card(
    id: 'aa3dd15d-c501-4781-81c0-800fb0a99891',
    type: CardType.standard,
    category: Category.main,
    name: 'Lamb Chops',
  ),
  Card(
    id: 'b2590d89-4580-40c7-8b33-3c92fc6b347d',
    type: CardType.standard,
    category: Category.main,
    name: 'Sausages',
  ),
  Card(
    id: '07052827-80dd-4b67-b52a-cfdd1efbe4c2',
    type: CardType.standard,
    category: Category.main,
    name: 'Steak Pie',
  ),
  Card(
    id: '52093ec1-989b-4fe6-afaa-5482339e5d79',
    type: CardType.standard,
    category: Category.carbohydrate,
    name: 'Baked Potato',
  ),
  Card(
    id: 'e28dc998-bbf9-4eef-b0e2-0cf93678951b',
    type: CardType.standard,
    category: Category.carbohydrate,
    name: 'Boiled Potatoes',
  ),
  Card(
    id: 'd9134a51-0a46-4b83-b415-87cbd14b749c',
    type: CardType.standard,
    category: Category.carbohydrate,
    name: 'Chips',
  ),
  Card(
    id: '9b7a2054-b704-4028-aa72-cd2981c464d8',
    type: CardType.standard,
    category: Category.carbohydrate,
    name: 'Mashed Potato',
  ),
  Card(
    id: '9c50c52b-f825-49b8-a711-0b8db36dceb4',
    type: CardType.standard,
    category: Category.drink,
    name: 'Grape Soda',
  ),
  Card(
    id: '8c1effeb-cb21-40bd-9232-014490c639c8',
    type: CardType.standard,
    category: Category.drink,
    name: 'Milk',
  ),
  Card(
    id: '739daf3a-2df3-4aaa-9e2b-3154f5f691f9',
    type: CardType.standard,
    category: Category.drink,
    name: 'Orange Soda',
  ),
  Card(
    id: '8104dec3-ae72-492c-a310-80ff2d5b9d17',
    type: CardType.standard,
    category: Category.drink,
    name: 'Water',
  ),
  Card(
    id: '382584f7-3ae8-4dea-b256-41f8dd660e1d',
    type: CardType.spoiled,
    category: Category.dessert,
    name: 'Apple Core',
  ),
  Card(
    id: 'e67b07fc-f48e-4424-aabb-c4a2cdde911f',
    type: CardType.spoiled,
    category: Category.dessert,
    name: 'Banana Skin',
  ),
  Card(
    id: '1c76b18e-8985-4adf-88d5-8c7d688f2854',
    type: CardType.spoiled,
    category: Category.vegetable,
    name: 'Dandelions',
  ),
  Card(
    id: '85f44a37-1024-4812-be5f-ff79c832837c',
    type: CardType.spoiled,
    category: Category.vegetable,
    name: 'Mouldy Lettuce',
  ),
  Card(
    id: '22407c27-1682-4fca-b9b9-015208b86f18',
    type: CardType.spoiled,
    category: Category.main,
    name: 'Fish Bone',
  ),
  Card(
    id: '4d83670e-8428-497a-b29f-8e94813b77d7',
    type: CardType.spoiled,
    category: Category.main,
    name: 'Leather Boot',
  ),
  Card(
    id: 'd31b5b5c-a78a-4803-a61e-3ddd82f4c866',
    type: CardType.spoiled,
    category: Category.carbohydrate,
    name: 'Mouldy Potato',
  ),
  Card(
    id: 'e821e21f-16d7-4a89-871c-49ad3679fbb5',
    type: CardType.spoiled,
    category: Category.carbohydrate,
    name: 'Potato Peelings',
  ),
  Card(
    id: '43b3489f-d940-4980-8df5-bb669c751c3b',
    type: CardType.spoiled,
    category: Category.drink,
    name: 'Bug Soda',
  ),
  Card(
    id: '04c69c46-f6e4-4fde-aa98-5ca02b2c46de',
    type: CardType.spoiled,
    category: Category.drink,
    name: 'Pond Water',
  ),
];

/// Builds the full 30-card deck.
///
/// Returns a fresh, independent list on every call; the [Card]s themselves
/// (including their fixed [Card.id]s) are the same every time.
List<Card> buildDeck() {
  return List.of(_deck);
}
