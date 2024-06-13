import 'package:equatable/equatable.dart';

class ReminderState extends Equatable {
  @override
  List<Object> get props => [];
}

class ReminderInitial extends ReminderState {}

class GetAllHomeDataSuccessState extends ReminderInitial {
  final data;

  GetAllHomeDataSuccessState(this.data);
  List<Map<String, dynamic>> get value => data;

  @override
  List<Object> get props => [data];
}

class GetAllManageDataSuccessState extends ReminderInitial {
  final data;

  GetAllManageDataSuccessState(this.data);
  List<Map<String, dynamic>> get value => data;

  @override
  List<Object> get props => [data];
}

class AddNewReminderSuccessState extends ReminderInitial {}

class DeleteReminderSuccessState extends ReminderInitial {}
