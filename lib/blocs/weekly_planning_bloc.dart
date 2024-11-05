import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/models/recipe.dart';
import 'package:meal_planning/utils/hive_repository.dart';

sealed class WeeklyPlanningEvent {
  const WeeklyPlanningEvent();
}

class WeeklyPlanningWeekRangePressed extends WeeklyPlanningEvent {
  final int selected;
  const WeeklyPlanningWeekRangePressed(this.selected);
}

class WeeklyPlanningUpdateMeal extends WeeklyPlanningEvent {
  final String selectedMeal;
  final int index;
  const WeeklyPlanningUpdateMeal(this.selectedMeal, this.index);
}

sealed class WeeklyPlanningState {
  const WeeklyPlanningState();
}

class WeeklyPlanningInitial extends WeeklyPlanningState {
  final int initialSelected;
  final List<List<String>> mealsList;
  final List<DateTime> currentWeekRanges;
  final Map<String, Recipe> recipeTitlestoRecipeMap;
  const WeeklyPlanningInitial(this.initialSelected, this.mealsList,
      this.currentWeekRanges, this.recipeTitlestoRecipeMap);
}

class WeeklyPlanningWeekRangeUpdated extends WeeklyPlanningState {
  final int selected;
  const WeeklyPlanningWeekRangeUpdated(this.selected);
}

class WeeklyPlanningMealsUpdated extends WeeklyPlanningState {
  final List<List<String>> mealsList;
  const WeeklyPlanningMealsUpdated(this.mealsList);
}

class WeeklyPlanningBloc
    extends Bloc<WeeklyPlanningEvent, WeeklyPlanningState> {
  final HiveRepository hive;

  WeeklyPlanningBloc(this.hive)
      : super(WeeklyPlanningInitial(0, hive.weeklyMealsSplit,
            hive.currentWeekRanges, hive.recipeTitlestoRecipeMap)) {
    on<WeeklyPlanningWeekRangePressed>((event, emit) {
      emit(WeeklyPlanningWeekRangeUpdated(event.selected));
    });

    on<WeeklyPlanningUpdateMeal>((event, emit) {
      hive.updateWeeklyMeals(event.index, event.selectedMeal);
      emit(WeeklyPlanningMealsUpdated(hive.weeklyMealsSplit));
    });
  }
}
