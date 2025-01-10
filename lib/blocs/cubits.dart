import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/screens/recipe_page.dart';
import 'package:meal_planning/utils/hive_repository.dart';

class ToggleGroceryDeletingCubit extends Cubit<bool> {
  ToggleGroceryDeletingCubit() : super(false);
  void toggle() => emit(!state);
}

class GroceryAddEntryCubit extends Cubit<String> {
  GroceryAddEntryCubit() : super("");
  // [bool AddEntryTileExists, String CategoryWhereItExists]
  void update(String addEntryInCategory) {
    emit(addEntryInCategory);
  }
}

class GroceryCategoryOrderCubit extends Cubit<List<String>> {
  final HiveRepository hive;
  GroceryCategoryOrderCubit(this.hive) : super(hive.groceryCategoryOrder);

  void update(List<String> newOrder) {
    hive.updateGroceryCategoryOrder(newOrder: newOrder);
    emit(newOrder);
  }
}

class GroceryDraggingItemCubit extends Cubit<List<dynamic>> {
  GroceryDraggingItemCubit() : super([null, null]);
  // int? draggingIndex, int? hoverIndex

  void update({required int? draggingIndex, required int? hoveringIndex, required String? originCategory}) {
    emit([draggingIndex, hoveringIndex, originCategory]);
  }
}

class GroceryScrollDraggingCubit extends Cubit<bool> {
  GroceryScrollDraggingCubit() : super(false);

  void update({required bool isDragging}) {
    emit(isDragging);
  }
}

class GroceryCategoryHover extends Cubit<String> {
  GroceryCategoryHover() : super("");

  void update({required String hoveredCategory}) {
    emit(hoveredCategory);
  }
}

class IngredientToGroceryCategoryHover extends Cubit<String> {
  IngredientToGroceryCategoryHover() : super("");

  void update({required String hoveredCategory}) {
    emit(hoveredCategory);
  }
}

class SettingsEditingTextCubit extends Cubit<List<String>> {
  SettingsEditingTextCubit() : super(["", ""]);

  void editing({required String type, required String name}) {
    emit([type, name]);
  }
}

class SettingsAddColorCubit extends Cubit<int?> {
  final int? color;
  SettingsAddColorCubit(this.color) : super(color);

  void selectColor({required int? color}) {
    emit(color);
  }
}

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

class RecipeIngredientKeysCubit extends Cubit<List<GlobalKey<RecipeTextFieldState>>> {
  final List<GlobalKey<RecipeTextFieldState>> keys;

  RecipeIngredientKeysCubit(this.keys) : super(keys);

  void add({required int numKeys, required int ingredientOrderNumber}) {
    final newList = [...state];
    if (ingredientOrderNumber == -1) {
      GlobalKey<RecipeTextFieldState> createdKey = GlobalKey<RecipeTextFieldState>();
      newList.add(createdKey);
    } else {
      for (int i = 0; i < numKeys; i++) {
        if (i == 0) {
          GlobalKey<RecipeTextFieldState> createdKey = GlobalKey<RecipeTextFieldState>();
          newList[ingredientOrderNumber] = createdKey;
        } else {
          GlobalKey<RecipeTextFieldState> createdKey = GlobalKey<RecipeTextFieldState>();
          newList.insert(ingredientOrderNumber + i, createdKey);
        }
      }
    }
    emit(newList);
  }

  void replaceList({required int numKeys}) {
    final List<GlobalKey<RecipeTextFieldState>> newList = [];
    for (int i = 0; i < numKeys; i++) {
      GlobalKey<RecipeTextFieldState> createdKey = GlobalKey<RecipeTextFieldState>();
      newList.add(createdKey);
    }

    emit(newList);
  }

  void deleteKey({required int ingredientOrderNumber}) {
    final newList = [...state];
    newList.removeAt(ingredientOrderNumber);
    emit(newList);
  }
}

class RecipeInstructionsKeysCubit extends Cubit<List<GlobalKey<RecipeTextFieldState>>> {
  final List<GlobalKey<RecipeTextFieldState>> keys;

  RecipeInstructionsKeysCubit(this.keys) : super(keys);

  void add({required int numKeys, required int stepNumber}) {
    final newList = [...state];
    if (stepNumber == -1) {
      GlobalKey<RecipeTextFieldState> createdKey = GlobalKey<RecipeTextFieldState>();
      newList.add(createdKey);
    } else {
      for (int i = 0; i < numKeys; i++) {
        if (i == 0) {
          GlobalKey<RecipeTextFieldState> createdKey = GlobalKey<RecipeTextFieldState>();
          newList[stepNumber] = createdKey;
        } else {
          GlobalKey<RecipeTextFieldState> createdKey = GlobalKey<RecipeTextFieldState>();
          newList.insert(stepNumber + i, createdKey);
        }
      }
    }
    emit(newList);
  }

  void replaceList({required int numKeys}) {
    final List<GlobalKey<RecipeTextFieldState>> newList = [];
    for (int i = 0; i < numKeys; i++) {
      GlobalKey<RecipeTextFieldState> createdKey = GlobalKey<RecipeTextFieldState>();
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

  void replace({required String ingredient, required int ingredientOrderNumber}) {
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
}

enum PageSelected { weeklyPlanning, grocery, recipes }

class NavbarCubit extends Cubit<PageSelected> {
  final PageSelected page;
  NavbarCubit(this.page) : super(page);

  void changePage({required PageSelected page}) {
    emit(page);
  }
}
