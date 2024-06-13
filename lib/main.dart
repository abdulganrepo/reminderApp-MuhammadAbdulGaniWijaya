import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reminder_abdulgani/src/core/bloc.dart';
import 'package:reminder_abdulgani/src/core/event.dart';
import 'package:reminder_abdulgani/src/services/reminderService.dart';
import 'package:reminder_abdulgani/src/utility/color_hex_ext.dart';
import 'package:reminder_abdulgani/src/views/home.dart';
import 'package:reminder_abdulgani/src/views/manage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
      home: BlocProvider(
    create: (context) => ReminderBloc(ReminderService()),
    child: ReminderApp(),
  )));
}

class ReminderApp extends StatefulWidget {
  @override
  _ReminderAppState createState() => _ReminderAppState();
}

class _ReminderAppState extends State<ReminderApp> {
  int _pageIndex = 0;
  int _bottomIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    final reminderBloc = BlocProvider.of<ReminderBloc>(context);
    reminderBloc.add(OpenDatabaseEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _bottomIndex,
        items: <Widget>[
          Icon(Icons.data_saver_off, size: 30, color: HexColor("#f5600a")),
          Icon(Icons.list, size: 30, color: HexColor("#f5600a")),
        ],
        color: Colors.white,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.blueAccent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
            _bottomIndex = index;
          });
        },
      ),
      body: _buildPage(_pageIndex),
    );
  }

  Widget _buildPage(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return BlocProvider(
          create: (context) => ReminderBloc(ReminderService()),
          child: HomePage(
            onPageChanged: (index) {
              setState(() {
                _pageIndex = index;
                _bottomIndex = index;
              });
            },
          ),
        );
      case 1:
        return BlocProvider(
          create: (context) => ReminderBloc(ReminderService()),
          child: ManagePage(),
        );
      default:
        return Container();
    }
  }
}
