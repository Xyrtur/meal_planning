import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/hive_repository.dart';

sealed class AllRecipesEvent extends Equatable {
  const AllRecipesEvent();
  @override
  List<Object> get props => [];
}

class CategoryUpdated extends AllRecipesEvent {
  const CategoryUpdated();
}

class RecipeAddDeleted extends AllRecipesEvent {
  const RecipeAddDeleted();
}

class RecipeClicked extends AllRecipesEvent {
  final String recipeName;
  const RecipeClicked(this.recipeName);
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

class RecipesImported extends AllRecipesEvent {
  const RecipesImported();
}

sealed class AllRecipesState {
  // Contains the recipe title and its corresponding category color
  final Map<String, List<int>> filteredRecipeMap;

  // Contains all possible recipe categories and their corresponding colors, null if not toggled
  final Map<String, int?> toggledCategories;

  const AllRecipesState(this.filteredRecipeMap, this.toggledCategories);

  List<Object> get props => [filteredRecipeMap, toggledCategories];
}

class AllRecipesInitial extends AllRecipesState {
  const AllRecipesInitial(super.filteredRecipeMap, super.toggledCategories);
}

class FiltersChanged extends AllRecipesState {
  const FiltersChanged(super.filteredRecipeMap, super.toggledCategories);
}

class AllRecipesListUpdated extends AllRecipesState {
  const AllRecipesListUpdated(super.filteredRecipeMap, super.toggledCategories);
}

class OpeningRecipePage extends AllRecipesState {
  final Recipe recipe;
  const OpeningRecipePage(super.filteredRecipeMap, super.toggledCategories, this.recipe);
}

class AllRecipesBloc extends Bloc<AllRecipesEvent, AllRecipesState> {
  final HiveRepository hive;
  Map<String, List<int>> filteredRecipes = {};
  Map<String, int?> toggledCategories = {};

  AllRecipesBloc(this.hive)
      : super(AllRecipesInitial(<String, List<int>>{
          for (String element in hive.recipeTitlestoRecipeMap.keys.toList())
            element: [
              for (String category in hive.recipeTitlestoRecipeMap[element]!.categories)
                hive.recipeCategoriesMap[category]!
            ]
        }, Map.from(hive.recipeCategoriesMap)..updateAll((key, value) => value = null))) {
    Map<String, List<int>> allRecipes = <String, List<int>>{
      for (String element in hive.recipeTitlestoRecipeMap.keys.toList())
        element: [
          for (String category in hive.recipeTitlestoRecipeMap[element]!.categories) hive.recipeCategoriesMap[category]!
        ]
    };
    toggledCategories = Map.from(hive.recipeCategoriesMap)..updateAll((key, value) => value = null);

    on<RecipeAddDeleted>((event, emit) {
      allRecipes = <String, List<int>>{
        for (String element in hive.recipeTitlestoRecipeMap.keys.toList())
          element: [
            for (String category in hive.recipeTitlestoRecipeMap[element]!.categories)
              hive.recipeCategoriesMap[category]!
          ]
      };
      emit(AllRecipesListUpdated(allRecipes, toggledCategories));
    });

    on<FilterToggle>((event, emit) {
      // If no category has been selected yet, can add all recipes belonging to that category
      if (toggledCategories[event.category] == null) {
        // If nothing was selected at first, add all recipes that share the first category
        if (toggledCategories.values.where((x) => x != null).toList().isEmpty) {
          filteredRecipes.addAll(<String, List<int>>{
            for (String recipeTitle in hive.recipeCategoriesToRecipeTitlesMap[event.category]!)
              recipeTitle: [
                for (String category in hive.recipeTitlestoRecipeMap[recipeTitle]!.categories)
                  hive.recipeCategoriesMap[category]!
              ]
          });

          // Otherwise, only allow recipes that share all currently selected categories
        } else {
          List<String> currentFilteredList = filteredRecipes.keys.toList();
          for (String recipeTitle in currentFilteredList) {
            if (!hive.recipeTitlestoRecipeMap[recipeTitle]!.categories.contains(event.category)) {
              filteredRecipes.remove(recipeTitle);
            }
          }
        }
        toggledCategories[event.category] = hive.recipeCategoriesMap[event.category]!;
      } else {
        toggledCategories[event.category] = null;
        // Completely clear filtered recipe list to re-add
        filteredRecipes.clear();
        // List of only the categories that are toggled, since toggledCategories is a map that will never be empty
        List<String> currentlyToggledList = toggledCategories.keys.where((x) => toggledCategories[x] != null).toList();

        // If at least one category is toggled
        if (currentlyToggledList.isNotEmpty) {
          filteredRecipes.addAll(<String, List<int>>{
            for (String recipeTitle in hive.recipeCategoriesToRecipeTitlesMap[currentlyToggledList.first]!)
              recipeTitle: [
                for (String category in hive.recipeTitlestoRecipeMap[recipeTitle]!.categories)
                  hive.recipeCategoriesMap[category]!
              ]
          });

          // If more than 1 category is toggled, remove the recipes that do not share all toggled categories
          if (currentlyToggledList.length > 1) {
            List<String> currentFilteredList = filteredRecipes.keys.toList();
            for (int i = 1; i < currentlyToggledList.length; i++) {
              for (String recipeTitle in currentFilteredList) {
                if (!hive.recipeTitlestoRecipeMap[recipeTitle]!.categories.contains(currentlyToggledList[i])) {
                  filteredRecipes.remove(recipeTitle);
                }
              }
            }
          }
        }
      }
      List<String> currentlyToggledList = toggledCategories.keys.where((x) => toggledCategories[x] != null).toList();

      emit(FiltersChanged(
          filteredRecipes.isEmpty
              ? currentlyToggledList.isEmpty
                  ? allRecipes
                  : {}
              : filteredRecipes,
          toggledCategories));
    });

    on<SearchClicked>((event, emit) {
      String reg = (event.searchString.split(" ").map((word) => '(?=.*${RegExp.escape(word)})').join());
      RegExp reg1 = RegExp("^$reg", caseSensitive: false);
      Map<String, List<int>> prunedMap = filteredRecipes.isEmpty ? Map.from(allRecipes) : Map.from(filteredRecipes);
      List<String> recipeTitlesToPrune = prunedMap.keys.toList();
      for (int i = 0; i < recipeTitlesToPrune.length; i++) {
        if (!reg1.hasMatch(recipeTitlesToPrune[i])) {
          prunedMap.remove(recipeTitlesToPrune[i]);
        }
      }
      emit(AllRecipesListUpdated(prunedMap, toggledCategories));
    });

    on<CategoryUpdated>((event, emit) {
      for (String category in hive.recipeCategoriesMap.keys) {
        toggledCategories.putIfAbsent(category, () => null);
      }
      emit(FiltersChanged(filteredRecipes.isEmpty ? allRecipes : filteredRecipes, toggledCategories));
    });

    on<RecipeClicked>((event, emit) {
      Recipe recipe = hive.recipeTitlestoRecipeMap[event.recipeName]!;
      emit(OpeningRecipePage(filteredRecipes, toggledCategories, recipe));
    });

    on<RecipesImported>((event, emit) {
      emit(AllRecipesListUpdated(allRecipes, toggledCategories));
    });
  }
}
