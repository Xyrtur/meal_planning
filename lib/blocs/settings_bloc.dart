import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meal_planning/utils/hive_repository.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object> get props => [];
}

class SettingsAddCategory extends SettingsEvent {
  final CategoryType type;
  final String name;
  final int color;
  const SettingsAddCategory(this.type, this.name, this.color);
}

class SettingsDeleteCategory extends SettingsEvent {
  final CategoryType type;
  final String name;
  const SettingsDeleteCategory(this.type, this.name);
}

class SettingsUpdateCategory extends SettingsEvent {
  final CategoryType type;
  final String oldName;
  final String? newName;
  final int? color;
  const SettingsUpdateCategory(this.type, this.oldName, this.newName, this.color);
}

sealed class SettingsState {
  final Map<String, int> groceryCategoriesMap;
  final Map<String, int> recipeCategoriesMap;
  final Map<String, int> genericCategoriesMap;
  const SettingsState(this.groceryCategoriesMap, this.recipeCategoriesMap, this.genericCategoriesMap);

  List<Object> get props => [groceryCategoriesMap, recipeCategoriesMap, genericCategoriesMap];
}

class SettingsUpdated extends SettingsState {
  const SettingsUpdated(super.groceryCategoriesMap, super.recipeCategoriesMap, super.genericCategoriesMap);
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final HiveRepository hive;

  SettingsBloc(this.hive)
      : super(SettingsUpdated(hive.groceryCategoriesMap, hive.recipeCategoriesMap, hive.genericCategoriesMap)) {
    on<SettingsAddCategory>((event, emit) {
      hive.addCategory(type: event.type, categoryName: event.name, color: event.color);
      emit(SettingsUpdated(hive.groceryCategoriesMap, hive.recipeCategoriesMap, hive.genericCategoriesMap));
    });
    on<SettingsUpdateCategory>((event, emit) {
      hive.updateCategory(oldName: event.oldName, type: event.type, newName: event.newName, color: event.color);
      emit(SettingsUpdated(hive.groceryCategoriesMap, hive.recipeCategoriesMap, hive.genericCategoriesMap));
    });
    on<SettingsDeleteCategory>((event, emit) {
      hive.deleteCategory(type: event.type, categoryName: event.name);
      emit(SettingsUpdated(hive.groceryCategoriesMap, hive.recipeCategoriesMap, hive.genericCategoriesMap));
    });
  }
}
