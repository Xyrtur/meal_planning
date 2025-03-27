import 'package:hive_ce/hive.dart';

part 'recipe.g.dart';

// Allows Comparable to be used like a mixin, and can now sort lists of Recipes
mixin Compare<T> implements Comparable<T> {
  bool operator <=(T other) => compareTo(other) <= 0;
  bool operator >=(T other) => compareTo(other) >= 0;
  bool operator <(T other) => compareTo(other) < 0;
  bool operator >(T other) => compareTo(other) > 0;
}

@HiveType(typeId: 2)
class Recipe extends HiveObject with Compare<Recipe> {
  @HiveField(0)
  String title;
  @HiveField(1)
  String ingredients;
  @HiveField(2)
  String instructions;
  @HiveField(3)
  List<String> categories;
  @HiveField(4)
  String prepTime;

  Recipe(
      {required this.title,
      required this.ingredients,
      required this.instructions,
      required this.categories,
      required this.prepTime});

  Recipe edit(
      {required String title,
      required String ingredients,
      required String instructions,
      required List<String> categories,
      required String prepTime}) {
    this.title = title;
    this.ingredients = ingredients;
    this.instructions = instructions;
    this.categories = categories;
    this.prepTime = prepTime;
    return this;
  }

  // Used when sorting a list into alphabetical order
  @override
  int compareTo(Recipe other) {
    return title.compareTo(other.title);
  }

  @override
  toString() {
    return {
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'categories': categories,
      'prepTime': prepTime
    }.toString();
  }
}
