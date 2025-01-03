import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/utils/hive_repository.dart';

enum Updating { checked, ingredients }

sealed class GroceryEvent extends Equatable {
  const GroceryEvent();

  @override
  List<Object?> get props => [];
}

final class ToggleGroceryCategory extends GroceryEvent {
  final String category;
  const ToggleGroceryCategory(this.category);

  @override
  List<Object> get props => [category];
}

final class AddIngredient extends GroceryEvent {
  final String item;
  final String category;
  const AddIngredient(this.item, this.category);

  @override
  List<Object> get props => [item, category];
}

final class UpdateIngredientsChecked extends GroceryEvent {
  final bool? checked;
  final int? index;
  final String category;
  const UpdateIngredientsChecked(this.checked, this.index, this.category);

  @override
  List<Object?> get props => [checked, index, category];
}

final class UpdateIngredientsCategory extends GroceryEvent {
  final Map<String, List<GroceryItem>> items;
  final String newCategory;
  final bool onlyItemOrderChanged;
  const UpdateIngredientsCategory({required this.items, required this.newCategory, required this.onlyItemOrderChanged});

  @override
  List<Object> get props => [items, newCategory];
}

final class DeleteIngredients extends GroceryEvent {
  final Map<String, List<GroceryItem>> items;
  final bool clearAll;
  const DeleteIngredients({required this.items, required this.clearAll});

  @override
  List<Object> get props => [items];
}

final class IngredientsImported extends GroceryEvent {
  const IngredientsImported();
}

sealed class GroceryState {
  final Map<String, List<GroceryItem>> items;
  const GroceryState(this.items);

  List<Object?> get props => [items];
}

final class GroceryInitial extends GroceryState {
  const GroceryInitial(super.items);

  @override
  List<Object?> get props => [items];
}

final class GroceryListUpdated extends GroceryState {
  const GroceryListUpdated(super.items);

  @override
  List<Object?> get props => [items];
}

final class GroceryCategoryToggled extends GroceryState {
  final String category;
  const GroceryCategoryToggled(super.items, this.category);

  @override
  List<Object?> get props => [items, category];
}

class GroceryBloc extends Bloc<GroceryEvent, GroceryState> {
  final HiveRepository hive;

  GroceryBloc(this.hive) : super(GroceryInitial(hive.groceryItemsMap)) {
    on<AddIngredient>((event, emit) {
      hive.addGroceryItem(GroceryItem(name: event.item, isChecked: false), event.category);
      emit(GroceryListUpdated(hive.groceryItemsMap));
    });

    on<UpdateIngredientsCategory>((event, emit) {
      hive.updateGroceryItems(
          noCategoryUpdated: event.onlyItemOrderChanged,
          updatingChecked: false,
          items: event.items,
          currentCategory: event.newCategory);
      emit(GroceryListUpdated(hive.groceryItemsMap));
    });

    on<UpdateIngredientsChecked>((event, emit) {
      hive.updateGroceryItems(
          noCategoryUpdated: false,
          updatingChecked: true,
          currentCategory: event.category,
          checked: event.checked,
          index: event.index);
      emit(GroceryListUpdated(hive.groceryItemsMap));
    });

    on<DeleteIngredients>((event, emit) {
      hive.deleteGroceryItems(itemsToDelete: event.items, clearAll: event.clearAll);
      emit(GroceryListUpdated(hive.groceryItemsMap));
    });

    on<ToggleGroceryCategory>((event, emit) {
      emit(GroceryCategoryToggled(hive.groceryItemsMap, event.category));
    });

    on<IngredientsImported>((event, emit) {
      emit(GroceryListUpdated(hive.groceryItemsMap));
    });
  }
}
