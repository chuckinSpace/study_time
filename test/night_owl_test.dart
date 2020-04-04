import 'package:test_device/models/event_from_device.dart';
import 'package:test_device/models/session.dart';
import 'package:flutter_test/flutter_test.dart';
import "package:test_device/helpers/TimeAllocation.dart";

final time = TimeAllocation("asd", [], 2);
final today = new DateTime.now();
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    time.finalSessions = [];
    time.testing = true;
    time.idealStudyLenght = 1;
  });

  group("isLessThanTwoDaysFrom", () {
    test('return true if is less than two days apart', () {
      final date1 = new DateTime(20, 3, 17, 0, 0, 0, 0);
      final date2 = new DateTime(20, 3, 18, 0, 0, 0, 0);
      final response = time.isLessThanTwoDaysApart(date1, date2);
      expect(response, true);
    });
    test('return true if is less than two days apart (same day)', () {
      final date1 = new DateTime(20, 3, 17, 0, 0, 0, 0);
      final date2 = new DateTime(20, 3, 17, 0, 0, 0, 0);
      final response = time.isLessThanTwoDaysApart(date1, date2);
      expect(response, true);
    });
    test('return false if is less than two days apart ', () {
      final date1 = new DateTime(20, 3, 17, 0, 0, 0, 0);
      final date2 = new DateTime(20, 3, 19, 0, 0, 0, 0);
      final response = time.isLessThanTwoDaysApart(date1, date2);
      expect(response, false);
    });
  });
  group("isSameDay", () {
    test('return true when same day', () {
      final date1 = new DateTime(20, 3, 5, 19, 0, 0, 0, 0);
      final date2 = new DateTime(20, 3, 5, 20, 0, 0, 0, 0);
      final response = time.isSameDay(date1, date2);
      expect(response, true);
    });

    test('return false when diff day', () {
      final date1 = new DateTime(20, 3, 7, 19, 0, 0, 0, 0);
      final date2 = new DateTime(20, 3, 6, 19, 0, 0, 0, 0);
      final response = time.isSameDay(date1, date2);
      expect(response, false);
    });
  });
  group("is Available", () {
    test('No collision, add normally', () {
      DateTime time1 = new DateTime(20, 3, 20, 17, 0, 0, 0, 0);
      DateTime timeEnd1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);

      var sessionToTry = {"start": time1, "end": timeEnd1};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 22, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 23, 0, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, true);
    });
    test('Return false when event in device is multiple days', () {
      DateTime time1 = new DateTime(20, 3, 23, 19, 0, 0, 0, 0);
      DateTime timeEnd1 = new DateTime(20, 3, 23, 20, 0, 0, 0, 0);

      var sessionToTry = {"start": time1, "end": timeEnd1};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 22, 7, 0, 0, 0, 0),
          end: new DateTime(20, 3, 23, 23, 0, 0, 0, 0));

      eventsFromDevice.add(event1);

      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, false);
    });
    test('event - session - event/session', () {
      DateTime time1 = new DateTime(20, 3, 20, 17, 0, 0, 0, 0);
      DateTime timeEnd1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);

      var sessionToTry = {"start": time1, "end": timeEnd1};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 18, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 19, 0, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, false);
    });
    test('event/session - event/session', () {
      DateTime time1 = new DateTime(20, 3, 20, 17, 0, 0, 0, 0);
      DateTime timeEnd1 = new DateTime(20, 3, 20, 18, 0, 0, 0, 0);
      var sessionToTry = {"start": time1, "end": timeEnd1};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 17, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 18, 0, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, false);
    });
    test('event-session-event-session', () {
      DateTime time1 = new DateTime(20, 3, 20, 17, 0, 0, 0, 0);
      DateTime timeEnd1 = new DateTime(20, 3, 20, 18, 0, 0, 0, 0);
      var sessionToTry = {"start": time1, "end": timeEnd1};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 17, 30, 0, 0, 0),
          end: new DateTime(20, 3, 20, 18, 30, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, false);
    });
    test('session- event -session - event', () {
      DateTime time1 = new DateTime(20, 3, 20, 17, 0, 0, 0, 0);
      DateTime timeEnd1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      var sessionToTry = {"start": time1, "end": timeEnd1};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 16, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 18, 0, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, false);
    });
    test('session/event -event-session', () {
      DateTime time1 = new DateTime(20, 3, 20, 18, 0, 0, 0, 0);
      DateTime timeEnd1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      var sessionToTry = {"start": time1, "end": timeEnd1};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 18, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 18, 30, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, false);
    });
    test('session-event event/session', () {
      DateTime time1 = new DateTime(20, 3, 20, 18, 30, 0, 0, 0);
      DateTime timeEnd1 = new DateTime(20, 3, 20, 19, 30, 0, 0, 0);
      var sessionToTry = {"start": time1, "end": timeEnd1};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 19, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 19, 30, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, false);
    });
    test('session-event event/session 30 min', () {
      time.idealStudyLenght = 30;

      var sessionToTry = {
        "start": new DateTime(20, 3, 20, 18, 30, 0, 0, 0),
        "end": new DateTime(20, 3, 20, 19, 0, 0, 0, 0)
      };
      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 3, 20, 18, 45, 0, 0, 0),
            end: new DateTime(20, 3, 20, 19, 0, 0, 0, 0)),
        EventFromDevice(
            start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
            end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0))
      ];

      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, false);
    });
    test('session-event-session-event', () {
      DateTime time1 = new DateTime(20, 3, 20, 20, 0, 0, 0, 0);
      DateTime timeEnd1 = new DateTime(20, 3, 20, 21, 0, 0, 0, 0);
      var sessionToTry = {"start": time1, "end": timeEnd1};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 20, 30, 0, 0, 0),
          end: new DateTime(20, 3, 20, 21, 30, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, false);
    });
    test('session-event-session-event 30min', () {
      time.idealStudyLenght = 30;

      var sessionToTry = {
        "start": new DateTime(20, 3, 20, 20, 30, 0, 0, 0),
        "end": new DateTime(20, 3, 20, 21, 0, 0, 0, 0)
      };
      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 3, 20, 20, 30, 0, 0, 0),
            end: new DateTime(20, 3, 20, 21, 30, 0, 0, 0)),
        EventFromDevice(
            start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
            end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0))
      ];

      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, false);
    });
    test('session-event-session-event 30min allocate', () {
      time.idealStudyLenght = 30;

      var sessionToTry = {
        "start": new DateTime(20, 3, 20, 20, 30, 0, 0, 0),
        "end": new DateTime(20, 3, 20, 21, 0, 0, 0, 0)
      };
      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 3, 20, 11, 0, 0, 0, 0),
            end: new DateTime(20, 3, 20, 12, 0, 0, 0, 0))
      ];

      final response =
          time.isAvailableFromDevice(sessionToTry, eventsFromDevice);
      expect(response, true);
    });
  });
  group("Add if Night Owl", () {
    test(
        'should not allocate a session that is more than one day apart form first session on finalSession',
        () {
      final finalSessions = [
        Session(
            start: new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 16, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 17, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 17, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 20, 0, 0, 0, 0)),
      ];
      time.finalSessions = finalSessions;
      List<EventFromDevice> eventsFromDevice = [];
      final session = {
        "start": new DateTime(20, 3, 14, 21, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 14, 22, 0, 0, 0, 0)
      };

      final response = time.addIfNightOwl(eventsFromDevice, session);
      expect(time.finalSessions.length, 3);
      expect(response, equals(session));
    });

    test("No device events, events after nightTime should fail", () async {
      time.sweetSpotStart = 18;
      time.sweetSpotEnd = 21;
      time.night = 23;
      time.morning = 8;

      DateTime time3 = new DateTime(20, 3, 20, 23, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 21, 0, 0, 0, 0, 0);
      // events from device
      var sessionToTry = {"start": time3, "end": time3end};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 21, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 22, 30, 0, 0, 0));
      eventsFromDevice.add(event1);

      //call sending 23-0 => falls outside sweet spot => fail => return the date on sweetSpot

      var nightOwl = time.addIfNightOwl(eventsFromDevice, sessionToTry);
      expect(
          nightOwl["start"], equals(new DateTime(20, 3, 20, 18, 0, 0, 0, 0)));
      expect(nightOwl["end"], equals(new DateTime(20, 3, 20, 19, 0, 0, 0, 0)));
      expect(time.finalSessions, []);
    });

    test('No device events,events after 22 and before nightTime should pass',
        () {
      //rejected
      DateTime time3 = new DateTime(20, 3, 20, 22, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 20, 23, 0, 0, 0, 0);
      List<EventFromDevice> eventsFromDevice = [];
      var sessionToTry = {"start": time3, "end": time3end};

      // set sweet spots
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.morning = 8;
      //call sending 22-23 => allocate between swetSpot and night => pass

      final nightOwl = time.addIfNightOwl(eventsFromDevice, sessionToTry);
      expect(nightOwl, null);
      expect(time.finalSessions[0].start, equals(time3));
      expect(time.finalSessions[0].end, equals(time3end));
    });
    test('Device events, events after 22 and before nightTime should pass', () {
      //rejected

      DateTime time3 = new DateTime(20, 3, 20, 21, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 20, 22, 0, 0, 0, 0);
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 21, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 22, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      var sessionToTry = {"start": time3, "end": time3end};
      // rejected sessions

      // set sweet spots
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 22;
      time.morning = 8;
      //call sending 21-22 => device event bloking => next fails outside night

      final nightOwl = time.addIfNightOwl(eventsFromDevice, sessionToTry);
      expect(
          nightOwl,
          equals({
            "start": new DateTime(20, 3, 20, 19, 0, 0, 0, 0),
            "end": new DateTime(20, 3, 20, 20, 0, 0, 0, 0)
          }));
      expect(time.finalSessions, equals([]));
    });
    test('add normally when studylenght is 30min', () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.morning = 8;
      time.idealStudyLenght = 30;

      DateTime time3 = new DateTime(20, 3, 20, 21, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 20, 21, 30, 0, 0, 0);
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 21, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 22, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      var sessionToTry = {"start": time3, "end": time3end};

      final nightOwl = time.addIfNightOwl(eventsFromDevice, sessionToTry);
      expect(nightOwl, null);
      expect(time.finalSessions[0].start,
          equals(new DateTime(20, 3, 20, 22, 0, 0, 0, 0)));
      expect(time.finalSessions[0].end,
          equals(new DateTime(20, 3, 20, 22, 30, 0, 0, 0)));
    });
  });
  group("Time Allocation", () {
    test('Returns null on null dueDate', () {
      expect(time.daysUntil(null), null);
    });
    test('Returns number of days correctly', () {
      var dueDate = new DateTime.now().add(new Duration(days: 5));
      var daysUntilTest = time.daysUntil(dueDate);
      expect(daysUntilTest, 5);
    });
    test('Add 1hr to session', () {
      var todayStart = new DateTime.now();
      var todayEnd = new DateTime.now().add(new Duration(hours: 1));
      var session = {"start": todayStart, "end": todayEnd};

      var sessionPlusHour = time.addHrToSession(session, 1);
      expect(sessionPlusHour["start"].hour,
          todayStart.add(new Duration(hours: 1)).hour);
      expect(sessionPlusHour["end"].hour,
          todayEnd.add(new Duration(hours: 1)).hour);

      sessionPlusHour = time.addHrToSession(null, 1);
      expect(sessionPlusHour, null);
    });
  });

  group("Add if SweetSpot", () {
    test(
        'should not allocate a session that is more than one day apart form first session on finalSession',
        () {
      time.sweetSpotStart = 18;
      time.sweetSpotEnd = 21;
      time.night = 23;
      time.morning = 7;

      final finalSessions = [
        Session(
            start: new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 16, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 17, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 17, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 20, 0, 0, 0, 0)),
      ];
      time.finalSessions = finalSessions;
      List<EventFromDevice> eventsFromDevice = [];
      final session = {
        "start": new DateTime(20, 3, 14, 17, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 14, 18, 0, 0, 0, 0)
      };

      final response = time.addIfSweetSpot(eventsFromDevice, session);
      expect(time.finalSessions.length, 3);
      expect(response, equals(session));
    });

    test('adds normally', () {
      DateTime time1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 20, 20, 0, 0, 0, 0);
      // events from device
      var sessionToTry = {"start": time1, "end": time1end};
      List<EventFromDevice> eventsFromDevice = [];
      // set sweet spots
      time.sweetSpotStart = 18;
      time.sweetSpotEnd = 21;
      time.night = 23;
      time.morning = 8;

      //call sending 19-20 => add normally

      var tryIfSweetSpot = time.addIfSweetSpot(eventsFromDevice, sessionToTry);
      expect(tryIfSweetSpot, null);
      expect(time.finalSessions[0].start, equals(time1));
      expect(time.finalSessions[0].end, equals(time1end));
    });

    test('fails when tried outside sweet spot', () {
      DateTime time3 = new DateTime(20, 3, 20, 22, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 20, 23, 0, 0, 0, 0);
      List<EventFromDevice> eventsFromDevice = [];
      var sessionToTry = {"start": time3, "end": time3end};

      // set sweet spots
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.morning = 8;
      //call sending 22-23 => falls outsite sweet spot => fail => return last date

      final sweetSpot = time.addIfSweetSpot(eventsFromDevice, sessionToTry);
      expect(
          sweetSpot,
          equals({
            "start": new DateTime(20, 3, 20, 19, 0, 0, 0, 0),
            "end": new DateTime(20, 3, 20, 20, 0, 0, 0, 0)
          }));
      expect(time.finalSessions, []);
    });
    test('passes when spot is ocupied device event and tries the next', () {
      DateTime time3 = new DateTime(20, 3, 20, 20, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 20, 21, 0, 0, 0, 0);
      List<EventFromDevice> eventsFromDevice = [];
      var sessionToTry = {"start": time3, "end": time3end};
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 20, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 21, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      // set sweet spots
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.morning = 8;
      //call sending 20-21 => spot taken move to next and passes => return null

      final sweetSpot = time.addIfSweetSpot(eventsFromDevice, sessionToTry);
      expect(sweetSpot, null);
      expect(time.finalSessions[0].start,
          equals(time3.add(new Duration(hours: 1))));
      expect(time.finalSessions[0].end,
          equals(time3end.add(new Duration(hours: 1))));
    });
    test(
        'fails when spot is ocupied device event and tries the next outside sweet spot',
        () {
      DateTime time3 = new DateTime(20, 3, 20, 21, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 20, 22, 0, 0, 0, 0);
      List<EventFromDevice> eventsFromDevice = [];
      var sessionToTry = {"start": time3, "end": time3end};
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 21, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 22, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      // set sweet spots
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.morning = 8;

      //call sending 21-22 => spot taken move to next and passes => return null
      final sweetSpot = time.addIfSweetSpot(eventsFromDevice, sessionToTry);
      expect(
          sweetSpot,
          equals({
            "start": new DateTime(20, 3, 20, 19, 0, 0, 0, 0),
            "end": new DateTime(20, 3, 20, 20, 0, 0, 0, 0)
          }));
      expect(time.finalSessions, []);
    });
    test(
        'should not allocate a session that is more than one day apart form first session on finalSession',
        () {
      final finalSessions = [
        Session(
            start: new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 16, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 17, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 17, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 20, 0, 0, 0, 0)),
      ];
      time.finalSessions = finalSessions;
      List<EventFromDevice> eventsFromDevice = [];
      final session = {
        "start": new DateTime(20, 3, 14, 21, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 14, 22, 0, 0, 0, 0)
      };

      final response = time.addIfSweetSpot(eventsFromDevice, session);
      expect(time.finalSessions.length, 3);
      expect(response, equals(session));
    });
    test('Should accomodate 30 min slots when idealStudy lenght is 30', () {
      time.dueDate = new DateTime(20, 4, 2, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 17, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.morning = 8;
      time.night = 23;
      time.idealStudyLenght = 30;
      time.nightOwl = false;

      final session = {
        "start": new DateTime(20, 4, 1, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 1, 19, 30, 0, 0, 0)
      };

      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 4, 1, 17, 0, 0, 0, 0),
            end: new DateTime(20, 4, 1, 19, 0, 0, 0, 0))
      ];

      final response = time.addIfSweetSpot(eventsFromDevice, session);
      expect(response, null);
      expect(
          time.finalSessions[0].start, new DateTime(20, 4, 1, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[0].end, new DateTime(20, 4, 1, 19, 30, 0, 0, 0));
    });
  });
  ///////////////////
  group("Add if early bird", () {
    test('adds normally', () {
      DateTime time1 = new DateTime(20, 3, 20, 5, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 20, 7, 0, 0, 0, 0);
      // events from device
      var sessionToTry = {"start": time1, "end": time1end};
      List<EventFromDevice> eventsFromDevice = [];
      // set sweet spots
      time.sweetSpotStart = 18;
      time.sweetSpotEnd = 21;
      time.night = 23;
      time.morning = 8;
      time.idealStudyLenght = 1;
      //call sending 5 - 7 sets to  sweetSpotStart - 1 => 17-18 => should pass

      var earlyBird = time.addIfEarlyBird(eventsFromDevice, sessionToTry);
      expect(earlyBird, null);
      expect(
          time.finalSessions[0].start,
          equals(new DateTime(20, 3, 20,
              (time.sweetSpotStart - time.idealStudyLenght.toInt()), 0, 0, 0)));
      expect(time.finalSessions[0].end,
          equals(new DateTime(20, 3, 20, (time.sweetSpotStart), 0, 0, 0)));
    });
    test('fails when falling outside morning range', () {
      DateTime time1 = new DateTime(20, 3, 20, 11, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 20, 12, 0, 0, 0, 0);
      // events from device
      var sessionToTry = {"start": time1, "end": time1end};
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 20, 9, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 10, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 20, 8, 0, 0, 0, 0),
          end: new DateTime(20, 3, 20, 9, 0, 0, 0, 0));
      eventsFromDevice.add(event2);

      // set sweet spots
      time.sweetSpotStart = 10;
      time.sweetSpotEnd = 21;
      time.night = 23;
      time.morning = 8;
      time.idealStudyLenght = 1;
      //call sending 10 - 11 sets to sweetSpotStart - 1  => busy slots until fall out of morning => should fail

      var earlyBird = time.addIfEarlyBird(eventsFromDevice, sessionToTry);
      expect(
          earlyBird,
          equals({
            "start": new DateTime(20, 3, 20, 10, 0, 0, 0, 0),
            "end": new DateTime(20, 3, 20, 11, 0, 0, 0, 0)
          }));
      expect(time.finalSessions, equals([]));
    });
    test('Should accomodate 30 min slots when idealStudy lenght is 30', () {
      time.dueDate = new DateTime(20, 4, 2, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 17, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.morning = 8;
      time.night = 23;
      time.idealStudyLenght = 30;
      time.nightOwl = false;

      final session = {
        "start": new DateTime(20, 4, 1, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 1, 20, 0, 0, 0, 0)
      };

      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 4, 1, 19, 0, 0, 0, 0),
            end: new DateTime(20, 4, 1, 23, 0, 0, 0, 0))
      ];

      final response = time.addIfEarlyBird(eventsFromDevice, session);
      expect(response, null);
      expect(
          time.finalSessions[0].start, new DateTime(20, 4, 1, 18, 30, 0, 0, 0));
      expect(time.finalSessions[0].end, new DateTime(20, 4, 1, 19, 0, 0, 0, 0));
    });
  });
  group("Accomodate Sessions", () {
    test('On busy slot add on sweet spot', () {
      DateTime time1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 20, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 21, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 21, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 22, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 22, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 23, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 23, 20, 0, 0, 0, 0);
      // events from device

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);

      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 22, 19, 0, 0, 0, 0),
          end: new DateTime(20, 3, 22, 20, 0, 0, 0, 0));

      eventsFromDevice.add(event1);

      time.dueDate = new DateTime(20, 3, 24, 19, 0, 0, 0, 0);

      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.morning = 8;
      time.idealStudyLenght = 1;
      time.nightOwl = true;

      time.accomodateSessions(sessions, eventsFromDevice);
      expect(time.finalSessions.length, 4);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start, equals(time1));
      expect(time.finalSessions[0].end, equals(time1end));
      expect(time.finalSessions[1].start, equals(time2));
      expect(time.finalSessions[1].end, equals(time2end));
      expect(time.finalSessions[2].start,
          equals(time3.add(new Duration(hours: 1))));
      expect(time.finalSessions[2].end,
          equals(time3end.add(new Duration(hours: 1))));
      expect(time.finalSessions[3].start, equals(time4));
      expect(time.finalSessions[3].end, equals(time4end));
    });
    test('Accomodate normally when multiple day event on device', () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.morning = 8;
      time.idealStudyLenght = 1;
      time.nightOwl = true;
      time.dueDate = new DateTime(20, 3, 24, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 18, 19, 0, 0, 0, 0);

      DateTime time1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 20, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 21, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 21, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 22, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 22, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 23, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 23, 20, 0, 0, 0, 0);
      // events from device

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);

      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 22, 7, 0, 0, 0, 0),
          end: new DateTime(20, 3, 23, 23, 0, 0, 0, 0));

      eventsFromDevice.add(event1);

      time.accomodateSessions(sessions, eventsFromDevice);
      expect(time.finalSessions.length, 4);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start,
          equals(new DateTime(20, 3, 18, 19, 0, 0, 0, 0)));
      expect(time.finalSessions[0].end,
          equals(new DateTime(20, 3, 18, 20, 0, 0, 0, 0)));
      expect(time.finalSessions[1].start,
          equals(new DateTime(20, 3, 19, 19, 0, 0, 0, 0)));
      expect(time.finalSessions[1].end,
          equals(new DateTime(20, 3, 19, 20, 0, 0, 0, 0)));
      expect(time.finalSessions[2].start, equals(time1));
      expect(time.finalSessions[2].end, equals(time1end));
      expect(time.finalSessions[3].start, equals(time2));
      expect(time.finalSessions[3].end, equals(time2end));
    });
    test('On busy slots outside sweet spot, tries night owl first', () {
      DateTime time1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 20, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 21, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 21, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 22, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 22, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 23, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 23, 20, 0, 0, 0, 0);
      // events from device

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);

      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 22, 18, 0, 0, 0, 0),
          end: new DateTime(20, 3, 22, 22, 0, 0, 0, 0));

      eventsFromDevice.add(event1);

      time.dueDate = new DateTime(20, 3, 24, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.night = 22;
      time.morning = 8;
      time.idealStudyLenght = 1;

      time.nightOwl = true;

      time.accomodateSessions(sessions, eventsFromDevice);
      expect(time.finalSessions.length, 4);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start, equals(time1));
      expect(time.finalSessions[0].end, equals(time1end));
      expect(time.finalSessions[1].start, equals(time2));
      expect(time.finalSessions[1].end, equals(time2end));
      expect(time.finalSessions[2].start,
          equals(new DateTime(20, 3, 22, 17, 0, 0, 0, 0)));
      expect(time.finalSessions[2].end,
          equals(new DateTime(20, 3, 22, 18, 0, 0, 0, 0)));
      expect(time.finalSessions[3].start, equals(time4));
      expect(time.finalSessions[3].end, equals(time4end));
    });
    test('On busy slots outside sweet spot, tries night owl first, early after',
        () {
      DateTime time1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 20, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 21, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 21, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 22, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 22, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 23, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 23, 20, 0, 0, 0, 0);
      // events from device

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);

      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 22, 19, 0, 0, 0, 0),
          end: new DateTime(20, 3, 22, 20, 0, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 22, 20, 0, 0, 0, 0),
          end: new DateTime(20, 3, 22, 21, 0, 0, 0, 0));

      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);

      time.dueDate = new DateTime(20, 3, 24, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.night = 21;
      time.morning = 8;
      time.idealStudyLenght = 1;

      time.nightOwl = true;

      time.accomodateSessions(sessions, eventsFromDevice);
      expect(time.finalSessions.length, 4);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start, equals(time1));
      expect(time.finalSessions[0].end, equals(time1end));
      expect(time.finalSessions[1].start, equals(time2));
      expect(time.finalSessions[1].end, equals(time2end));
      expect(time.finalSessions[2].start,
          equals(new DateTime(20, 3, 22, 18, 0, 0, 0, 0)));
      expect(time.finalSessions[2].end,
          equals(new DateTime(20, 3, 22, 19, 0, 0, 0, 0)));
      expect(time.finalSessions[3].start, equals(time4));
      expect(time.finalSessions[3].end, equals(time4end));
    });
    test('On busy slots outside sweet spot, if early bird, tries that first',
        () {
      DateTime time1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 20, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 21, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 21, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 22, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 22, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 23, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 23, 20, 0, 0, 0, 0);
      // events from device

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);

      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 22, 19, 0, 0, 0, 0),
          end: new DateTime(20, 3, 22, 20, 0, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 22, 20, 0, 0, 0, 0),
          end: new DateTime(20, 3, 22, 21, 0, 0, 0, 0));

      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);

      time.dueDate = new DateTime(20, 3, 24, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.night = 21;
      time.morning = 8;
      time.idealStudyLenght = 1;

      time.nightOwl = false;

      time.accomodateSessions(sessions, eventsFromDevice);
      expect(time.finalSessions.length, 4);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start, equals(time1));
      expect(time.finalSessions[0].end, equals(time1end));
      expect(time.finalSessions[1].start, equals(time2));
      expect(time.finalSessions[1].end, equals(time2end));
      expect(time.finalSessions[2].start,
          equals(new DateTime(20, 3, 22, 18, 0, 0, 0, 0)));
      expect(time.finalSessions[2].end,
          equals(new DateTime(20, 3, 22, 19, 0, 0, 0, 0)));
      expect(time.finalSessions[3].start, equals(time4));
      expect(time.finalSessions[3].end, equals(time4end));
    });
    test(
        'On busy slots outside sweet spot, if early bird, tries that first, that outside morning, tries night',
        () {
      DateTime time1 = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 20, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 21, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 21, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 22, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 22, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 23, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 23, 20, 0, 0, 0, 0);
      // events from device

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);

      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 22, 19, 0, 0, 0, 0),
          end: new DateTime(20, 3, 22, 20, 0, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 22, 20, 0, 0, 0, 0),
          end: new DateTime(20, 3, 22, 21, 0, 0, 0, 0));

      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);

      //morning events
      EventFromDevice event3 = EventFromDevice(
          start: new DateTime(20, 3, 22, 11, 0, 0, 0, 0),
          end: new DateTime(20, 3, 22, 19, 0, 0, 0, 0));
      eventsFromDevice.add(event3);

      time.dueDate = new DateTime(20, 3, 24, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.night = 23;
      time.morning = 12;
      time.idealStudyLenght = 1;

      time.nightOwl = false;

      time.accomodateSessions(sessions, eventsFromDevice);
      expect(time.finalSessions.length, 4);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start, equals(time1));
      expect(time.finalSessions[0].end, equals(time1end));
      expect(time.finalSessions[1].start, equals(time2));
      expect(time.finalSessions[1].end, equals(time2end));
      expect(time.finalSessions[2].start,
          equals(new DateTime(20, 3, 22, 21, 0, 0, 0, 0)));
      expect(time.finalSessions[2].end,
          equals(new DateTime(20, 3, 22, 22, 0, 0, 0, 0)));
      expect(time.finalSessions[3].start, equals(time4));
      expect(time.finalSessions[3].end, equals(time4end));
    });
    test(
        'On one session busy the, creates a the session on extra day available, closes to the last session',
        () {
      DateTime time1 = new DateTime(20, 3, 25, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 25, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 26, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 26, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 27, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 27, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 28, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 28, 20, 0, 0, 0, 0);
      DateTime time5 = new DateTime(20, 3, 29, 19, 0, 0, 0, 0);
      DateTime time5end = new DateTime(20, 3, 29, 20, 0, 0, 0, 0);
      // events from device

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};
      var session5 = {"start": time5, "end": time5end};
      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);
      sessions.add(session5);
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 26, 7, 0, 0, 0, 0),
          end: new DateTime(20, 3, 26, 23, 0, 0, 0, 0));

      eventsFromDevice.add(event1);

      time.today = new DateTime(20, 3, 15, 14, 0, 0, 0, 0);
      time.dueDate = new DateTime(20, 3, 30, 14, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.night = 23;
      time.morning = 8;
      time.idealStudyLenght = 1;

      time.nightOwl = true;

      time.accomodateSessions(sessions, eventsFromDevice);
      expect(time.finalSessions.length, 5);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[1].start, equals(time1));
      expect(time.finalSessions[1].end, equals(time1end));
      expect(time.finalSessions[0].start,
          equals(new DateTime(20, 3, 24, 19, 0, 0, 0, 0)));
      expect(time.finalSessions[0].end,
          equals(new DateTime(20, 3, 24, 20, 0, 0, 0, 0)));
      expect(time.finalSessions[2].start, equals(time3));
      expect(time.finalSessions[2].end, equals(time3end));
      expect(time.finalSessions[3].start, equals(time4));
      expect(time.finalSessions[3].end, equals(time4end));
      expect(time.finalSessions[4].start, equals(time5));
      expect(time.finalSessions[4].end, equals(time5end));
    });
    test(
        'On test  close to start of month sessions behind it get accomodate (month change problem)',
        () {
      time.today = new DateTime(20, 3, 15, 14, 0, 0, 0, 0);
      time.dueDate = new DateTime(20, 4, 2, 14, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.night = 23;
      time.morning = 8;
      time.idealStudyLenght = 1;

      time.nightOwl = true;

      DateTime time1 = new DateTime(20, 3, 28, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 28, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 29, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 29, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 30, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 30, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 31, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 31, 20, 0, 0, 0, 0);
      DateTime time5 = new DateTime(20, 4, 1, 19, 0, 0, 0, 0);
      DateTime time5end = new DateTime(20, 4, 1, 20, 0, 0, 0, 0);
      // events from device

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};
      var session5 = {"start": time5, "end": time5end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);
      sessions.add(session5);
      List<EventFromDevice> eventsFromDevice = [];

      time.accomodateSessions(sessions, eventsFromDevice);
      expect(time.finalSessions.length, 5);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start,
          equals(new DateTime(20, 3, 28, 19, 0, 0, 0, 0)));
      expect(time.finalSessions[0].end,
          equals(new DateTime(20, 3, 28, 20, 0, 0, 0, 0)));
      expect(time.finalSessions[1].start, equals(time2));
      expect(time.finalSessions[1].end, equals(time2end));

      expect(time.finalSessions[2].start, equals(time3));
      expect(time.finalSessions[2].end, equals(time3end));
      expect(time.finalSessions[3].start, equals(time4));
      expect(time.finalSessions[3].end, equals(time4end));
      expect(time.finalSessions[4].start, equals(time5));
      expect(time.finalSessions[4].end, equals(time5end));
    });

    test(
        'Accomodates normally when studyLenght is 30 min (diff month for test)',
        () {
      time.today = new DateTime(20, 3, 15, 14, 0, 0, 0, 0);
      time.dueDate = new DateTime(20, 4, 2, 14, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.night = 23;
      time.morning = 8;
      time.idealStudyLenght = 30;

      time.nightOwl = true;

      DateTime time1 = new DateTime(20, 3, 28, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 28, 19, 30, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 29, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 29, 19, 30, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 30, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 30, 19, 30, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 31, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 31, 19, 30, 0, 0, 0);
      DateTime time5 = new DateTime(20, 4, 1, 19, 0, 0, 0, 0);
      DateTime time5end = new DateTime(20, 4, 1, 19, 30, 0, 0, 0);
      // events from device

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};
      var session5 = {"start": time5, "end": time5end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);
      sessions.add(session5);
      List<EventFromDevice> eventsFromDevice = [];

      time.accomodateSessions(sessions, eventsFromDevice);
      expect(time.finalSessions.length, 5);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start,
          equals(new DateTime(20, 3, 28, 19, 0, 0, 0, 0)));
      expect(time.finalSessions[0].end,
          equals(new DateTime(20, 3, 28, 19, 30, 0, 0, 0)));
      expect(time.finalSessions[1].start, equals(time2));
      expect(time.finalSessions[1].end, equals(time2end));

      expect(time.finalSessions[2].start, equals(time3));
      expect(time.finalSessions[2].end, equals(time3end));
      expect(time.finalSessions[3].start, equals(time4));
      expect(time.finalSessions[3].end, equals(time4end));
      expect(time.finalSessions[4].start, equals(time5));
      expect(time.finalSessions[4].end, equals(time5end));
    });
    test('Add normally when days in between are busy', () {
      time.sweetSpotStart = 16;
      time.sweetSpotEnd = 17;
      time.night = 20;
      time.morning = 6;
      time.idealStudyLenght = 1;
      time.nightOwl = true;
      time.today = new DateTime(20, 3, 25, 15, 0, 0, 0, 0);
      time.dueDate = new DateTime(20, 4, 3, 12, 0, 0, 0, 0);

      DateTime time1 = new DateTime(20, 4, 2, 16, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 4, 2, 17, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 4, 1, 16, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 4, 1, 17, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 31, 16, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 31, 17, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 30, 16, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 30, 17, 0, 0, 0, 0);
      DateTime time5 = new DateTime(20, 3, 29, 16, 0, 0, 0, 0);
      DateTime time5end = new DateTime(20, 3, 29, 17, 0, 0, 0, 0);
      // events from device

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};
      var session5 = {"start": time5, "end": time5end};
      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);
      sessions.add(session5);
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 31, 16, 0, 0, 0, 0),
          end: new DateTime(20, 3, 31, 17, 0, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 4, 1, 16, 0, 0, 0, 0),
          end: new DateTime(20, 4, 1, 17, 0, 0, 0, 0));
      EventFromDevice event3 = EventFromDevice(
          start: new DateTime(20, 4, 2, 16, 0, 0, 0, 0),
          end: new DateTime(20, 4, 2, 17, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      eventsFromDevice.add(event3);

      time.accomodateSessions(sessions, eventsFromDevice);
      expect(time.finalSessions.length, 5);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start, equals(time5));
      expect(time.finalSessions[0].end, equals(time5end));
      expect(time.finalSessions[1].start, equals(time4));
      expect(time.finalSessions[1].end, equals(time4end));
      expect(time.finalSessions[2].start,
          equals(new DateTime(20, 3, 31, 17, 0, 0, 0, 0)));
      expect(time.finalSessions[2].end,
          equals(new DateTime(20, 3, 31, 18, 0, 0, 0, 0)));
      expect(time.finalSessions[3].start,
          equals(new DateTime(20, 4, 1, 17, 0, 0, 0, 0)));
      expect(time.finalSessions[3].end,
          equals(new DateTime(20, 4, 1, 18, 0, 0, 0, 0)));
      expect(time.finalSessions[4].start,
          equals(new DateTime(20, 4, 2, 17, 0, 0, 0, 0)));
      expect(time.finalSessions[4].end,
          equals(new DateTime(20, 4, 2, 18, 0, 0, 0, 0)));
    });
  });
  group("getExtraDaysNeeded", () {
    test('return number correctly', () {
      final finalSessions = [
        Session(start: today),
        Session(start: today),
        Session(start: today),
      ];
      print(finalSessions.length);
      time.sessionsNeeded = 4;
      final response = time.getExtraDaysNeeded(finalSessions);
      expect(response, equals(1));
    });
    test('handles null', () {
      final finalSessions = null;
      time.sessionsNeeded = 4;
      final response = time.getExtraDaysNeeded(finalSessions);
      expect(response, equals(null));
    });
  });
  group("getFinalDays", () {
    test('return empty list evualuating only sessions', () {
      List<Map> sessions = [
        {
          "start": new DateTime(20, 3, 20, 19, 0, 0, 0, 0),
          "end": new DateTime(20, 3, 20, 20, 0, 0, 0, 0)
        },
        {
          "start": new DateTime(20, 3, 21, 19, 0, 0, 0, 0),
          "end": new DateTime(20, 3, 21, 20, 0, 0, 0, 0)
        },
        {
          "start": new DateTime(20, 3, 22, 19, 0, 0, 0, 0),
          "end": new DateTime(20, 3, 22, 20, 0, 0, 0, 0)
        },
        {
          "start": new DateTime(20, 3, 23, 19, 0, 0, 0, 0),
          "end": new DateTime(20, 3, 23, 20, 0, 0, 0, 0)
        },
      ];
      final result = time.getFinalDays(sessions);

      expect(
          result,
          equals([
            sessions[0]["start"],
            sessions[1]["start"],
            sessions[2]["start"],
            sessions[3]["start"]
          ]));
    });
    test('return list of days to evaluate not repeated', () {
      List<Map> sessions = [
        {
          "start": new DateTime(20, 3, 20, 19, 0, 0, 0, 0),
          "end": new DateTime(20, 3, 20, 20, 0, 0, 0, 0)
        },
        {
          "start": new DateTime(20, 3, 21, 19, 0, 0, 0, 0),
          "end": new DateTime(20, 3, 21, 20, 0, 0, 0, 0)
        },
        {
          "start": new DateTime(20, 3, 22, 19, 0, 0, 0, 0),
          "end": new DateTime(20, 3, 22, 20, 0, 0, 0, 0)
        },
        {
          "start": new DateTime(20, 3, 22, 20, 0, 0, 0, 0),
          "end": new DateTime(20, 3, 22, 21, 0, 0, 0, 0)
        },
      ];

      final result = time.getFinalDays(sessions);
      expect(
          result,
          equals([
            sessions[0]["start"],
            sessions[1]["start"],
            sessions[2]["start"],
          ]));
    });
  });
  group("getDaysUntilTest", () {
    test(
        'returns a list of days (ints) from today until the test not including test date',
        () {
      time.dueDate = new DateTime(20, 3, 25, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      time.night = 23;
      time.morning = 8;
      final result = time.getDaysUntilTest();
      expect(
          result,
          equals([
            new DateTime(20, 3, 20, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 21, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 22, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 23, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 24, 19, 0, 0, 0, 0)
          ]));
    });
    test(
        'returns a list of days (ints) from today until the test when test is on different month',
        () {
      time.night = 23;
      time.morning = 8;
      time.dueDate = new DateTime(20, 4, 2, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 25, 19, 0, 0, 0, 0);
      final result = time.getDaysUntilTest();
      expect(
          result,
          equals([
            new DateTime(20, 3, 25, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 26, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 27, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 28, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 29, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 30, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 31, 19, 0, 0, 0, 0),
            new DateTime(20, 4, 1, 19, 0, 0, 0, 0),
          ]));
    });
  });
  group("getDiff", () {
    test('get not repeated element between two lists', () {
      List<DateTime> finalDays = [
        new DateTime(20, 3, 29, 19, 0, 0, 0, 0),
        new DateTime(20, 3, 30, 19, 0, 0, 0, 0),
        new DateTime(20, 3, 31, 19, 0, 0, 0, 0),
        new DateTime(20, 4, 1, 19, 0, 0, 0, 0),
      ];
      List<DateTime> dayListUntilTest = [
        new DateTime(20, 3, 27, 19, 0, 0, 0, 0),
        new DateTime(20, 3, 28, 19, 0, 0, 0, 0),
        new DateTime(20, 3, 29, 19, 0, 0, 0, 0),
        new DateTime(20, 3, 30, 19, 0, 0, 0, 0),
        new DateTime(20, 3, 31, 19, 0, 0, 0, 0),
        new DateTime(20, 4, 1, 19, 0, 0, 0, 0),
      ];
      final result = time.getDiff(dayListUntilTest, finalDays);
      expect(
          result,
          equals([
            new DateTime(20, 3, 27, 19, 0, 0, 0, 0),
            new DateTime(20, 3, 28, 19, 0, 0, 0, 0),
          ]));
    });
  });
  group("getExtraDaysToTry", () {
    test('return a list with available days to allocate,using today ', () {
      DateTime time1 = new DateTime(20, 3, 16, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 16, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 17, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 17, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 18, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 18, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 19, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 19, 20, 0, 0, 0, 0);

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);

      time.dueDate = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 14, 19, 0, 0, 0, 0);
      time.night = 21;
      time.sweetSpotStart = 19;
      final response = time.getDaysToTry(session1, sessions);
      expect(
          response,
          equals({
            'daysToTry': [
              new DateTime(20, 3, 14, 19, 0, 0, 0, 0),
              new DateTime(20, 3, 15, 19, 0, 0, 0, 0)
            ],
            'session': {
              'start': new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
              'end': DateTime(20, 3, 16, 20, 0, 0, 0, 0)
            }
          }));
    });
    test('return a list with available days to allocate,not including today',
        () {
      DateTime time1 = new DateTime(20, 3, 16, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 16, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 17, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 17, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 18, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 18, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 19, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 19, 20, 0, 0, 0, 0);

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);
      time.dueDate = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 14, 21, 0, 0, 0, 0);
      time.night = 21;
      final response = time.getDaysToTry(session1, sessions);
      expect(
          response,
          equals({
            'daysToTry': [new DateTime(20, 3, 15, 21, 0, 0, 0, 0)],
            'session': {
              'start': new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
              'end': DateTime(20, 3, 16, 20, 0, 0, 0, 0)
            }
          }));
    });
    test('return an empty list when all days until the test are busy', () {
      DateTime time1 = new DateTime(20, 3, 16, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 16, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 17, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 17, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 18, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 18, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 19, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 19, 20, 0, 0, 0, 0);

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);

      time.dueDate = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 16, 21, 0, 0, 0, 0);
      time.night = 21;

      final response = time.getDaysToTry(session1, sessions);
      expect(
          response,
          equals({
            "daysToTry": [],
            'session': {
              'start': new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
              'end': new DateTime(20, 3, 16, 20, 0, 0, 0, 0),
            }
          }));
    });
    test(
        'return an empty list when all days until the test are busy and return sweetspot on 30min idealStud',
        () {
      time.dueDate = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 16, 21, 0, 0, 0, 0);
      time.night = 21;
      time.idealStudyLenght = 30;

      DateTime time1 = new DateTime(20, 3, 16, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 16, 19, 30, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 17, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 17, 19, 30, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 18, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 18, 19, 30, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 19, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 19, 19, 30, 0, 0, 0);

      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);

      final response = time.getDaysToTry(session1, sessions);
      expect(
          response,
          equals({
            "daysToTry": [],
            'session': {
              'start': new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
              'end': new DateTime(20, 3, 16, 19, 30, 0, 0, 0),
            }
          }));
    });
    test(
        'return days to try between today and test  occupied by device events.',
        () {
      time.dueDate = new DateTime(20, 3, 20, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 13, 16, 0, 0, 0, 0);
      time.night = 21;

      DateTime time1 = new DateTime(20, 3, 16, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 16, 20, 0, 0, 0, 0);
      DateTime time2 = new DateTime(20, 3, 17, 19, 0, 0, 0, 0);
      DateTime time2end = new DateTime(20, 3, 17, 20, 0, 0, 0, 0);
      DateTime time3 = new DateTime(20, 3, 18, 19, 0, 0, 0, 0);
      DateTime time3end = new DateTime(20, 3, 18, 20, 0, 0, 0, 0);
      DateTime time4 = new DateTime(20, 3, 19, 19, 0, 0, 0, 0);
      DateTime time4end = new DateTime(20, 3, 19, 20, 0, 0, 0, 0);

      var session = {"start": time1, "end": time1end};
      var session1 = {"start": time1, "end": time1end};
      var session2 = {"start": time2, "end": time2end};
      var session3 = {"start": time3, "end": time3end};
      var session4 = {"start": time4, "end": time4end};

      List<Map> sessions = [];

      sessions.add(session1);
      sessions.add(session2);
      sessions.add(session3);
      sessions.add(session4);
      // will return sessions with the hour of today
      final response = time.getDaysToTry(session, sessions);
      expect(
          response,
          equals({
            "daysToTry": [
              new DateTime(20, 3, 13, 16, 0, 0, 0, 0),
              new DateTime(20, 3, 14, 16, 0, 0, 0, 0),
              new DateTime(20, 3, 15, 16, 0, 0, 0, 0)
            ],
            'session': {
              'start': new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
              'end': new DateTime(20, 3, 16, 20, 0, 0, 0, 0),
            }
          }));
    });
  });
  group("nightOwlEarlyBird", () {
    test('sends error on null', () {
      List<EventFromDevice> eventsFromDevice = [];

      expect(() => time.nightOwlEarlyBird(eventsFromDevice, null),
          throwsException);
    });
    test('add to final sessions night owl and returns null', () {
      DateTime time1 = new DateTime(20, 3, 18, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 18, 20, 0, 0, 0, 0);
      var session = {"start": time1, "end": time1end};

      List<EventFromDevice> eventsFromDevice = [];

      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
          end: new DateTime(20, 3, 18, 22, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      time.finalSessions = [];

      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.nightOwl = true;

      //send session 20/19-20 => slot busy whole sweet spot =>nightOwl first => should return slot between sweetspot End and night
      time.nightOwlEarlyBird(eventsFromDevice, session);
      expect(time.finalSessions.length, 1);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start,
          equals(new DateTime(20, 3, 18, 22, 0, 0, 0, 0)));
      expect(time.finalSessions[0].end,
          equals(new DateTime(20, 3, 18, 23, 0, 0, 0, 0)));
    });

    test('return the session when no slots available', () {
      DateTime time1 = new DateTime(20, 3, 18, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 18, 20, 0, 0, 0, 0);
      var session = {"start": time1, "end": time1end};

      List<EventFromDevice> eventsFromDevice = [];

      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
          end: new DateTime(20, 3, 18, 22, 0, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 18, 8, 0, 0, 0, 0),
          end: new DateTime(20, 3, 18, 19, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      time.finalSessions = [];

      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 22;
      time.morning = 8;
      time.nightOwl = true;

      //send session 20/19-20 => slot busy whole sweet spot => nightOwl first => sweet spot and night are the same, nomore night time=> fail => return session 1 hour before morning
      final response = time.nightOwlEarlyBird(eventsFromDevice, session);
      expect(time.finalSessions.length, 0);
      expect(
          response,
          equals({
            "start": new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            "end": new DateTime(20, 3, 18, 20, 0, 0, 0, 0)
          }));
    });
    test('add to final sessions with nightOwl when studyLenght 30min ', () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.nightOwl = true;
      time.idealStudyLenght = 30;

      var session = {
        "start": new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 18, 19, 30, 0, 0, 0)
      };

      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 22, 0, 0, 0, 0))
      ];

      final response = time.nightOwlEarlyBird(eventsFromDevice, session);
      expect(response, null);
      expect(time.finalSessions.length, 1);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start,
          equals(new DateTime(20, 3, 18, 22, 0, 0, 0, 0)));
      expect(time.finalSessions[0].end,
          equals(new DateTime(20, 3, 18, 22, 30, 0, 0, 0)));
    });
  });
  group("earlyBirdNightOwl", () {
    test('sends error on null', () {
      List<EventFromDevice> eventsFromDevice = [];

      expect(() => time.earlyBirdNightOwl(eventsFromDevice, null),
          throwsException);
    });
    test('add to final sessions with earlyBird normally and returns null', () {
      DateTime time1 = new DateTime(20, 3, 18, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 18, 20, 0, 0, 0, 0);
      var session = {"start": time1, "end": time1end};

      List<EventFromDevice> eventsFromDevice = [];

      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
          end: new DateTime(20, 3, 18, 22, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      time.finalSessions = [];

      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.nightOwl = false;

      //send session 20/19-20 => slot busy whole sweet spot =>earlyBird first => should return slot before sweetspot start
      final response = time.earlyBirdNightOwl(eventsFromDevice, session);
      expect(response, null);
      expect(time.finalSessions.length, 1);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start,
          equals(new DateTime(20, 3, 18, 18, 0, 0, 0, 0)));
      expect(time.finalSessions[0].end,
          equals(new DateTime(20, 3, 18, 19, 0, 0, 0, 0)));
    });

    test('return the session when no slots available', () {
      DateTime time1 = new DateTime(20, 3, 18, 19, 0, 0, 0, 0);
      DateTime time1end = new DateTime(20, 3, 18, 20, 0, 0, 0, 0);
      var session = {"start": time1, "end": time1end};

      List<EventFromDevice> eventsFromDevice = [];

      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
          end: new DateTime(20, 3, 18, 22, 0, 0, 0, 0));
      EventFromDevice event2 = EventFromDevice(
          start: new DateTime(20, 3, 18, 8, 0, 0, 0, 0),
          end: new DateTime(20, 3, 18, 19, 0, 0, 0, 0));
      eventsFromDevice.add(event1);
      eventsFromDevice.add(event2);
      time.finalSessions = [];

      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 22;
      time.morning = 8;
      time.nightOwl = false;

      //send session 20/19-20 => slot busy whole sweet spot and morning => earlyBird first => => fail => return session 1 from weetSpot End
      final response = time.earlyBirdNightOwl(eventsFromDevice, session);
      expect(time.finalSessions.length, 0);
      expect(
          response,
          equals({
            "start": new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            "end": new DateTime(20, 3, 18, 20, 0, 0, 0, 0)
          }));
    });
    test('sends error on null', () {
      List<EventFromDevice> eventsFromDevice = [];

      expect(() => time.earlyBirdNightOwl(eventsFromDevice, null),
          throwsException);
    });
    test('add to final sessions with earlyBird when studyLenght 30min ', () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.nightOwl = false;
      time.idealStudyLenght = 30;

      var session = {
        "start": new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 18, 19, 30, 0, 0, 0)
      };

      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 22, 0, 0, 0, 0))
      ];

      final response = time.earlyBirdNightOwl(eventsFromDevice, session);
      expect(response, null);
      expect(time.finalSessions.length, 1);
      expect(time.finalSessions, isA<List<Session>>());
      expect(time.finalSessions[0].start,
          equals(new DateTime(20, 3, 18, 18, 30, 0, 0, 0)));
      expect(time.finalSessions[0].end,
          equals(new DateTime(20, 3, 18, 19, 0, 0, 0, 0)));
    });
  });
  group("addHours", () {
    test('add 1 hour from missed session to 3 remaining session', () {
      final finalSessions = [
        Session(
            start: new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 16, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 19, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 19, 20, 0, 0, 0, 0)),
      ];

      List<EventFromDevice> eventsFromDevice = [];
      time.finalSessions = finalSessions;
      final hoursToAdd = 1;

      time.addHours(finalSessions, hoursToAdd, eventsFromDevice);
      expect(time.finalSessions.length, 3);
      expect(
          time.finalSessions[0].start, new DateTime(20, 3, 16, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[0].end, new DateTime(20, 3, 16, 20, 20, 0, 0, 0));
      expect(
          time.finalSessions[1].start, new DateTime(20, 3, 18, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[1].end, new DateTime(20, 3, 18, 20, 20, 0, 0, 0));
      expect(
          time.finalSessions[2].start, new DateTime(20, 3, 19, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[2].end, new DateTime(20, 3, 19, 20, 20, 0, 0, 0));
    });
    test('add 1 hour from missed session to 4 remaining session', () {
      final finalSessions = [
        Session(
            start: new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 16, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 17, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 17, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 19, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 19, 20, 0, 0, 0, 0)),
      ];

      List<EventFromDevice> eventsFromDevice = [];

      final hoursToAdd = 1;
      time.finalSessions = finalSessions;
      time.addHours(finalSessions, hoursToAdd, eventsFromDevice);
      expect(time.finalSessions.length, 4);
      expect(
          time.finalSessions[0].start, new DateTime(20, 3, 16, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[0].end, new DateTime(20, 3, 16, 20, 15, 0, 0, 0));
      expect(
          time.finalSessions[1].start, new DateTime(20, 3, 17, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[1].end, new DateTime(20, 3, 17, 20, 15, 0, 0, 0));
      expect(
          time.finalSessions[2].start, new DateTime(20, 3, 18, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[2].end, new DateTime(20, 3, 18, 20, 15, 0, 0, 0));

      expect(
          time.finalSessions[3].start, new DateTime(20, 3, 19, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[3].end, new DateTime(20, 3, 19, 20, 15, 0, 0, 0));
    });
    test('add 2 hours from missed session to 3 remaining session', () {
      final finalSessions = [
        Session(
            start: new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 16, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 17, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 17, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 20, 0, 0, 0, 0)),
      ];

      List<EventFromDevice> eventsFromDevice = [];

      final hoursToAdd = 2;
      time.finalSessions = finalSessions;
      time.addHours(finalSessions, hoursToAdd, eventsFromDevice);
      expect(time.finalSessions.length, 3);
      expect(
          time.finalSessions[0].start, new DateTime(20, 3, 16, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[0].end, new DateTime(20, 3, 16, 20, 40, 0, 0, 0));
      expect(
          time.finalSessions[1].start, new DateTime(20, 3, 17, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[1].end, new DateTime(20, 3, 17, 20, 40, 0, 0, 0));
      expect(
          time.finalSessions[2].start, new DateTime(20, 3, 18, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[2].end, new DateTime(20, 3, 18, 20, 40, 0, 0, 0));
    });
    test('add original final sessions when new times not available', () {
      final finalSessions = [
        Session(
            start: new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 16, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 17, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 17, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 20, 0, 0, 0, 0)),
      ];

      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice event1 = EventFromDevice(
          start: new DateTime(20, 3, 17, 20, 0, 0, 0, 0),
          end: new DateTime(20, 3, 17, 21, 0, 0, 0, 0));

      eventsFromDevice.add(event1);
      time.finalSessions = finalSessions;
      final hoursToAdd = 2;
      //its going to try to allocate sessions of 19-20:40 on days 16-17-18 but 17 its busy til 21, should allocate the rest
      time.addHours(finalSessions, hoursToAdd, eventsFromDevice);
      expect(time.finalSessions.length, 3);
      expect(
          time.finalSessions[0].start, new DateTime(20, 3, 16, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[0].end, new DateTime(20, 3, 16, 20, 0, 0, 0, 0));
      expect(
          time.finalSessions[1].start, new DateTime(20, 3, 17, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[1].end, new DateTime(20, 3, 17, 20, 0, 0, 0, 0));
      expect(
          time.finalSessions[2].start, new DateTime(20, 3, 18, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[2].end, new DateTime(20, 3, 18, 20, 0, 0, 0, 0));
    });
    test('add hours add when studyLengt is 30minutes', () {
      time.idealStudyLenght = 30;
      final finalSessions = [
        Session(
            start: new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 16, 19, 30, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 17, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 17, 19, 30, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 19, 30, 0, 0, 0)),
      ];
      time.finalSessions = finalSessions;
      List<EventFromDevice> eventsFromDevice = [];

      final hoursToAdd = 2;

      time.addHours(finalSessions, hoursToAdd, eventsFromDevice);
      expect(time.finalSessions.length, 3);
      expect(
          time.finalSessions[0].start, new DateTime(20, 3, 16, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[0].end, new DateTime(20, 3, 16, 20, 10, 0, 0, 0));
      expect(
          time.finalSessions[1].start, new DateTime(20, 3, 17, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[1].end, new DateTime(20, 3, 17, 20, 10, 0, 0, 0));
      expect(
          time.finalSessions[2].start, new DateTime(20, 3, 18, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[2].end, new DateTime(20, 3, 18, 20, 10, 0, 0, 0));
    });
  });
  group("createSweetSpotSessions", () {
    test('create sessions normally', () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 23;
      time.dueDate = new DateTime(20, 3, 30, 19, 0, 0, 0, 0);
      time.complexity = 5;
      time.uid = "fakeUid";
      time.testId = "fakeTestId";
      time.today = new DateTime(20, 3, 12, 19, 0, 0, 0, 0);
      time.idealStudyLenght = 1;
      Map result1 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 3, 29, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 29, 20, 0, 0, 0, 0)
      };
      Map result2 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 3, 28, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 28, 20, 0, 0, 0, 0)
      };
      Map result3 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 3, 27, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 27, 20, 0, 0, 0, 0)
      };
      Map result4 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 3, 26, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 26, 20, 0, 0, 0, 0)
      };
      Map result5 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 3, 25, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 25, 20, 0, 0, 0, 0)
      };
      final sessions = time.createSweetSpotSessions();
      expect(sessions, isA<List<Map>>());
      expect(sessions.length, 5);
      expect(sessions, equals([result1, result2, result3, result4, result5]));
    });
    test('add normally when due date in 6 months in advance', () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 23;
      time.dueDate = new DateTime(20, 8, 30, 19, 0, 0, 0, 0);
      time.complexity = 5;
      time.uid = "fakeUid";
      time.testId = "fakeTestId";
      time.today = new DateTime(20, 2, 12, 19, 0, 0, 0, 0);
      time.idealStudyLenght = 1;
      Map result1 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 8, 29, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 8, 29, 20, 0, 0, 0, 0)
      };
      Map result2 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 8, 28, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 8, 28, 20, 0, 0, 0, 0)
      };
      Map result3 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 8, 27, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 8, 27, 20, 0, 0, 0, 0)
      };
      Map result4 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 8, 26, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 8, 26, 20, 0, 0, 0, 0)
      };
      Map result5 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 8, 25, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 8, 25, 20, 0, 0, 0, 0)
      };
      final sessions = time.createSweetSpotSessions();
      expect(sessions, isA<List<Map>>());
      expect(sessions.length, 5);
      expect(sessions, equals([result1, result2, result3, result4, result5]));
    });
    test(
        'add only 1 session when test its the next day and today is less than night cutoff ven when complexity its more',
        () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.dueDate = new DateTime(20, 3, 25, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 24, 19, 0, 0, 0, 0);
      time.complexity = 5;
      time.uid = "fakeUid";
      time.testId = "fakeTestId";
      time.idealStudyLenght = 1;

      Map result1 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 3, 24, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 24, 20, 0, 0, 0, 0)
      };

      final sessions = time.createSweetSpotSessions();
      expect(sessions, isA<List<Map>>());
      expect(sessions.length, 1);
      expect(sessions, equals([result1]));
    });
    test('add only 1 session when test its a year in advance 1', () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.dueDate = new DateTime(21, 1, 25, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 1, 24, 19, 0, 0, 0, 0);
      time.complexity = 4;
      time.uid = "fakeUid";
      time.testId = "fakeTestId";
      time.idealStudyLenght = 1;

      Map result1 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(21, 1, 24, 19, 0, 0, 0, 0),
        "end": new DateTime(21, 1, 24, 20, 0, 0, 0, 0)
      };
      Map result2 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(21, 1, 23, 19, 0, 0, 0, 0),
        "end": new DateTime(21, 1, 23, 20, 0, 0, 0, 0)
      };
      Map result3 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(21, 1, 22, 19, 0, 0, 0, 0),
        "end": new DateTime(21, 1, 22, 20, 0, 0, 0, 0)
      };
      Map result4 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(21, 1, 21, 19, 0, 0, 0, 0),
        "end": new DateTime(21, 1, 21, 20, 0, 0, 0, 0)
      };

      final sessions = time.createSweetSpotSessions();
      expect(sessions, isA<List<Map>>());
      expect(sessions.length, 4);
      expect(sessions, equals([result1, result2, result3, result4]));
    });
    test(
        'add normally when test is begginin of a diff month (session go to previuus month',
        () {
      time.sweetSpotStart = 16;
      time.sweetSpotEnd = 17;
      time.night = 23;
      time.dueDate = new DateTime(20, 4, 5, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 25, 19, 0, 0, 0, 0);
      time.complexity = 5;
      time.uid = "fakeUid";
      time.testId = "fakeTestId";
      time.idealStudyLenght = 1;

      //first will use today at 19, it will set to 19-20,
      Map result1 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 4, 4, 16, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 4, 17, 0, 0, 0, 0)
      };
      Map result2 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 4, 3, 16, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 3, 17, 0, 0, 0, 0)
      };
      Map result3 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 4, 2, 16, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 2, 17, 0, 0, 0, 0)
      };
      Map result4 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 4, 1, 16, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 1, 17, 0, 0, 0, 0)
      };
      Map result5 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 3, 31, 16, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 31, 17, 0, 0, 0, 0)
      };

      final sessions = time.createSweetSpotSessions();
      expect(sessions, isA<List<Map>>());
      expect(sessions.length, 5);
      expect(sessions, equals([result1, result2, result3, result4, result5]));
    });
    test('creates 30min slot when idealStudy is 30', () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 22;
      time.night = 23;
      time.dueDate = new DateTime(20, 1, 25, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 1, 15, 19, 0, 0, 0, 0);
      time.complexity = 2;
      time.uid = "fakeUid";
      time.testId = "fakeTestId";
      time.idealStudyLenght = 30;

      Map result1 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 1, 24, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 1, 24, 19, 30, 0, 0, 0)
      };
      Map result2 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 1, 23, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 1, 23, 19, 30, 0, 0, 0)
      };
      Map result3 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 1, 22, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 1, 22, 19, 30, 0, 0, 0)
      };
      Map result4 = {
        "uid": "fakeUid",
        "testId": "fakeTestId",
        "sessionNumber": 0,
        "start": new DateTime(20, 1, 21, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 1, 21, 19, 30, 0, 0, 0)
      };

      final sessions = time.createSweetSpotSessions();
      expect(sessions, isA<List<Map>>());
      expect(sessions.length, 4);
      expect(sessions, equals([result1, result2, result3, result4]));
    });
  });

  group("tryDays", () {
    test(
        'should not accomodate a session that is more that one day apart from the first session',
        () {
      time.dueDate = new DateTime(20, 3, 25, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 13, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.morning = 8;
      time.night = 23;
      time.finalSessions = [
        Session(
            start: new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 16, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 17, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 17, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 20, 0, 0, 0, 0)),
      ];

      List<DateTime> daysToTry = [
        new DateTime(20, 3, 13, 0, 0, 0, 0, 0),
        new DateTime(20, 3, 14, 0, 0, 0, 0, 0),
        new DateTime(20, 3, 15, 0, 0, 0, 0, 0),
      ];

      final session = {
        "start": new DateTime(20, 3, 15, 7, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 15, 23, 0, 0, 0, 0)
      };

      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 3, 15, 7, 0, 0, 0, 0),
            end: new DateTime(20, 3, 15, 23, 0, 0, 0, 0))
      ];
      final response = time.tryDays(daysToTry, session, eventsFromDevice);
      expect(response, {
        "start": new DateTime(20, 3, 13, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 13, 20, 0, 0, 0, 0)
      });
    });
    test('Should accomodate on a extra day the closest to the last session',
        () {
      time.dueDate = new DateTime(20, 3, 25, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 13, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.morning = 8;
      time.night = 23;
      time.finalSessions = [
        Session(
            start: new DateTime(20, 3, 16, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 16, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 17, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 17, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 18, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 18, 20, 0, 0, 0, 0)),
      ];

      List<DateTime> daysToTry = [
        new DateTime(20, 3, 13, 0, 0, 0, 0, 0),
        new DateTime(20, 3, 14, 0, 0, 0, 0, 0),
        new DateTime(20, 3, 15, 0, 0, 0, 0, 0),
      ];

      final session = {
        "start": new DateTime(20, 3, 15, 4, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 15, 6, 0, 0, 0, 0)
      };

      List<EventFromDevice> eventsFromDevice = [];
      final response = time.tryDays(daysToTry, session, eventsFromDevice);
      expect(response, null);
      expect(
          time.finalSessions[3].start, new DateTime(20, 3, 15, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[3].end, new DateTime(20, 3, 15, 20, 0, 0, 0, 0));
    });
    test('Should accomodate normally when days to try are in separate months',
        () {
      time.dueDate = new DateTime(20, 3, 2, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 28, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.morning = 8;
      time.night = 23;
      time.finalSessions = [
        Session(
            start: new DateTime(20, 3, 29, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 29, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 30, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 30, 20, 0, 0, 0, 0)),
        Session(
            start: new DateTime(20, 3, 31, 19, 0, 0, 0, 0),
            end: new DateTime(20, 3, 31, 20, 0, 0, 0, 0)),
      ];

      List<DateTime> daysToTry = [
        new DateTime(20, 4, 1, 0, 0, 0, 0, 0),
        new DateTime(20, 3, 28, 0, 0, 0, 0, 0),
      ];

      final session = {
        "start": new DateTime(20, 4, 1, 20, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 1, 19, 0, 0, 0, 0)
      };

      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 3, 28, 7, 0, 0, 0, 0),
            end: new DateTime(20, 3, 28, 23, 0, 0, 0, 0))
      ];

      final response = time.tryDays(daysToTry, session, eventsFromDevice);
      expect(response, null);
      expect(
          time.finalSessions[3].start, new DateTime(20, 4, 1, 19, 0, 0, 0, 0));
      expect(time.finalSessions[3].end, new DateTime(20, 4, 1, 20, 0, 0, 0, 0));
    });
    test(
        'Should accomodate normally when days to try are in separate months and finalSessions is empty',
        () {
      time.dueDate = new DateTime(20, 3, 2, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 28, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.morning = 8;
      time.night = 23;

      List<DateTime> daysToTry = [
        new DateTime(20, 4, 1, 0, 0, 0, 0, 0),
        new DateTime(20, 3, 28, 0, 0, 0, 0, 0),
      ];

      final session = {
        "start": new DateTime(20, 4, 1, 20, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 1, 19, 0, 0, 0, 0)
      };

      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 3, 28, 7, 0, 0, 0, 0),
            end: new DateTime(20, 3, 28, 23, 0, 0, 0, 0))
      ];

      final response = time.tryDays(daysToTry, session, eventsFromDevice);
      expect(response, null);
      expect(
          time.finalSessions[0].start, new DateTime(20, 4, 1, 19, 0, 0, 0, 0));
      expect(time.finalSessions[0].end, new DateTime(20, 4, 1, 20, 0, 0, 0, 0));
    });
    test('Should accomodate 30 min slots when idealStudy lenght is 30', () {
      time.dueDate = new DateTime(20, 3, 2, 19, 0, 0, 0, 0);
      time.today = new DateTime(20, 3, 28, 19, 0, 0, 0, 0);
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 21;
      time.morning = 8;
      time.night = 23;
      time.idealStudyLenght = 30;

      List<DateTime> daysToTry = [
        new DateTime(20, 4, 1, 0, 0, 0, 0, 0),
        new DateTime(20, 3, 28, 0, 0, 0, 0, 0),
      ];

      final session = {
        "start": new DateTime(20, 4, 1, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 1, 20, 0, 0, 0, 0)
      };

      List<EventFromDevice> eventsFromDevice = [
        EventFromDevice(
            start: new DateTime(20, 3, 28, 7, 0, 0, 0, 0),
            end: new DateTime(20, 3, 28, 23, 0, 0, 0, 0))
      ];

      final response = time.tryDays(daysToTry, session, eventsFromDevice);
      expect(response, null);
      expect(
          time.finalSessions[0].start, new DateTime(20, 4, 1, 19, 0, 0, 0, 0));
      expect(
          time.finalSessions[0].end, new DateTime(20, 4, 1, 19, 30, 0, 0, 0));
    });
  });
  group("setToSweetSpot", () {
    test(
        'set to sweet spot when start and end are different days (past midnight)',
        () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 23;
      time.idealStudyLenght = 1;
      Map session = {
        "start": new DateTime(20, 3, 31, 23, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 1, 0, 0, 0, 0, 0)
      };
      final response = time.setToSweetSpot(session, session["start"].day);
      expect(response, {
        "start": new DateTime(20, 3, 31, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 31, 20, 0, 0, 0, 0)
      });
    });
    test('set to sweet spot when idealStudy is 30', () {
      time.sweetSpotStart = 19;
      time.sweetSpotEnd = 23;
      time.idealStudyLenght = 30;
      Map session = {
        "start": new DateTime(20, 3, 25, 22, 0, 0, 0, 0),
        "end": new DateTime(20, 4, 25, 22, 30, 0, 0, 0)
      };
      final response = time.setToSweetSpot(session, session["start"].day);
      expect(response, {
        "start": new DateTime(20, 3, 25, 19, 0, 0, 0, 0),
        "end": new DateTime(20, 3, 25, 19, 30, 0, 0, 0)
      });
    });
  });
}
