/*
 * Provided to: Recipe page, GroceryList page, all recipes page,
 * AddRecipeCategory
 *  do hivethings
 * 
 * AddGroceryCategory
 * 
 * DeleteRecipeCategory
 * DeleteGroceryCategory
 */

import 'package:bloc/bloc.dart';
import 'package:meal_planning/utils/hive_repository.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

sealed class SettingsState {
  const SettingsState();
}

class SettingsInitial extends SettingsState {
  //TODO: send through the category colors
  const SettingsInitial();
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final HiveRepository hive;

  SettingsBloc(this.hive) : super(const SettingsInitial());
}
