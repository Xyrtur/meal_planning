import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/models/grocery_item.dart';
import 'package:meal_planning/utils/hive_repository.dart';

enum Updating { checked, ingredients }

sealed class GroceryEvent extends Equatable {
  const GroceryEvent();

  @override
  List<Object> get props => [];
}

final class ToggleGroceryCategory extends GroceryEvent {
  final String category;
  const ToggleGroceryCategory(this.category);

  @override
  List<Object> get props => [category];
}

final class AddIngredient extends GroceryEvent {
  final GroceryItem item;
  final String category;
  const AddIngredient(this.item, this.category);

  @override
  List<Object> get props => [item, category];
}

final class UpdateIngredientsChecked extends GroceryEvent {
  final bool? checked;
  final int index;
  final Map<String, List<GroceryItem>> items;
  const UpdateIngredientsChecked(this.checked, this.index, this.items);

  @override
  List<Object> get props => [checked ?? checked.toString(), index, items];
}

final class UpdateIngredientsCategory extends GroceryEvent {
  final Map<String, List<GroceryItem>> items;
  final String newCategory;
  final bool onlyItemOrderChanged;
  const UpdateIngredientsCategory(
      this.items, this.newCategory, this.onlyItemOrderChanged);

  @override
  List<Object> get props => [items, newCategory];
}

final class DeleteIngredients extends GroceryEvent {
  final Map<String, List<GroceryItem>> items;
  const DeleteIngredients(this.items);

  @override
  List<Object> get props => [items];
}

sealed class GroceryState extends Equatable {
  const GroceryState();

  @override
  List<Object?> get props => [];
}

final class GroceryInitial extends GroceryState {
  final Map<String, List<GroceryItem>> items;
  const GroceryInitial(this.items);

  @override
  List<Object?> get props => [items];
}

final class GroceryListUpdated extends GroceryState {
  final Map<String, List<GroceryItem>> items;
  const GroceryListUpdated(this.items);

  @override
  List<Object?> get props => [items];
}

final class GroceryCategoryToggled extends GroceryState {
  final String category;
  const GroceryCategoryToggled(this.category);

  @override
  List<Object?> get props => [category];
}

class GroceryBloc extends Bloc<GroceryEvent, GroceryState> {
  final HiveRepository hive;

  GroceryBloc(this.hive) : super(GroceryInitial(hive.groceryItemsMap)) {
    on<AddIngredient>((event, emit) {
      hive.addGroceryItem(event.item, event.category);
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
          items: event.items,
          checked: event.checked,
          index: event.index);
      emit(GroceryListUpdated(event.items));
    });

    on<DeleteIngredients>((event, emit) {
      hive.deleteGroceryItems(event.items);
      emit(GroceryListUpdated(hive.groceryItemsMap));
    });

    on<ToggleGroceryCategory>((event, emit) {
      emit(GroceryCategoryToggled(event.category));
    });
  }
}