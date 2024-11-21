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
  final Recipe recipe;
  const UpdateRecipe(this.recipe);
}

class EditRecipeClicked extends RecipeEvent {
  final Recipe recipe;
  const EditRecipeClicked(this.recipe);
}

sealed class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object> get props => [];
}

class ViewingRecipe extends RecipeState {
  final Recipe recipe;
  const ViewingRecipe(this.recipe);
}

class EditingRecipe extends RecipeState {
  final Recipe? recipe;
  const EditingRecipe(this.recipe);
}

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final HiveRepository hive;
  final Recipe? recipe;
  RecipeBloc(this.hive, this.recipe)
      : super(() {
          return recipe == null
              ? const EditingRecipe(null)
              : ViewingRecipe(recipe);
        }()) {
    on<AddRecipe>((event, emit) {
      hive.addRecipe();
      emit(ViewingRecipe(event.recipe));
    });
    on<DeleteRecipe>((event, emit) {
      hive.deleteRecipe();
      emit(ViewingRecipe(event.recipe));
    });
    on<UpdateRecipe>((event, emit) {
      hive.updateRecipe();
      emit(ViewingRecipe(event.recipe));
    });
    on<EditRecipeClicked>((event, emit) {
      emit(EditingRecipe(event.recipe));
    });
  }
}
