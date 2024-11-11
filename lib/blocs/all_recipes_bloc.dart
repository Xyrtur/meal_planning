/*
 * Filter button logic for All Recipes page
 * 
 *  * Filter logic
 * Filter by available recipe categories
 * Have filterToggledList > if empty, show all recipes in current recipe list
 *  List<Recipe> filteredRecipeList = [];

 *  For each recipe in current list {
 *    for category in recipe.categories {
 *      if recipe.category in toggled filters > add to list + break loop
 * 
 * }
 * }
 * 
 * returns list of Recipes to display
 */

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/utils/hive_repository.dart';

sealed class AllRecipesEvent extends Equatable {
  const AllRecipesEvent();
  @override
  List<Object> get props => [];
}

class FilterToggle extends AllRecipesEvent {
  final String category;
  const FilterToggle(this.category);

  @override
  List<Object> get props => [category];
}

class SearchClicked extends AllRecipesEvent {
  final String searchString;
  const SearchClicked(this.searchString);

  @override
  List<Object> get props => [searchString];
}

sealed class AllRecipesState extends Equatable {
  final List<String> filteredRecipeList;
  final List<String> toggledCategories;
  const AllRecipesState(this.filteredRecipeList, this.toggledCategories);

  @override
  List<Object> get props => [filteredRecipeList, toggledCategories];
}

class AllRecipesInitial extends AllRecipesState {
  const AllRecipesInitial(super.filteredRecipeList, super.toggledCategories);
}

class FiltersChanged extends AllRecipesState {
  const FiltersChanged(super.filteredRecipeList, super.toggledCategories);
}

class AllRecipesListUpdated extends AllRecipesState {
  const AllRecipesListUpdated(super.filteredRecipeList, super.toggledCategories);
}

class AllRecipesBloc extends Bloc<AllRecipesEvent, AllRecipesState> {
  final HiveRepository hive;
  List<String> filteredRecipeList = [];
  List<String> toggledCategories = [];

  AllRecipesBloc(this.hive) : super(AllRecipesInitial(hive.recipeTitlestoRecipeMap.keys.toList(), [])) {
    on<FilterToggle>((event, emit) {
      if (!toggledCategories.remove(event.category)) {
        toggledCategories.add(event.category);
        filteredRecipeList.add(hive.recipeCategoriesToRecipesMap)
      }else{

      }
      filteredRecipeList.
      emit(FiltersChanged());
    });

    on<SearchClicked>((event, emit) {
      emit(AllRecipesListUpdated(event.selected));
    });
  }
}
