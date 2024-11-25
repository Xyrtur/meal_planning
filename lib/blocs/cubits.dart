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

  void update(
      {required int? draggingIndex,
      required int? hoveringIndex,
      required String? originCategory}) {
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

class RecipeIngredientKeysCubit
    extends Cubit<List<GlobalKey<RecipeTextFieldState>>> {
  final List<GlobalKey<RecipeTextFieldState>> keys;

  RecipeIngredientKeysCubit(this.keys) : super(keys);

  void addKey() {
    GlobalKey<RecipeTextFieldState> createdKey =
        GlobalKey<RecipeTextFieldState>();
    final newList = [...state];
    newList.add(createdKey);
    emit(newList);
    // return createdKey;
  }

  void deleteKey({required GlobalKey<RecipeTextFieldState> key}) {
    final newList = [...state];
    assert(newList.remove(key));
    emit(newList);
  }
}

class RecipeInstructionsKeysCubit
    extends Cubit<List<GlobalKey<RecipeTextFieldState>>> {
  final List<GlobalKey<RecipeTextFieldState>> keys;

  RecipeInstructionsKeysCubit(this.keys) : super(keys);

  GlobalKey<RecipeTextFieldState> addKey() {
    GlobalKey<RecipeTextFieldState> createdKey =
        GlobalKey<RecipeTextFieldState>();
    state.add(createdKey);
    emit(state);
    return createdKey;
  }

  void deleteKey({required GlobalKey<RecipeTextFieldState> key}) {
    assert(state.remove(key));
    emit(state);
  }
}

class IngredientsAlreadyDraggedCubit extends Cubit<List<String>> {
  final List<String> ingredients = [];
  IngredientsAlreadyDraggedCubit() : super([]);

  void add({required String item}) {
    if (!ingredients.contains(item)) {
      ingredients.add(item);
    }
    emit(ingredients);
  }
}
