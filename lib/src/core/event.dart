import 'package:equatable/equatable.dart';

class ReminderEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class OpenDatabaseEvent extends ReminderEvent {
  @override
  List<Object> get props => [];
}

class GetAllHomeDataEvent extends ReminderEvent {
  @override
  List<Object> get props => [];
}

class GetAllManageDataEvent extends ReminderEvent {
  @override
  List<Object> get props => [];
}

class AddReminderEvent extends ReminderEvent {
  final String name;
  final String description;
  final String time;

  AddReminderEvent(
    this.name,
    this.description,
    this.time,
  );

  @override
  List<Object> get props => [];
}

class DeleteReminderEvent extends ReminderEvent {
  final int id;

  DeleteReminderEvent(this.id);

  @override
  List<Object> get props => [];
}
