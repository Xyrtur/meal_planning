import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meal_planning/utils/hive_repository.dart';

abstract class ImportExportEvent extends Equatable {
  const ImportExportEvent(this.isAndroid);
  final bool isAndroid;
  @override
  List<Object?> get props => [isAndroid];
}

class ImportClicked extends ImportExportEvent {
  const ImportClicked(super.isAndroid);
}

class ExportClicked extends ImportExportEvent {
  const ExportClicked(super.isAndroid);
}

abstract class ImportExportState {
  const ImportExportState();

  List<Object> get props => [];
}

class ImportFinished extends ImportExportState {
  const ImportFinished();
}

class ExportFinished extends ImportExportState {
  const ExportFinished();
}

class ImportExportInitial extends ImportExportState {
  const ImportExportInitial();
}

/*
 * Asks the repository to import/export the data in the app 
 */
class ImportExportBloc extends Bloc<ImportExportEvent, ImportExportState> {
  final HiveRepository hive;

  ImportExportBloc(this.hive) : super(const ImportExportInitial()) {
    on<ImportClicked>((event, emit) async {
      bool importSuccess = await hive.importFile(event.isAndroid);
      if (importSuccess) {
        hive.cacheInitialData();
        emit(const ImportExportInitial());
        emit(const ImportFinished());
      }
    });

    on<ExportClicked>((event, emit) async {
      await hive.exportFile(event.isAndroid);
      hive.cacheInitialData();
      emit(const ImportExportInitial());
      emit(const ExportFinished());
    });
  }
}
