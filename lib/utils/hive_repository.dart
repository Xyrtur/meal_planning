import 'package:hive_ce/hive.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/datetime_ext.dart';

enum CategoryType { grocery, recipe, generic }

class HiveRepository {
  late Box recipesBox;
  late Box mealPlanningBox;
  Map<String, Recipe> recipeTitlestoRecipeMap = {};
  Map<String, List<Recipe>> recipeCategoriesToRecipesMap = {};
  Map<String, int> recipeCategoriesMap = {};
  Map<String, int> groceryCategoriesMap = {};
  Map<String, int> genericCategoriesMap = {};
  Map<String, List<GroceryItem>> groceryItemsMap = {};
  List<String> weeklyMealsList = [];
  List<List<String>> weeklyMealsSplit = [];
  List<Recipe> recipeList = [];
  List<DateTime> currentWeekRanges = [];
  List<String> groceryCategoryOrder = [];

  HiveRepository();

  cacheInitialData() {
    recipesBox = Hive.box<Recipe>('recipesBox');
    mealPlanningBox = Hive.box<dynamic>('mealPlanningBox');

    recipeList = recipesBox.values.cast<Recipe>().toList();
    recipeCategoriesMap =
        (mealPlanningBox.get('recipeCategoriesMap') ?? <String, int>{})
            .cast<String, int>();
    groceryCategoriesMap =
        (mealPlanningBox.get('groceryCategoriesMap') ?? <String, int>{})
            .cast<String, int>();
    genericCategoriesMap =
        (mealPlanningBox.get('genericCategoriesMap') ?? <String, int>{})
            .cast<String, int>();
    groceryItemsMap = (mealPlanningBox.get('groceryItemsMap') ?? {})
        .cast<String, List<GroceryItem>>();
    currentWeekRanges =
        (mealPlanningBox.get('currentWeekRanges') ?? []).cast<DateTime>();
    weeklyMealsList =
        (mealPlanningBox.get('weeklyMealsList') ?? []).cast<String>();
    groceryCategoryOrder =
        (mealPlanningBox.get('groceryCategoryOrder') ?? []).cast<String>();

    recipeTitlestoRecipeMap.clear();
    weeklyMealsSplit.clear();
    currentWeekRanges.clear();
    recipeCategoriesToRecipesMap.clear();
    for (String category in recipeCategoriesMap.keys) {
      recipeCategoriesToRecipesMap[category] = [];
    }

    // Cache recipe information to speed up searching and filtering
    for (Recipe recipe in recipeList) {
      recipeTitlestoRecipeMap[recipe.title] = recipe;
      recipeCategoriesToRecipesMap[recipe.category]!.add(recipe);
    }

    // Set current week ranges / correct if needed
    // If there are no week ranges set OR today's date is not within the stored ranges
    if (currentWeekRanges.isEmpty ||
        !(DateTime.now().isBetweenDates(
            currentWeekRanges[0],
            currentWeekRanges.length == 6
                ? currentWeekRanges[5]
                : currentWeekRanges[3]))) {
      currentWeekRanges.clear();
      weeklyMealsList.clear();
      DateTime startOfRanges =
          DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
      currentWeekRanges.add(startOfRanges);
      currentWeekRanges.add(startOfRanges.add(Duration(days: 6)));

      currentWeekRanges.add(startOfRanges.add(Duration(days: 7)));
      currentWeekRanges.add(startOfRanges.add(Duration(days: 13)));

      weeklyMealsList.addAll(List.filled(5 * 14, ""));

      if (DateTime.now().weekday > 5) {
        currentWeekRanges.add(startOfRanges.add(Duration(days: 14)));
        currentWeekRanges.add(startOfRanges.add(Duration(days: 20)));

        weeklyMealsList.addAll(List.filled(5 * 7, ""));
      }
    } else {
      // Prune the list
      if (DateTime.now()
          .isBetweenDates(currentWeekRanges[2], currentWeekRanges[3])) {
        // Lops off first week
        currentWeekRanges.removeRange(0, 2);
        weeklyMealsList.removeRange(0, 35);
      } else if (currentWeekRanges.length == 6 &&
          DateTime.now()
              .isBetweenDates(currentWeekRanges[4], currentWeekRanges[5])) {
        // Lops off first and second week
        currentWeekRanges.removeRange(0, 4);
        weeklyMealsList.removeRange(0, 70);
      }

      // Extend the list

      // If only one week is left, add a second
      if (currentWeekRanges.length == 2) {
        currentWeekRanges.add(currentWeekRanges[0].add(Duration(days: 7)));
        currentWeekRanges.add(currentWeekRanges[0].add(Duration(days: 13)));
        weeklyMealsList.addAll(List.filled(5 * 7, ""));
      }
      // Add a third week only if nearing the end of the first week
      if (DateTime.now().weekday >= 5 && currentWeekRanges.length == 4) {
        currentWeekRanges.add(currentWeekRanges[0].add(Duration(days: 14)));
        currentWeekRanges.add(currentWeekRanges[0].add(Duration(days: 20)));
        weeklyMealsList.addAll(List.filled(5 * 7, ""));
      }
    }
    // Update in the box
    mealPlanningBox.put('currentWeekRanges', currentWeekRanges);
    mealPlanningBox.put('weeklyMealsList', weeklyMealsList);

    for (int i = 0; i < (weeklyMealsList.length / 5).floor(); i++) {
      weeklyMealsSplit.add(weeklyMealsList.sublist(i * 5, i * 5 + 5));
    }
  }

  // Weekly Planning Page functions

  void updateWeeklyMeals(int index, String recipeName) {
    // Update the box
    weeklyMealsList[index] = recipeName;
    weeklyMealsSplit[(index / 5).floor()][index % 5] = recipeName;
    mealPlanningBox.put('weeklyMealsList', weeklyMealsList);
  }

  // Settings page
  void deleteCategory(
      {required CategoryType type, required String categoryName}) {
    switch (type) {
      case CategoryType.grocery:
        groceryCategoriesMap.remove(categoryName);
        mealPlanningBox.put('groceryCategoriesMap', groceryCategoriesMap);
        groceryCategoryOrder.remove(categoryName);
        mealPlanningBox.put('groceryCategoryOrder', groceryCategoryOrder);

        groceryItemsMap.update(
            "Other", (list) => list..addAll(groceryItemsMap[categoryName]!),
            ifAbsent: () => groceryItemsMap[categoryName]!);
        break;

      case CategoryType.recipe:
        recipeCategoriesMap.remove(categoryName);
        mealPlanningBox.put('recipeCategoriesMap', recipeCategoriesMap);
        recipeCategoriesToRecipesMap.update("Other",
            (list) => list..addAll(recipeCategoriesToRecipesMap[categoryName]!),
            ifAbsent: () => recipeCategoriesToRecipesMap[categoryName]!);
        break;

      case CategoryType.generic:
        genericCategoriesMap.remove(categoryName);
        mealPlanningBox.put('genericCategoriesMap', genericCategoriesMap);
        for (int i = 0; i < weeklyMealsList.length; i++) {
          if (weeklyMealsList[i] == categoryName) {
            weeklyMealsList[i] = "";
            weeklyMealsSplit[(i / 5).floor()][i % 5] = "";
          }
        }
        mealPlanningBox.put('weeklyMealsList', weeklyMealsList);
        break;
    }
  }

  void addCategory(
      {required CategoryType type,
      required String categoryName,
      required int color}) {
    switch (type) {
      case CategoryType.grocery:
        groceryCategoriesMap[categoryName] = color;
        mealPlanningBox.put('groceryCategoriesMap', groceryCategoriesMap);

        groceryItemsMap.addAll({categoryName: []});
        mealPlanningBox.put('groceryItemsMap', groceryItemsMap);

        groceryCategoryOrder.add(categoryName);
        mealPlanningBox.put('groceryCategoryOrder', groceryCategoryOrder);
        break;

      case CategoryType.recipe:
        recipeCategoriesMap[categoryName] = color;
        mealPlanningBox.put('recipeCategoriesMap', recipeCategoriesMap);
        break;

      case CategoryType.generic:
        genericCategoriesMap[categoryName] = color;
        mealPlanningBox.put('genericCategoriesMap', genericCategoriesMap);
        break;
    }
  }

  void updateCategory({required String oldName, String? newName, int? color}) {
    //TODO:
  }

  // Grocery page functions
  void updateGroceryItems({
    required bool updatingChecked,
    required bool noCategoryUpdated,
    required Map<String, List<GroceryItem>> items,
    String? currentCategory,
    int? index,
    bool? checked,
  }) {
    if (updatingChecked) {
      // if checked is not set, then whole category(ies) are being checked off/on
      if (checked != null) {
        groceryItemsMap[items.keys.first]![index!].isChecked = checked;
      }
      for (String category in items.keys) {
        bool allCheckedOff = true;
        if (items.length > 1) {
          for (int i = 0; i < groceryItemsMap[category]!.length; i++) {
            if (!groceryItemsMap[category]![i].isChecked) {
              allCheckedOff = false;
              break;
            }
          }
          checked = !allCheckedOff;
        }
        for (int i = 0; i < groceryItemsMap[category]!.length; i++) {
          groceryItemsMap[category]![i].isChecked = checked!;
        }
      }
    } else {
      if (noCategoryUpdated) {
        groceryItemsMap[items.keys.first] = items[items.keys.first]!;
      } else {
        // Updating categories of moved items
        for (String category in items.keys) {
          for (GroceryItem item in items[category]!) {
            groceryItemsMap[category]!.remove(item);
          }
          groceryItemsMap[currentCategory]!.addAll(items[category]!);
        }
      }
    }
    mealPlanningBox.put('groceryItemsMap', groceryItemsMap);
  }

  void deleteGroceryItems(Map<String, List<GroceryItem>> itemsToDelete) {
    for (String category in itemsToDelete.keys) {
      for (GroceryItem item in groceryItemsMap[category]!) {
        groceryItemsMap[category]!.remove(item);
      }
    }
    mealPlanningBox.put('groceryItemsMap', groceryItemsMap);
  }

  void addGroceryItem(GroceryItem item, String category) {
    groceryItemsMap[category]!.add(item);
    mealPlanningBox.put('groceryItemsMap', groceryItemsMap);
  }

  void updateGroceryCategoryOrder({required List<String> newOrder}) {
    groceryCategoryOrder = newOrder;
    mealPlanningBox.put('groceryCategoryOrder', groceryCategoryOrder);
  }

  // All Recipes page functions
  void addRecipe() {}

  void deleteRecipe() {}

  void updateRecipe() {}
}
