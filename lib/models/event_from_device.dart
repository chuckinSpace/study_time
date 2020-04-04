import 'dart:collection';
import 'package:test_device/services/database.dart';
import 'package:test_device/shared/Error.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/services.dart';

/// An event associated with a calendar
class EventFromDevice {
  /// The unique identifier for this event
  String eventId;

  /// The identifier of the calendar that this event is associated with
  String calendarEventId;

  /// The title of this event
  String title;

  /// The description for this event
  String description;

  /// Indicates when the event starts
  DateTime start;

  /// Indicates when the event ends
  DateTime end;

  /// Indicates if this is an all-day event
  bool allDay;

  // day of the event
  DateTime day;
  String calendarId;
  int daysToTest;
  int fromWhen;
  // event obj coming from device

  EventFromDevice(
      {this.fromWhen = -30,
      this.daysToTest = 90,
      this.calendarEventId,
      this.title,
      this.day,
      this.start,
      this.end,
      this.description,
      this.allDay = false,
      this.calendarId});

  @override
  String toString() {
    return "Title: $title - Id: $eventId - Start : $start - End $end - Description: $description";
  }

//create function takes the event date and separates between day of event, start time and end time
//_event shoulb be [eventDay:[{"eventId":eventId,"description":eventDesciption,"startTime":timeStart,"endTime":timeEnd}]]
  Future<List<Map>> retrieveCalendars() async {
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

    try {
      List<Map> calendars = [];
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && !permissionsGranted.data) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || !permissionsGranted.data) {
          return calendars;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

      if (calendarsResult.isSuccess && calendarsResult.data.isNotEmpty) {
        calendarsResult.data.forEach((doc) {
          if (doc.id != null) {
            calendars.add({"id": doc.id, "name": doc.name, "inUse": false});
          }
        });
        return calendars;
      } else {
        calendars = [];
        return calendars;
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<EventFromDevice>> retrieveEventsFromDevice(String uid) async {
//retriving event from device in the range of from when and daysTitest those default to -30 and 90 a month before and 3 months after today

    try {
      /*  final calendars = await retrieveCalendars(); */
      final userSettings = await DatabaseService(uid).getUserSettings();
      String calendarToUse = userSettings["calendarToUse"];
      List<EventFromDevice> events = [];
      if (calendarToUse.isNotEmpty) {
        DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
        final start = DateTime.now().add(new Duration(days: fromWhen));
        final end = new DateTime.now().add(new Duration(days: daysToTest));
        final retrieveEventsParams =
            new RetrieveEventsParams(startDate: start, endDate: end);

        /*     await Future.forEach(calendars, (calendar) async { */
        Result<UnmodifiableListView<Event>> response =
            await _deviceCalendarPlugin.retrieveEvents(
                calendarToUse, retrieveEventsParams);
        if (response.isSuccess && response.data.isNotEmpty) {
          response.data.forEach((event) {
            events.add(EventFromDevice(
                start: event.start,
                end: event.end,
                description: event.title,
                calendarEventId: event.eventId,
                calendarId: event.calendarId,
                allDay: event.allDay));
          });
        }
        /*     }); */
        return events;
      } else {
        print("no calendar info found");
        return events;
      }
    } on PlatformException catch (e) {
      print(e);
      return null;
    }
  }

  void deleteCalendarEvent(String calendarId, String eventId) async {
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();
    final deleteResult =
        await _deviceCalendarPlugin.deleteEvent(calendarId, eventId);
    if (deleteResult.isSuccess && deleteResult.data) {
      print("delete from calendar success $eventId");
    }
  }

  Future<String> createDeviceEvent(
      String calendarId, Map<dynamic, dynamic> event) async {
    print("creting device event $event");
    DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

    final eventToCreate = new Event(calendarId);

    try {
      String text = "";
      final test = await Firestore.instance
          .collection("tests")
          .document(event["testId"])
          .get();
      if (event["sessionNumber"] != null) {
        text =
            "Study session nº ${event["sessionNumber"]} for ${test["subject"]} ";
      } else {
        text = "${event["description"]} ${event["subject"]}";
      }

      if (test.exists) {
        eventToCreate.title = "$text";
        eventToCreate.end = event["end"];
        eventToCreate.start = event["start"];
        final eventId =
            await _deviceCalendarPlugin.createOrUpdateEvent(eventToCreate);

        return eventId.data;
      } else {
        throw new Error("error when creating device event");
      }
    } catch (e) {
      throw new Error("error when creating device event $e");
    }
  }
}
