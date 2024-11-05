import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meal_planning/utils/hive_repository.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class SettingsAddCategory extends SettingsEvent {
  const SettingsAddCategory();
}

class SettingsDeleteCategory extends SettingsEvent {
  const SettingsDeleteCategory();
}

class SettingsUpdateCategory extends SettingsEvent {
  const SettingsUpdateCategory();
}

sealed class SettingsState {
  final Map<String, int> groceryCategoriesMap;
  final Map<String, int> recipeCategoriesMap;
  final Map<String, int> genericCategoriesMap;
  const SettingsState(this.groceryCategoriesMap, this.recipeCategoriesMap,
      this.genericCategoriesMap);

  List<Object> get props =>
      [groceryCategoriesMap, recipeCategoriesMap, genericCategoriesMap];
}

class SettingsUpdated extends SettingsState {
  const SettingsUpdated(super.groceryCategoriesMap, super.recipeCategoriesMap,
      super.genericCategoriesMap);
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final HiveRepository hive;

  SettingsBloc(this.hive)
      : super(SettingsUpdated(hive.groceryCategoriesMap,
            hive.recipeCategoriesMap, hive.genericCategoriesMap)) {
    on<SettingsAddCategory>((event, emit) {
      emit(SettingsUpdated(hive.groceryCategoriesMap, hive.recipeCategoriesMap,
          hive.genericCategoriesMap));
    });
    on<SettingsUpdateCategory>((event, emit) {
      emit(SettingsUpdated(hive.groceryCategoriesMap, hive.recipeCategoriesMap,
          hive.genericCategoriesMap));
    });
    on<SettingsDeleteCategory>((event, emit) {
      emit(SettingsUpdated(hive.groceryCategoriesMap, hive.recipeCategoriesMap,
          hive.genericCategoriesMap));
    });
  }
}
