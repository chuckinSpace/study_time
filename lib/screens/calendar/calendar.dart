import 'package:flutter/material.dart';
import 'package:test_device/models/event_from_device.dart';
import 'package:test_device/services/database.dart';
import 'package:provider/provider.dart';
import "package:test_device/models/test.dart";
import 'package:table_calendar/table_calendar.dart';
import 'package:test_device/models/user.dart';
import 'package:intl/intl.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> with TickerProviderStateMixin {
  CalendarController _calendarController;
  List<dynamic> _selectedEvents;
  Map<DateTime, List> _events;
  AnimationController _animationController;
  EventFromDevice _eventsFromDevice;
  List<EventFromDevice> deviceEvents;
  DatabaseService database;

  @override
  void initState() {
    super.initState();

    _events = {};
    _calendarController = CalendarController();
    _selectedEvents = [];
    _eventsFromDevice = EventFromDevice();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  didChangeDependencies() async {
    super.didChangeDependencies();
    final user = Provider.of<User>(context);
    database = new DatabaseService(user.uid);
    final tests = await database.getTestsByUser(user.uid);
    deviceEvents = await _eventsFromDevice.retrieveEventsFromDevice(user.uid);
    _eventFromDeviceParse(deviceEvents, tests);
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected $day, $events');
    try {
      setState(() {
        _selectedEvents = events;
      });
    } catch (e) {
      print("error $e");
    }
  }

  void _eventFromDeviceParse(List<EventFromDevice> events, List<Test> tests) {
    try {
      print("on event parse $events");
      List<String> testsIds = [];
      tests.forEach((test) {
        testsIds.add(test.calendarEventId);
      });
      events.forEach((event) async {
        final description = "${event.description}";
        final startTime = new DateFormat("HH:mm").format(event.start);
        final endTime = new DateFormat("HH:mm").format(event.end);

        final time = "$startTime -  $endTime";
        final start = event.start;
        final date =
            new DateTime(start.year, start.month, start.day, 0, 0, 0, 0, 0);
        bool isTest = false;

        if (testsIds.contains(event.calendarEventId)) {
          isTest = true;
        }
        setState(() {
          if (_events[date] != null) {
            _events[date].add({"text": "$description $time", "isTest": isTest});
          } else {
            _events[date] = [
              {"text": "$description $time", "isTest": isTest}
            ];
          }
        });
      });
    } catch (e) {
      print("error $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text("Study Time"),
        backgroundColor: Colors.black38,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.pop(
            context,
            false,
          ),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TableCalendar(
            calendarController: _calendarController,
            events: _events,
            onDaySelected: _onDaySelected,
            builders: CalendarBuilders(
              markersBuilder: (context, date, events, holidays) {
                final children = <Widget>[];
                final notTests =
                    events.where((doc) => doc["isTest"] != true).toList();
                if (notTests.isNotEmpty) {
                  children.add(
                    Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildEventsMarker(date, notTests),
                    ),
                  );
                }

                final tests =
                    events.where((doc) => doc["isTest"] == true).toList();

                if (tests.isNotEmpty) {
                  children.add(
                    Positioned(
                      left: 1,
                      bottom: 1,
                      child: _buildTestMarker(date, tests),
                    ),
                  );
                }

                return children;
              },
            ),
          ),
          Expanded(
            child: new ListView.builder(
                itemCount: _selectedEvents.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  print(" selected event, $_selectedEvents");
                  return new ListTile(
                    title: Text(
                      _selectedEvents[index]["text"],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildTestMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.red[500]
            : _calendarController.isToday(date)
                ? Colors.red[300]
                : Colors.red[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
