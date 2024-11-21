import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/datetime_ext.dart';

enum CategoryType { grocery, recipe, generic }

class HiveRepository {
  late Box recipesBox;
  late Box mealPlanningBox;

  // RECIPES
  // Stores all the lists from the recipe box
  List<Recipe> recipeList = [];
  // Quick way to get recipes from their name
  Map<String, Recipe> recipeTitlestoRecipeMap = {};
  // Allows for quicker filtering
  Map<String, List<String>> recipeCategoriesToRecipeTitlesMap = {};

  // SETTINGS
  // Stores colors of recipe categories
  Map<String, int> recipeCategoriesMap = {};
  // Stores colors of grocery categories
  Map<String, int> groceryCategoriesMap = {};
  // Stores colors of generic categories
  Map<String, int> genericCategoriesMap = {};

  // GROCERY LIST
  // Stores grocery list items in their categories
  Map<String, List<GroceryItem>> groceryItemsMap = {};
  // Stores the order of categories for the grocery list
  List<String> groceryCategoryOrder = [];

  // WEEKLY PLANNING
  // Stores all the meals planned for coming weeks
  List<String> weeklyMealsList = [];
  // Breaks up the meals into sublists
  List<List<String>> weeklyMealsSplit = [];
  // Stores the weeks that can be planned for
  List<DateTime> currentWeekRanges = [];

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
    (mealPlanningBox.get('groceryItemsMap') ?? {}).forEach((key, value) {
      if (key is String && value is List<dynamic>) {
        groceryItemsMap[key] = value.whereType<GroceryItem>().toList();
      }
    });
    recipeCategoriesMap.addEntries(
        {"Veggie": Colors.green.value, "Meat": Colors.red.value}.entries);
    recipeList.addAll([
      Recipe(
          title: "Chicken Slop",
          ingredients: "pee\npoo\nmao",
          instructions: "meep\nmoop",
          categories: ["Meat"]),
      Recipe(
          title: "Beet mix",
          ingredients: "pee\npoo\nmao",
          instructions: "meep\nmoop",
          categories: ["Veggie"]),
      Recipe(
          title: "Salad",
          ingredients: "pee\npoo\nmao",
          instructions: "meep\nmoop",
          categories: ["Veggie"])
    ]);

    currentWeekRanges =
        (mealPlanningBox.get('currentWeekRanges') ?? []).cast<DateTime>();
    weeklyMealsList =
        (mealPlanningBox.get('weeklyMealsList') ?? []).cast<String>();
    groceryCategoryOrder =
        (mealPlanningBox.get('groceryCategoryOrder') ?? []).cast<String>();

    recipeTitlestoRecipeMap.clear();
    weeklyMealsSplit.clear();
    currentWeekRanges.clear();
    recipeCategoriesToRecipeTitlesMap.clear();
    for (String category in recipeCategoriesMap.keys) {
      recipeCategoriesToRecipeTitlesMap[category] = [];
    }

    // Cache recipe information to speed up searching and filtering
    for (Recipe recipe in recipeList) {
      recipeTitlestoRecipeMap[recipe.title] = recipe;
      for (String category in recipe.categories) {
        recipeCategoriesToRecipeTitlesMap[category]!.add(recipe.title);
      }
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
      currentWeekRanges.add(startOfRanges.add(const Duration(days: 6)));

      currentWeekRanges.add(startOfRanges.add(const Duration(days: 7)));
      currentWeekRanges.add(startOfRanges.add(const Duration(days: 13)));

      weeklyMealsList.addAll(List.filled(5 * 14, ""));

      if (DateTime.now().weekday > 5) {
        currentWeekRanges.add(startOfRanges.add(const Duration(days: 14)));
        currentWeekRanges.add(startOfRanges.add(const Duration(days: 20)));

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
        currentWeekRanges
            .add(currentWeekRanges[0].add(const Duration(days: 7)));
        currentWeekRanges
            .add(currentWeekRanges[0].add(const Duration(days: 13)));
        weeklyMealsList.addAll(List.filled(5 * 7, ""));
      }
      // Add a third week only if nearing the end of the first week
      if (DateTime.now().weekday >= 5 && currentWeekRanges.length == 4) {
        currentWeekRanges
            .add(currentWeekRanges[0].add(const Duration(days: 14)));
        currentWeekRanges
            .add(currentWeekRanges[0].add(const Duration(days: 20)));
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
        groceryCategoryOrder.remove(categoryName);
        if (groceryItemsMap[categoryName]!.isNotEmpty) {
          groceryItemsMap.update(
              "Other", (list) => list..addAll(groceryItemsMap[categoryName]!),
              ifAbsent: () {
            groceryCategoriesMap["Other"] = Colors.blueGrey.value;
            groceryCategoryOrder.add("Other");
            return groceryItemsMap[categoryName]!;
          });
        }
        groceryItemsMap.remove(categoryName);

        mealPlanningBox.put('groceryCategoryOrder', groceryCategoryOrder);
        mealPlanningBox.put('groceryCategoriesMap', groceryCategoriesMap);
        mealPlanningBox.put('groceryItemsMap', groceryItemsMap);

        break;

      case CategoryType.recipe:
        recipeCategoriesMap.remove(categoryName);
        if (recipeCategoriesToRecipeTitlesMap[categoryName]!.isNotEmpty) {
          recipeCategoriesToRecipeTitlesMap.update("Other", (list) {
            for (String recipeName
                in recipeCategoriesToRecipeTitlesMap[categoryName]!) {
              if (recipeTitlestoRecipeMap[recipeName]!.categories.length == 1) {
                list.add(recipeName);
              }
            }
            return list;
          }, ifAbsent: () {
            recipeCategoriesMap["Other"] = Colors.blueGrey.value;
            List<String> list = [];
            for (String recipeName
                in recipeCategoriesToRecipeTitlesMap[categoryName]!) {
              if (recipeTitlestoRecipeMap[recipeName]!.categories.length == 1) {
                list.add(recipeName);
              }
            }
            return list;
          });
        }
        recipeCategoriesToRecipeTitlesMap.remove(categoryName);

        mealPlanningBox.put('recipeCategoriesMap', recipeCategoriesMap);

        break;

      case CategoryType.generic:
        genericCategoriesMap.remove(categoryName);
        for (int i = 0; i < weeklyMealsList.length; i++) {
          if (weeklyMealsList[i] == categoryName) {
            weeklyMealsList[i] = "";
            weeklyMealsSplit[(i / 5).floor()][i % 5] = "";
          }
        }
        mealPlanningBox.put('genericCategoriesMap', genericCategoriesMap);
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
        recipeCategoriesToRecipeTitlesMap[categoryName] = [];
        mealPlanningBox.put('recipeCategoriesMap', recipeCategoriesMap);
        break;

      case CategoryType.generic:
        genericCategoriesMap[categoryName] = color;
        mealPlanningBox.put('genericCategoriesMap', genericCategoriesMap);
        break;
    }
  }

  void updateCategory(
      {required CategoryType type,
      required String oldName,
      String? newName,
      int? color}) {
    switch (type) {
      case CategoryType.grocery:
        if (color != null) {
          groceryCategoriesMap[oldName] = color;
        } else {
          int val = groceryCategoriesMap.remove(oldName)!;
          groceryCategoriesMap[newName!] = val;
          groceryCategoryOrder[groceryCategoryOrder.indexOf(oldName)] = newName;
          List<GroceryItem> items = groceryItemsMap.remove(oldName)!;
          groceryItemsMap[newName] = items;
        }
        mealPlanningBox.put('groceryCategoriesMap', groceryCategoriesMap);
        mealPlanningBox.put('groceryCategoryOrder', groceryCategoryOrder);
        mealPlanningBox.put('groceryItemsMap', groceryItemsMap);
        break;

      case CategoryType.recipe:
        if (color != null) {
          recipeCategoriesMap[oldName] = color;
        } else {
          int val = recipeCategoriesMap.remove(oldName)!;
          recipeCategoriesMap[newName!] = val;
          List<String> items =
              recipeCategoriesToRecipeTitlesMap.remove(oldName)!;
          recipeCategoriesToRecipeTitlesMap[newName] = items;
          for (String recipeTitle in items) {
            recipeTitlestoRecipeMap[recipeTitle]!.categories.remove(oldName);
            recipeTitlestoRecipeMap[recipeTitle]!.categories.add(newName);
            recipeTitlestoRecipeMap[recipeTitle]!.save();
          }
        }
        mealPlanningBox.put('recipeCategoriesMap', recipeCategoriesMap);
        break;

      case CategoryType.generic:
        if (color != null) {
          genericCategoriesMap[oldName] = color;
        } else {
          int val = genericCategoriesMap.remove(oldName)!;
          genericCategoriesMap[newName!] = val;
          for (int i = 0; i < weeklyMealsList.length; i++) {
            if (weeklyMealsList[i] == oldName) {
              weeklyMealsList[i] = newName;
              weeklyMealsSplit[(i / 5).floor()][i % 5] = newName;
            }
          }
        }
        mealPlanningBox.put('genericCategoriesMap', genericCategoriesMap);
        mealPlanningBox.put('weeklyMealsList', weeklyMealsList);
        break;
    }
  }

  // Grocery page functions
  void updateGroceryItems({
    required bool updatingChecked,
    required bool noCategoryUpdated,
    Map<String, List<GroceryItem>>? items,
    String? currentCategory,
    int? index,
    bool? checked,
  }) {
    if (updatingChecked) {
      // if checked is not set, then whole category(ies) are being checked off/on
      if (checked != null) {
        groceryItemsMap[currentCategory]![index!].isChecked = checked;
      } else {
        bool allCheckedOff = true;

        for (int i = 0; i < groceryItemsMap[currentCategory]!.length; i++) {
          if (!groceryItemsMap[currentCategory]![i].isChecked) {
            allCheckedOff = false;
            break;
          }
        }
        checked = !allCheckedOff;

        for (int i = 0; i < groceryItemsMap[currentCategory]!.length; i++) {
          groceryItemsMap[currentCategory]![i].isChecked = checked;
        }
      }
    } else {
      if (noCategoryUpdated) {
        groceryItemsMap[items!.keys.first] = items[items.keys.first]!;
      } else {
        // Updating categories of moved items
        for (String category in items!.keys) {
          for (GroceryItem item in items[category]!) {
            groceryItemsMap[category]!.remove(item);
          }
          groceryItemsMap[currentCategory]!.addAll(items[category]!);
        }
      }
    }
    mealPlanningBox.put('groceryItemsMap', groceryItemsMap);
  }

  void deleteGroceryItems(
      {required Map<String, List<GroceryItem>> itemsToDelete,
      required bool clearAll}) {
    if (clearAll) {
      for (String category in groceryItemsMap.keys) {
        groceryItemsMap[category]!.clear();
      }
    } else {
      for (String category in itemsToDelete.keys) {
        for (GroceryItem item in itemsToDelete[category]!) {
          groceryItemsMap[category]!.remove(item);
        }
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

  // Recipe page functions
  void addRecipe() {}

  void deleteRecipe() {}

  void updateRecipe() {}
}
