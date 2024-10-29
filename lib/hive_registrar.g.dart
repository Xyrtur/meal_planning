import 'package:hive_ce/hive.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/models/recipe.dart';

extension HiveRegistrar on HiveInterface {
  void registerAdapters() {
    registerAdapter(GroceryItemAdapter());
    registerAdapter(RecipeAdapter());
  }
}
