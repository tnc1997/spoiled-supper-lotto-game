/// The type of food (or drink) a card belongs to.
///
/// The physical cards split into two groups by board position, referred to as
/// "Left Side" and "Right Side" during specification discussion; that
/// distinction described board position, not printed box text, and is not
/// reflected here. The underlying card split is consistently veg vs. carb, so
/// this enum uses food-type names instead.
enum Category {
  dessert,
  vegetables,
  main,
  carbohydrates,
  drink,
}
