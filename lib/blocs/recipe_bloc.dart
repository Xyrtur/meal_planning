import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/hive_repository.dart';

sealed class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

sealed class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object> get props => [];
}

class RecipeInitial extends RecipeState {
  const RecipeInitial();
}

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final HiveRepository hive;
  RecipeBloc(this.hive) : super(RecipeInitial()) {}
}
