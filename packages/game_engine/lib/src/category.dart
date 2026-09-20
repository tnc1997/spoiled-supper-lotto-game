/// The type of food (or drink) a card belongs to.
///
/// [vegetables] and [carbohydrates] were shorthanded as "Left Side" and
/// "Right Side" during specification discussion, describing their opposing
/// position on the physical board plate — not printed box text, and not a
/// left/right split of all five categories. The underlying card split is
/// consistently veg vs. carb, so this enum uses food-type names for those two
/// values instead.
enum Category {
  dessert,
  vegetables,
  main,
  carbohydrates,
  drink,
}
