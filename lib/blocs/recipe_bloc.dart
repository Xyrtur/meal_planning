import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/hive_repository.dart';

sealed class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

class AddRecipe extends RecipeEvent {
  final Recipe recipe;
  const AddRecipe(this.recipe);
}

class DeleteRecipe extends RecipeEvent {
  final Recipe recipe;
  const DeleteRecipe(this.recipe);
}

class UpdateRecipe extends RecipeEvent {
  final Recipe oldRecipe;
  final Recipe newRecipe;
  const UpdateRecipe(this.oldRecipe, this.newRecipe);
}

class EditRecipeClicked extends RecipeEvent {
  final Recipe recipe;
  const EditRecipeClicked(this.recipe);
}

sealed class RecipeState extends Equatable {
  final Recipe? recipe;
  const RecipeState({this.recipe});

  @override
  List<Object> get props => [];
}

class ViewingRecipe extends RecipeState {
  @override
  covariant Recipe recipe;

  ViewingRecipe(this.recipe);
}

class EditingRecipe extends RecipeState {
  const EditingRecipe({super.recipe});
}

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final HiveRepository hive;
  final Recipe? recipe;
  RecipeBloc(this.hive, this.recipe)
      : super(() {
          return recipe == null ? const EditingRecipe(recipe: null) : ViewingRecipe(recipe);
        }()) {
    on<AddRecipe>((event, emit) {
      hive.addRecipe(recipe: event.recipe);
      emit(ViewingRecipe(event.recipe));
    });
    on<DeleteRecipe>((event, emit) {
      hive.deleteRecipe(recipe: event.recipe);
      emit(ViewingRecipe(event.recipe));
    });
    on<UpdateRecipe>((event, emit) {
      hive.updateRecipe(oldRecipe: event.oldRecipe, updatedRecipe: event.newRecipe);
      emit(ViewingRecipe(event.newRecipe));
    });
    on<EditRecipeClicked>((event, emit) {
      emit(EditingRecipe(recipe: event.recipe));
    });
  }
}
