import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:reminder_abdulgani/src/core/bloc.dart';
import 'package:reminder_abdulgani/src/core/event.dart';
import 'package:reminder_abdulgani/src/core/state.dart';
import 'package:reminder_abdulgani/src/services/notificationService.dart';
import 'package:reminder_abdulgani/src/services/reminderService.dart';
import 'package:reminder_abdulgani/src/utility/color_hex_ext.dart';

class HomePage extends StatefulWidget {
  final Function(int) onPageChanged;
  const HomePage({super.key, required this.onPageChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Timer _timer;
  late final LocalNotificationService service;

  List<HomeDataModel> dataList = [];

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
    reminderBloc.add(GetAllHomeDataEvent());
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEEE, d MMMM yyyy').format(now);
    Size screenSize = MediaQuery.of(context).size;
    return BlocListener<ReminderBloc, ReminderState>(
      listener: (context, state) {
        if (state is GetAllHomeDataSuccessState) {
          state.value.forEach((element) {
            dataList.add(HomeDataModel(
                id: element['id'],
                name: element['name'],
                description: element['description'],
                time: element['time']));
          });
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                height: 200,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 30.0, right: 30.0, top: 30.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Welcome!"),
                              SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Abdul Gani",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(formattedDate),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: Image.asset(
                                  'assets/images/profile.jpg',
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 320,
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Daily',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                                ),
                                Text(
                                  'reminder',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                                color: HexColor("#f5600a"),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(20.0),
                                    bottomRight: Radius.circular(20.0))),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
          ),
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0),
            child: Text(
              "Your Reminders",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, state) {
              if (state is GetAllHomeDataSuccessState) {
                if (dataList.isEmpty) {
                  return Padding(
                      padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 100,
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Reminder data is empty",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  widget.onPageChanged(1);
                                });
                              },
                              child: Text("Add"),
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
                                    width: 20,
                                  )
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
}
