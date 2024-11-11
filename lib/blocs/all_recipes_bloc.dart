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
  const AllRecipesListUpdated(
      super.filteredRecipeList, super.toggledCategories);
}

class AllRecipesBloc extends Bloc<AllRecipesEvent, AllRecipesState> {
  final HiveRepository hive;
  List<String> filteredRecipeList = [];
  List<String> toggledCategories = [];

  AllRecipesBloc(this.hive)
      : super(AllRecipesInitial(
            hive.recipeTitlestoRecipeMap.keys.toList()..sort(), [])) {
    List<String> sortedAllRecipesList =
        hive.recipeTitlestoRecipeMap.keys.toList()..sort();
    on<FilterToggle>((event, emit) {
      if (!toggledCategories.remove(event.category)) {
        toggledCategories.add(event.category);
        filteredRecipeList
            .addAll(hive.recipeCategoriesToRecipeTitlesMap[event.category]!);
      } else {
        for (int i = 0;
            i < hive.recipeCategoriesToRecipeTitlesMap[event.category]!.length;
            i++) {
          filteredRecipeList.removeAt(i);
        }
      }

      emit(FiltersChanged(
          filteredRecipeList.isEmpty ? sortedAllRecipesList : filteredRecipeList
            ..sort(),
          toggledCategories));
    });

    on<SearchClicked>((event, emit) {
      String reg = (event.searchString
          .split(" ")
          .map((word) => '(?=.*${RegExp.escape(word)})')
          .join());
      RegExp reg1 = RegExp("^$reg", caseSensitive: false);
      List<String> prunedList =
          filteredRecipeList.isEmpty ? sortedAllRecipesList : filteredRecipeList
            ..sort();
      for (int i = 0; i < prunedList.length; i++) {
        if (!reg1.hasMatch(prunedList[i])) {
          prunedList.removeAt(i);
        }
      }
      emit(AllRecipesListUpdated(prunedList, toggledCategories));
    });
  }
}
