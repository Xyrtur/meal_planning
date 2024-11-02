import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/utils/hive_repository.dart';

class ToggleGroceryDeletingCubit extends Cubit<bool> {
  ToggleGroceryDeletingCubit() : super(false);
  void toggle() => emit(!state);
}
