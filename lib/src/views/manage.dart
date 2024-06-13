import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder_abdulgani/src/core/bloc.dart';
import 'package:reminder_abdulgani/src/core/event.dart';
import 'package:reminder_abdulgani/src/core/state.dart';
import 'package:reminder_abdulgani/src/services/notificationService.dart';
import 'package:reminder_abdulgani/src/services/reminderService.dart';
import 'package:reminder_abdulgani/src/utility/color_hex_ext.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  late Timer _timer;
  late final LocalNotificationService service;

  final _formKey = GlobalKey<FormState>();

  List<ManageDataModel> dataList = [];

  void _startTimer() {
    const duration = Duration(seconds: 1);
    _timer = Timer.periodic(duration, (timer) {
      _checkTime();
    });
  }

  Future<void> _checkTime() async {
    DateTime now = DateTime.now();
    String currentHour = now.hour < 10 ? '0${now.hour}' : '${now.hour}';
    String currentMinute = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
    String currentSecond = now.second < 10 ? '0${now.second}' : '${now.second}';
    String currentTime = "$currentHour:$currentMinute:$currentSecond";
    print("Current Time: $currentTime");
    dataList.forEach((element) {
      var reminderTime = "${element.time}:00";
      if (reminderTime == currentTime) {
        service.showNotification(
            id: 0, title: element.name, body: element.description);

        setState(() {
          deleteReminder(element.id);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  var reminderNameCtrl = TextEditingController();
  var descriptionCtrl = TextEditingController();
  var timeSelectedCtrl = TextEditingController();

  TimeOfDay timeOfDay = TimeOfDay.now();
  Future<Null> _selectedTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      builder: (BuildContext? context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context!).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      initialTime: timeOfDay,
    );

    if (picked != null) {
      setState(() {
        timeOfDay = picked;
        timeSelectedCtrl.value =
            TextEditingValue(text: timeOfDay.format(context));
      });
    }
  }

  void addNewReminder(String name, String description, String time) {
    Navigator.pop(context);
    final reminderBloc = BlocProvider.of<ReminderBloc>(context);
    reminderBloc.add(AddReminderEvent(name, description, time));
  }

  void deleteReminder(int id) {
    final reminderBloc = BlocProvider.of<ReminderBloc>(context);
    reminderBloc.add(DeleteReminderEvent(id));
  }

  @override
  void initState() {
    service = LocalNotificationService();
    service.initialize();
    dataList.clear();
    _startTimer();
    final reminderBloc = BlocProvider.of<ReminderBloc>(context);
    reminderBloc.add(GetAllManageDataEvent());
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    Size screenSize = MediaQuery.of(context).size;
    return BlocListener<ReminderBloc, ReminderState>(
      listener: (context, state) {
        if (state is GetAllManageDataSuccessState) {
          state.value.forEach((element) {
            dataList.add(ManageDataModel(
                id: element['id'],
                name: element['name'],
                description: element['description'],
                time: element['time']));
          });
        }
        if (state is AddNewReminderSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Add New Reminder Success!'),
              action: SnackBarAction(
                label: 'Close',
                onPressed: () {},
              ),
            ),
          );
          dataList.clear();
          reminderNameCtrl.clear();
          descriptionCtrl.clear();
          timeSelectedCtrl.clear();
          final reminderBloc = BlocProvider.of<ReminderBloc>(context);
          reminderBloc.add(GetAllManageDataEvent());
        }

        if (state is DeleteReminderSuccessState) {
          dataList.clear();
          final reminderBloc = BlocProvider.of<ReminderBloc>(context);
          reminderBloc.add(GetAllManageDataEvent());
        }
      },
      child: Container(
        width: screenSize.width,
        height: screenSize.height,
        color: Colors.blueAccent,
        child: Column(children: [
          SizedBox(
            height: 50,
          ),
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))),
            child: Container(
              width: screenSize.width,
              height: 100,
              child: Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Reminders Manager",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.all(8),
                      width: 350,
                      height: 35,
                      child: Text(
                        textAlign: TextAlign.center,
                        "Manage your daily reminder here ..",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic),
                      ),
                      decoration: BoxDecoration(
                          color: HexColor("#f5600a"),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0))),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Reminders",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Stack(
                                clipBehavior: Clip.none,
                                children: <Widget>[
                                  Positioned(
                                    right: -40,
                                    top: -40,
                                    child: InkResponse(
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: HexColor("#f5600a"),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                hintText: "Reminder name"),
                                            controller: reminderNameCtrl,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: TextFormField(
                                            decoration: InputDecoration(
                                                hintText: "Description"),
                                            controller: descriptionCtrl,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: GestureDetector(
                                            onTap: () {
                                              _selectedTime(context);
                                            },
                                            child: TextFormField(
                                                decoration: InputDecoration(
                                                    hintText:
                                                        "Click to select time"),
                                                enabled: false,
                                                controller: timeSelectedCtrl),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: ElevatedButton(
                                            child: const Text('Add'),
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith((states) {
                                                if (states.contains(
                                                    MaterialState.pressed)) {
                                                  return Colors.green;
                                                }
                                                return HexColor("#f5600a");
                                              }),
                                            ),
                                            onPressed: () {
                                              reminderNameCtrl.text.isEmpty ||
                                                      descriptionCtrl
                                                          .text.isEmpty ||
                                                      timeSelectedCtrl
                                                          .text.isEmpty
                                                  ? showAlertDialog(context)
                                                  : addNewReminder(
                                                      reminderNameCtrl.text,
                                                      descriptionCtrl.text,
                                                      timeSelectedCtrl.text);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ));
                  },
                  child: Icon(Icons.add_alarm),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.green;
                      }
                      return HexColor("#f5600a");
                    }),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, state) {
              if (state is GetAllManageDataSuccessState) {
                if (dataList.isEmpty) {
                  return const Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 200,
                            ),
                            Text(
                              "Reminder data is empty",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ));
                } else {
                  return Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(right: 30.0, left: 30.0),
                      itemCount: dataList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var data = dataList[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 10),
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_filled,
                                    color: HexColor("#f5600a"),
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    data.name,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(data.time),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      child:
                                          Icon(Icons.delete, color: Colors.red),
                                    ),
                                    onTap: () {
                                      showDeleteDialog(
                                        context,
                                        data.id,
                                        data.name,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }
              }
              return SizedBox();
            },
          )
        ]),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Alert"),
      content: Text("Data can not be empty"),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDeleteDialog(BuildContext context, int id, String name) {
    AlertDialog alert = AlertDialog(
      title: Text(name),
      content: Text("Are you sure want to delete?"),
      actions: [
        TextButton(
          child: Text("Yes"),
          onPressed: () {
            deleteReminder(id);
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("No"),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
