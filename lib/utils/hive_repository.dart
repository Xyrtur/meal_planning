import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/datetime_ext.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

enum CategoryType { grocery, recipe, generic }

class HiveRepository {
  late Box remcipesBox;
  late Box mealPlanmingBox;

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
    remcipesBox = Hive.box<Recipe>('remcipesBox');
    mealPlanmingBox = Hive.box<dynamic>('mealPlanmingBox');

    recipeList = remcipesBox.values.cast<Recipe>().toList();
    for (Recipe recipe in recipeList) {
      recipe.edit(
          title: recipe.title,
          ingredients: recipe.ingredients,
          subsectionOrder: {0: "000"},
          instructions: recipe.instructions,
          categories: recipe.categories,
          prepTime: recipe.prepTime);
      recipe.save();
    }
    recipeList = remcipesBox.values.cast<Recipe>().toList();
    for (Recipe recipe in recipeList) {
      recipe.save();
    }

    recipeCategoriesMap = (mealPlanmingBox.get('recipeCategoriesMap') ?? <String, int>{}).cast<String, int>();
    groceryCategoriesMap = (mealPlanmingBox.get('groceryCategoriesMap') ?? <String, int>{}).cast<String, int>();
    genericCategoriesMap = (mealPlanmingBox.get('genericCategoriesMap') ?? <String, int>{}).cast<String, int>();
    (mealPlanmingBox.get('groceryItemsMap') ?? {}).forEach((key, value) {
      if (key is String && value is List<dynamic>) {
        groceryItemsMap[key] = value.whereType<GroceryItem>().toList();
      }
    });

    currentWeekRanges = (mealPlanmingBox.get('currentWeekRanges') ?? []).cast<DateTime>();
    weeklyMealsList = (mealPlanmingBox.get('weeklyMealsList') ?? []).cast<String>();
    groceryCategoryOrder = (mealPlanmingBox.get('groceryCategoryOrder') ?? []).cast<String>();

    recipeTitlestoRecipeMap.clear();
    weeklyMealsSplit.clear();
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
            currentWeekRanges[0], currentWeekRanges.length == 6 ? currentWeekRanges[5] : currentWeekRanges[3]))) {
      currentWeekRanges.clear();
      weeklyMealsList.clear();
      DateTime startOfRanges = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
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
      if (DateTime.now().isBetweenDates(currentWeekRanges[2], currentWeekRanges[3])) {
        // Lops off first week
        currentWeekRanges.removeRange(0, 2);
        weeklyMealsList.removeRange(0, 35);
      } else if (currentWeekRanges.length == 6 &&
          DateTime.now().isBetweenDates(currentWeekRanges[4], currentWeekRanges[5])) {
        // Lops off first and second week
        currentWeekRanges.removeRange(0, 4);
        weeklyMealsList.removeRange(0, 70);
      }

      // Extend the list

      // If only one week is left, add a second
      if (currentWeekRanges.length == 2) {
        currentWeekRanges.add(currentWeekRanges[0].add(const Duration(days: 7)));
        currentWeekRanges.add(currentWeekRanges[0].add(const Duration(days: 13)));
        weeklyMealsList.addAll(List.filled(5 * 7, ""));
      }
      // Add a third week only if nearing the end of the first week
      if (DateTime.now().weekday >= 5 && currentWeekRanges.length == 4) {
        currentWeekRanges.add(currentWeekRanges[0].add(const Duration(days: 14)));
        currentWeekRanges.add(currentWeekRanges[0].add(const Duration(days: 20)));
        weeklyMealsList.addAll(List.filled(5 * 7, ""));
      }
    }
    // Update in the box
    mealPlanmingBox.put('currentWeekRanges', currentWeekRanges);
    mealPlanmingBox.put('weeklyMealsList', weeklyMealsList);

    for (int i = 0; i < (weeklyMealsList.length / 5).floor(); i++) {
      weeklyMealsSplit.add(weeklyMealsList.sublist(i * 5, i * 5 + 5));
    }
  }

  // Weekly Planning Page functions

  void updateWeeklyMeals(int index, String recipeName) {
    // Update the box
    weeklyMealsList[index] = recipeName;
    weeklyMealsSplit[(index / 5).floor()][index % 5] = recipeName;
    mealPlanmingBox.put('weeklyMealsList', weeklyMealsList);
  }

  // Settings page
  void deleteCategory({required CategoryType type, required String categoryName}) {
    switch (type) {
      case CategoryType.grocery:
        groceryCategoriesMap.remove(categoryName);
        groceryCategoryOrder.remove(categoryName);
        if (groceryItemsMap[categoryName]!.isNotEmpty) {
          groceryItemsMap.update("Other", (list) => list..addAll(groceryItemsMap[categoryName]!), ifAbsent: () {
            groceryCategoriesMap["Other"] = Colors.blueGrey.value;
            groceryCategoryOrder.add("Other");
            return groceryItemsMap[categoryName]!;
          });
        }
        groceryItemsMap.remove(categoryName);

        mealPlanmingBox.put('groceryCategoryOrder', groceryCategoryOrder);
        mealPlanmingBox.put('groceryCategoriesMap', groceryCategoriesMap);
        mealPlanmingBox.put('groceryItemsMap', groceryItemsMap);

        break;

      case CategoryType.recipe:
        recipeCategoriesMap.remove(categoryName);

        // If the category is not empty, add the "Other" category to the recipe if it has no other categories attached to it
        if (recipeCategoriesToRecipeTitlesMap[categoryName]!.isNotEmpty) {
          recipeCategoriesToRecipeTitlesMap.update("Other", (list) {
            for (String recipeName in recipeCategoriesToRecipeTitlesMap[categoryName]!) {
              Recipe oldRecipe = recipeTitlestoRecipeMap[recipeName]!;

              if (recipeTitlestoRecipeMap[recipeName]!.categories.length == 1) {
                list.add(recipeName);
                oldRecipe.edit(
                    title: oldRecipe.title,
                    ingredients: oldRecipe.ingredients,
                    subsectionOrder: oldRecipe.subsectionOrder,
                    instructions: oldRecipe.instructions,
                    categories: ["Other"],
                    prepTime: oldRecipe.prepTime);
              } else {
                oldRecipe.edit(
                    title: oldRecipe.title,
                    ingredients: oldRecipe.ingredients,
                    subsectionOrder: oldRecipe.subsectionOrder,
                    instructions: oldRecipe.instructions,
                    categories: oldRecipe.categories..remove(categoryName),
                    prepTime: oldRecipe.prepTime);
              }
              // Remove the deleted category from the recipe's category list
              recipeList.remove(recipeTitlestoRecipeMap[recipeName]!);
              recipeTitlestoRecipeMap[recipeName] = oldRecipe;
              recipeList.add(oldRecipe);
              oldRecipe.save();
            }

            return list;
          }, ifAbsent: () {
            recipeCategoriesMap["Other"] = Colors.blueGrey.value;
            List<String> list = [];
            for (String recipeName in recipeCategoriesToRecipeTitlesMap[categoryName]!) {
              Recipe oldRecipe = recipeTitlestoRecipeMap[recipeName]!;

              if (recipeTitlestoRecipeMap[recipeName]!.categories.length == 1) {
                list.add(recipeName);
                oldRecipe.edit(
                    title: oldRecipe.title,
                    ingredients: oldRecipe.ingredients,
                    subsectionOrder: oldRecipe.subsectionOrder,
                    instructions: oldRecipe.instructions,
                    categories: ["Other"],
                    prepTime: oldRecipe.prepTime);
              } else {
                oldRecipe.edit(
                    title: oldRecipe.title,
                    ingredients: oldRecipe.ingredients,
                    subsectionOrder: oldRecipe.subsectionOrder,
                    instructions: oldRecipe.instructions,
                    categories: oldRecipe.categories..remove(categoryName),
                    prepTime: oldRecipe.prepTime);
              }
              // Remove the deleted category from the recipe's category list
              recipeList.remove(recipeTitlestoRecipeMap[recipeName]!);
              recipeTitlestoRecipeMap[recipeName] = oldRecipe;
              recipeList.add(oldRecipe);
              oldRecipe.save();
            }
            return list;
          });
        }
        recipeCategoriesToRecipeTitlesMap.remove(categoryName);

        mealPlanmingBox.put('recipeCategoriesMap', recipeCategoriesMap);

        break;

      case CategoryType.generic:
        genericCategoriesMap.remove(categoryName);
        for (int i = 0; i < weeklyMealsList.length; i++) {
          if (weeklyMealsList[i] == categoryName) {
            weeklyMealsList[i] = "";
            weeklyMealsSplit[(i / 5).floor()][i % 5] = "";
          }
        }
        mealPlanmingBox.put('genericCategoriesMap', genericCategoriesMap);
        mealPlanmingBox.put('weeklyMealsList', weeklyMealsList);
        break;
    }
  }

  void addCategory({required CategoryType type, required String categoryName, required int color}) {
    switch (type) {
      case CategoryType.grocery:
        groceryCategoriesMap[categoryName] = color;
        mealPlanmingBox.put('groceryCategoriesMap', groceryCategoriesMap);

        groceryItemsMap.addAll({categoryName: []});
        mealPlanmingBox.put('groceryItemsMap', groceryItemsMap);

        groceryCategoryOrder.add(categoryName);
        mealPlanmingBox.put('groceryCategoryOrder', groceryCategoryOrder);
        break;

      case CategoryType.recipe:
        recipeCategoriesMap[categoryName] = color;
        recipeCategoriesToRecipeTitlesMap[categoryName] = [];
        mealPlanmingBox.put('recipeCategoriesMap', recipeCategoriesMap);
        break;

      case CategoryType.generic:
        genericCategoriesMap[categoryName] = color;
        mealPlanmingBox.put('genericCategoriesMap', genericCategoriesMap);
        break;
    }
  }

  void updateCategory({required CategoryType type, required String oldName, String? newName, int? color}) {
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
        mealPlanmingBox.put('groceryCategoriesMap', groceryCategoriesMap);
        mealPlanmingBox.put('groceryCategoryOrder', groceryCategoryOrder);
        mealPlanmingBox.put('groceryItemsMap', groceryItemsMap);
        break;

      case CategoryType.recipe:
        if (color != null) {
          recipeCategoriesMap[oldName] = color;
        } else {
          int val = recipeCategoriesMap.remove(oldName)!;
          recipeCategoriesMap[newName!] = val;
          List<String> items = recipeCategoriesToRecipeTitlesMap.remove(oldName)!;
          recipeCategoriesToRecipeTitlesMap[newName] = items;
          for (String recipeTitle in items) {
            recipeTitlestoRecipeMap[recipeTitle]!.categories.remove(oldName);
            recipeTitlestoRecipeMap[recipeTitle]!.categories.add(newName);
            recipeTitlestoRecipeMap[recipeTitle]!.save();
          }
        }
        mealPlanmingBox.put('recipeCategoriesMap', recipeCategoriesMap);
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
        mealPlanmingBox.put('genericCategoriesMap', genericCategoriesMap);
        mealPlanmingBox.put('weeklyMealsList', weeklyMealsList);
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
    mealPlanmingBox.put('groceryItemsMap', groceryItemsMap);
  }

  void deleteGroceryItems({required Map<String, List<GroceryItem>> itemsToDelete, required bool clearAll}) {
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
    mealPlanmingBox.put('groceryItemsMap', groceryItemsMap);
  }

  void addGroceryItem(GroceryItem item, String category) {
    groceryItemsMap[category]!.add(item);
    mealPlanmingBox.put('groceryItemsMap', groceryItemsMap);
  }

  void updateGroceryCategoryOrder({required List<String> newOrder}) {
    groceryCategoryOrder = newOrder;
    mealPlanmingBox.put('groceryCategoryOrder', groceryCategoryOrder);
  }

  // Recipe page functions
  void addRecipe({required Recipe recipe}) {
    remcipesBox.add(recipe);
    recipeList.add(recipe);
    recipeTitlestoRecipeMap.addEntries({recipe.title: recipe}.entries);
    for (String category in recipe.categories) {
      recipeCategoriesToRecipeTitlesMap[category]!.add(recipe.title);
    }
  }

  void deleteRecipe({required Recipe recipe}) {
    assert(recipeList.remove(recipe));
    recipeTitlestoRecipeMap.remove(recipe.title);
    for (String category in recipe.categories) {
      recipeCategoriesToRecipeTitlesMap[category]!.remove(recipe.title);
    }
    recipe.delete();
  }

  void updateRecipe({required Recipe oldRecipe, required Recipe updatedRecipe}) {
    updatedRecipe.save();
    recipeList.remove(oldRecipe);
    recipeList.add(updatedRecipe);

    recipeTitlestoRecipeMap.remove(oldRecipe.title);
    recipeTitlestoRecipeMap[updatedRecipe.title] = updatedRecipe;

    for (String category in oldRecipe.categories) {
      recipeCategoriesToRecipeTitlesMap[category]!.remove(oldRecipe.title);
    }

    for (String category in updatedRecipe.categories) {
      recipeCategoriesToRecipeTitlesMap[category]!.add(updatedRecipe.title);
    }
  }

  // Create a backup of current data and import data from the selected zip file
  Future<bool> importFile(bool isAndroid) async {
    // Get the paths to each of the box files
    String firstBoxPath = remcipesBox.path!;
    String secondBoxPath = mealPlanmingBox.path!;

    // If any data is present in the app, export a backup for the user
    if (mealPlanmingBox.isNotEmpty || remcipesBox.isNotEmpty) {
      // Get a directory to export to
      String? selectedDirectory =
          isAndroid ? (await getExternalStorageDirectory())?.path : (await getApplicationDocumentsDirectory()).path;

      if (selectedDirectory == null) {
        return false;
      }

      // Create a zip file
      var encoder = ZipFileEncoder();
      encoder.create("$selectedDirectory/back_up_meal_planning.zip");

      // Close the hives first
      await remcipesBox.close();
      await mealPlanmingBox.close();

      // Add the box files to the zip
      encoder.addFile((File(firstBoxPath)));
      encoder.addFile((File(secondBoxPath)));
      encoder.close();

      // Re-open the boxes
      remcipesBox = await Hive.openBox<Recipe>('remcipesBox');
      mealPlanmingBox = await Hive.openBox<dynamic>('mealPlanmingBox');
    }

    // Get the user to pick a zip file
    FilePicker.platform.clearTemporaryFiles();
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(dialogTitle: "Choose zip file", type: FileType.custom, allowedExtensions: ['zip']);

    if (result != null) {
      await remcipesBox.close();
      await mealPlanmingBox.close();

      final inputStream = InputFileStream(result.files.single.path!);
      final archive = ZipDecoder().decodeStream(inputStream);

      // For all of the entries in the archive
      final firstStream = OutputFileStream(firstBoxPath);
      final secondStream = OutputFileStream(secondBoxPath);

      // Ensure there are only 2 files in the zip
      if (archive.files.length != 2) return false;

      // If the files aren't hive files, not sure how to stop the user from inputting those
      // Checking file names doesn't matter because a user can just rename their input files to contain the right strings and extensions
      // Not sure what to do

      for (int i = 0; i < 2; i++) {
        if (archive.files[i].name.contains('remcipes')) {
          archive.files[i].writeContent(firstStream);
          firstStream.close();
        } else {
          archive.files[i].writeContent(secondStream);
          secondStream.close();
        }
      }

      remcipesBox = await Hive.openBox<Recipe>('remcipesBox');
      mealPlanmingBox = await Hive.openBox<dynamic>('mealPlanmingBox');

      return true;
    }
    return false;
  }

  // Export the data in the app to a zip file
  Future exportFile(bool isAndroid) async {
    // Permission.storage.request();
    // if (await Permission.storage.request().isGranted) {
    //   {
    String? selectedDirectory =
        isAndroid ? (await getExternalStorageDirectory())?.path : (await getApplicationDocumentsDirectory()).path;
    if (selectedDirectory != null) {
      var encoder = ZipFileEncoder();
      encoder.create("$selectedDirectory/meal_planning.zip");
      String firstBoxPath = remcipesBox.path!;
      String secondBoxPath = mealPlanmingBox.path!;

      await remcipesBox.close();
      await mealPlanmingBox.close();

      await encoder.addFile((File(firstBoxPath)));
      await encoder.addFile((File(secondBoxPath)));
      encoder.close();
      SharePlus.instance.share(
        ShareParams(
            sharePositionOrigin: Rect.fromLTWH(0, 0, 100.w, 100.h / 2),
            subject: 'Meal Planning backup file',
            files: [XFile("$selectedDirectory/meal_planning.zip", name: "meal_planning.zip")]),
      );

      remcipesBox = await Hive.openBox<Recipe>('remcipesBox');
      mealPlanmingBox = await Hive.openBox<dynamic>('mealPlanmingBox');

      return selectedDirectory;
    }
  }
}
