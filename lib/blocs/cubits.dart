import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/screens/recipe_page.dart';
import 'package:meal_planning/utils/hive_repository.dart';

/// Handles state for delete toggle on grocery page
class ToggleGroceryDeletingCubit extends Cubit<bool> {
  ToggleGroceryDeletingCubit() : super(false);
  void toggle() => emit(!state);
}

/// Keeps track of add entry textfield tile on the grocery page
///
/// Only one add textfield is allowed at a time no matter what category is being edited.
/// State is the name of the category where the add entry tile exists. State starts out empty until the user clicks the add button on a category.
class GroceryAddEntryCubit extends Cubit<String> {
  GroceryAddEntryCubit() : super("");

  /// The [addEntryInCategory] is the name of the category where add tile currently is
  ///
  /// If [addEntryInCategory] is empty, the add tile does not exist on page.
  void update(String addEntryInCategory) {
    emit(addEntryInCategory);
  }
}

/// Keeps track of the order that the user keeps the categories in.
class GroceryCategoryOrderCubit extends Cubit<List<String>> {
  final HiveRepository hive;
  GroceryCategoryOrderCubit(this.hive) : super(hive.groceryCategoryOrder);

  /// Updates the state given [newOrder]
  void update(List<String> newOrder) {
    hive.updateGroceryCategoryOrder(newOrder: newOrder);
    emit(newOrder);
  }
}

/// This cubit tracks the info of the ingredient the user is currently dragging around on the Grocery page.
///
/// User can change ingredient order within origin category, or move ingredient to different category though cannot control index in new category
///
/// State stores 3 different variables:
/// - [draggingIndex] is the index of the category being dragged. If null, nothing is being dragged.
/// - [hoveringIndex] is the index of the category the user is hovering over
/// - [originCategory] is name of the category from which the ingredient came from.
class GroceryDraggingItemCubit extends Cubit<List<dynamic>> {
  GroceryDraggingItemCubit() : super([null, null]);

  void update(
      {required int? draggingIndex,
      required int? hoveringIndex,
      required String? originCategory}) {
    emit([draggingIndex, hoveringIndex, originCategory]);
  }
}

/// This cubit tracks using an ingredient to hover over another category in the Grocery page, using the category name.
///
/// Cannot use _hoveringIndex_ from _GroceryDraggingItemCubit_ because categories will not have their own unique index due to dragging.
/// This cubit is used to know when the category is being hovered, so that the color can be faded to match
class GroceryCategoryHover extends Cubit<String> {
  GroceryCategoryHover() : super("");

  void update({required String hoveredCategory}) {
    emit(hoveredCategory);
  }
}

/// This cubit tracks using an ingredient to hover over a category in the dialog for adding recipe ingredients to the grocery list.
class IngredientToGroceryCategoryHover extends Cubit<String> {
  IngredientToGroceryCategoryHover() : super("");

  void update({required String hoveredCategory}) {
    emit(hoveredCategory);
  }
}

/// This cubit tracks what category name is being edited.
///
/// [type] can vary between _recipe_, _grocery_, and _generic_.
/// [name] is the original name of what is being edited. Unique names only.
class SettingsEditingTextCubit extends Cubit<List<String>> {
  SettingsEditingTextCubit() : super(["", ""]);

  void editing({required String type, required String name}) {
    emit([type, name]);
  }
}

/// This cubit tracks what color is selected in the color dialog on the settings page.
///
/// The initial state is the old color of the category.
class SettingsAddColorCubit extends Cubit<int?> {
  final int? color;
  SettingsAddColorCubit(this.color) : super(color);

  void selectColor({required int? color}) {
    emit(color);
  }
}

/// This cubit tracks the categories assigned to a recipe on the Recipe page.
///
/// State tracks the list of categories
class RecipeCategoriesSelectedCubit extends Cubit<List<String>> {
  final List<String> categories;
  RecipeCategoriesSelectedCubit(this.categories) : super(categories);

  void addDeleteCategory({required String category}) {
    final newList = [...state];

    if (!newList.remove(category)) {
      newList.add(category);
    }
    emit(newList);
  }
}

///
class RecipeIngredientKeysCubit
    extends Cubit<List<GlobalKey<RecipeTextFieldState>>> {
  final List<GlobalKey<RecipeTextFieldState>> keys;

  RecipeIngredientKeysCubit(this.keys) : super(keys);

  void add(
      {required int numKeys,
      required int ingredientOrderNumber,
      required bool pastingIn}) {
    final newList = [...state];
    if (!pastingIn) {
      GlobalKey<RecipeTextFieldState> createdKey =
          GlobalKey<RecipeTextFieldState>();
      if (ingredientOrderNumber == -1) {
        newList.add(createdKey);
      } else {
        newList.insert(ingredientOrderNumber, createdKey);
      }
    } else {
      for (int i = 0; i < numKeys; i++) {
        if (i == 0) {
          GlobalKey<RecipeTextFieldState> createdKey =
              GlobalKey<RecipeTextFieldState>();
          newList[ingredientOrderNumber] = createdKey;
        } else {
          GlobalKey<RecipeTextFieldState> createdKey =
              GlobalKey<RecipeTextFieldState>();
          newList.insert(ingredientOrderNumber + i, createdKey);
        }
      }
    }
    emit(newList);
  }

  void replaceList({required int numKeys}) {
    final List<GlobalKey<RecipeTextFieldState>> newList = [];
    for (int i = 0; i < numKeys; i++) {
      GlobalKey<RecipeTextFieldState> createdKey =
          GlobalKey<RecipeTextFieldState>();
      newList.add(createdKey);
    }

    emit(newList);
  }

  void deleteKey({required int ingredientOrderNumber}) {
    final newList = [...state];
    newList.removeAt(ingredientOrderNumber);
    emit(newList);
  }

  void shiftIngredientKeys(
      {required int start, required int end, required int newStart}) {
    final newList = [...state];
    List<GlobalKey<RecipeTextFieldState>> toShift =
        newList.sublist(start, end == -1 ? newList.length : end);
    if (newStart == start || newStart == -1 && end == -1) {
      // do nothing
    } else {
      newList.removeRange(start, end == -1 ? newList.length : end);
      newList.insertAll(newStart, toShift);
    }
    emit(newList);
  }
}

class RecipeInstructionsKeysCubit
    extends Cubit<List<GlobalKey<RecipeTextFieldState>>> {
  final List<GlobalKey<RecipeTextFieldState>> keys;

  RecipeInstructionsKeysCubit(this.keys) : super(keys);

  void add({required int numKeys, required int stepNumber}) {
    final newList = [...state];
    if (stepNumber == -1) {
      GlobalKey<RecipeTextFieldState> createdKey =
          GlobalKey<RecipeTextFieldState>();
      newList.add(createdKey);
    } else {
      for (int i = 0; i < numKeys; i++) {
        if (i == 0) {
          GlobalKey<RecipeTextFieldState> createdKey =
              GlobalKey<RecipeTextFieldState>();
          newList[stepNumber] = createdKey;
        } else {
          GlobalKey<RecipeTextFieldState> createdKey =
              GlobalKey<RecipeTextFieldState>();
          newList.insert(stepNumber + i, createdKey);
        }
      }
    }
    emit(newList);
  }

  void replaceList({required int numKeys}) {
    final List<GlobalKey<RecipeTextFieldState>> newList = [];
    for (int i = 0; i < numKeys; i++) {
      GlobalKey<RecipeTextFieldState> createdKey =
          GlobalKey<RecipeTextFieldState>();
      newList.add(createdKey);
    }

    emit(newList);
  }

  void deleteKey({required int stepNumber}) {
    final newList = [...state];
    newList.removeAt(stepNumber);
    emit(newList);
  }

  void reorder({required int oldIndex, required int newIndex}) {
    final newList = [...state];
    final GlobalKey<RecipeTextFieldState> item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    emit(newList);
  }
}

class IngredientsAlreadyDraggedCubit extends Cubit<List<String>> {
  final List<String> ingredients = [];
  IngredientsAlreadyDraggedCubit() : super([]);

  void add({required String item}) {
    final newList = [...state];
    if (!newList.contains(item)) {
      newList.add(item);
    }
    emit(newList);
  }
}

class MultiSelectIngredientsCubit extends Cubit<List<String>> {
  final List<String> multiSelected = [];
  MultiSelectIngredientsCubit() : super([]);

  void toggleMultiSelect({required String item}) {
    final newList = [...state];
    if (!newList.remove(item)) {
      newList.add(item);
    }
    emit(newList);
  }

  void clear() {
    emit([]);
  }
}

class InstructionsListCubit extends Cubit<List<String>> {
  final List<String> instructionsList;
  InstructionsListCubit(this.instructionsList) : super(instructionsList);

  void add({required String instruction, required int stepNumber}) {
    final newList = [...state];
    if (stepNumber == -1) {
      newList.add(instruction);
    } else {
      newList.insert(stepNumber, instruction);
    }
    emit(newList);
  }

  void replace({required String instruction, required int stepNumber}) {
    final newList = [...state];
    if (newList.isEmpty) {
      newList.add(instruction);
    } else {
      newList[stepNumber] = instruction;
    }
    emit(newList);
  }

  void replaceList({required List<String> newList}) {
    emit(newList);
  }

  void delete({required int stepNumber}) {
    final newList = [...state];
    newList.removeAt(stepNumber);
    emit(newList);
  }

  void reorder({required int oldIndex, required int newIndex}) {
    final newList = [...state];
    final String item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    emit(newList);
  }
}

class IngredientsListCubit extends Cubit<List<String>> {
  final List<String> ingredientsList;
  IngredientsListCubit(this.ingredientsList) : super(ingredientsList);

  void add({required String ingredient, required int ingredientOrderNumber}) {
    final newList = [...state];
    if (ingredientOrderNumber == -1) {
      newList.add(ingredient);
    } else {
      newList.insert(ingredientOrderNumber, ingredient);
    }
    emit(newList);
  }

  void replace(
      {required String ingredient, required int ingredientOrderNumber}) {
    final newList = [...state];
    if (newList.isEmpty) {
      newList.add(ingredient);
    } else {
      newList[ingredientOrderNumber] = ingredient;
    }
    emit(newList);
  }

  void replaceList({required List<String> newList}) {
    emit(newList);
  }

  void delete({required int ingredientOrderNumber}) {
    final newList = [...state];
    newList.removeAt(ingredientOrderNumber);
    emit(newList);
  }

  void shiftIngredients(
      {required int start, required int end, required int newStart}) {
    final newList = [...state];
    List<String> toShift =
        newList.sublist(start, end == -1 ? newList.length : end);
    if (newStart == start || newStart == -1 && end == -1) {
      // do nothing
    } else {
      newList.removeRange(start, end == -1 ? newList.length : end);
      newList.insertAll(newStart, toShift);
    }

    emit(newList);
  }
}

enum PageSelected { weeklyPlanning, grocery, recipes }

class NavbarCubit extends Cubit<PageSelected> {
  final PageSelected page;
  NavbarCubit(this.page) : super(page);

  void changePage({required PageSelected page}) {
    emit(page);
  }
}

class IngredientSubsectionsKeysCubit
    extends Cubit<Map<int, GlobalKey<RecipeTextFieldState>>> {
  final Map<int, GlobalKey<RecipeTextFieldState>> subsectionKeys;
  IngredientSubsectionsKeysCubit(this.subsectionKeys) : super(subsectionKeys);

  void addSubsection({required int ingredientIndex}) {
    final newMap = {...state};
    GlobalKey<RecipeTextFieldState> createdKey =
        GlobalKey<RecipeTextFieldState>();
    newMap[ingredientIndex] = createdKey;

    emit(newMap);
  }

  void replaceList() {
    final Map<int, GlobalKey<RecipeTextFieldState>> newMap = {};
    for (int oldKey in state.keys.toList()..sort()) {
      GlobalKey<RecipeTextFieldState> createdKey =
          GlobalKey<RecipeTextFieldState>();
      newMap[oldKey] = createdKey;
    }

    emit(newMap);
  }

  void shiftIndices(
      {int? subsectionDeleted,
      required List<int> oldIndices,
      required int shift}) {
    final newMap = {...state};
    List<int> newIndices =
        List.generate(oldIndices.length, (int i) => oldIndices[i] + shift);

    for (int oldIndex in oldIndices) {
      if (oldIndex == 0) {
        continue;
      }
      if (subsectionDeleted != null && subsectionDeleted < oldIndex) {
        continue;
      }

      // Remove old keys, unless rewritten over by new ones that just happen to be same key
      if (!newIndices.contains(oldIndex)) {
        newMap.remove(oldIndex);
      }
      newMap[oldIndex + shift] = state[oldIndex]!;
    }

    emit(newMap);
  }

  void deleteSubsection({required int ingredientIndex}) {
    final newMap = {...state};
    newMap.remove(ingredientIndex);

    emit(newMap);
  }
}
