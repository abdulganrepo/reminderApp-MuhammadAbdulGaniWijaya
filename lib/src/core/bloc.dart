import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder_abdulgani/src/core/event.dart';
import 'package:reminder_abdulgani/src/core/state.dart';
import 'package:reminder_abdulgani/src/services/reminderService.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  ReminderService service;
  ReminderBloc(this.service) : super(ReminderInitial());
  ReminderState get initialState => ReminderInitial();

  Stream<ReminderState> mapEventToState(ReminderEvent event) async* {
    if (event is OpenDatabaseEvent) {
      print("Opening database connection");
      try {
        await service.myDatabase();
        print("Opening database connection success");
      } catch (e) {
        print("Error : ${e.toString()}");
      }
    }

    if (event is GetAllHomeDataEvent) {
      try {
        final data = await service.getAllData();
        yield GetAllHomeDataSuccessState(data);
      } catch (e) {
        print("Error : ${e.toString()}");
      }
    }
    if (event is GetAllManageDataEvent) {
      try {
        final data = await service.getAllData();
        yield GetAllManageDataSuccessState(data);
      } catch (e) {
        print("Error : ${e.toString()}");
      }
    }

    if (event is AddReminderEvent) {
      try {
        await service.insertData(event.name, event.description, event.time);
        yield AddNewReminderSuccessState();
      } catch (e) {
        print("Error : ${e.toString()}");
      }
    }

    if (event is DeleteReminderEvent) {
      try {
        await service.deleteData(
          event.id,
        );
        yield DeleteReminderSuccessState();
      } catch (e) {
        print("Error : ${e.toString()}");
      }
    }
  }
}
