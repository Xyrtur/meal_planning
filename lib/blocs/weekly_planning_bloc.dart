import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/utils/hive_repository.dart';

sealed class WeeklyPlanningEvent {
  const WeeklyPlanningEvent();
}

class WeeklyPlanningWeekRangePressed extends WeeklyPlanningEvent {
  final int chosen;
  const WeeklyPlanningWeekRangePressed(this.chosen);
}

sealed class WeeklyPlanningState {
  const WeeklyPlanningState();
}

class WeeklyPlanningInitial extends WeeklyPlanningState {
  const WeeklyPlanningInitial();
}

class WeeklyPlanningBloc
    extends Bloc<WeeklyPlanningEvent, WeeklyPlanningState> {
  final HiveRepository hive;

  WeeklyPlanningBloc(this.hive) : super(WeeklyPlanningInitial());
}
