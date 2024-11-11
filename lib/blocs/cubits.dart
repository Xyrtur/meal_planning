import 'package:flutter_bloc/flutter_bloc.dart';
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

class SettingsEditingTextCubit extends Cubit<List<String>> {
  SettingsEditingTextCubit() : super(["", ""]);

  void editing({required String type, required String name}) {
    emit([type, name]);
  }
}

class SettingsAddColorCubit extends Cubit<int?> {
  SettingsAddColorCubit() : super(null);

  void selectColor({required int color}) {
    emit(color);
  }
}
