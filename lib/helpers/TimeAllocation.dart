import 'package:test_device/models/event_from_device.dart';
import 'package:test_device/models/session.dart';
import 'package:test_device/services/database.dart';
import 'package:test_device/shared/Error.dart';

class TimeAllocation {
  String uid;
  DateTime dueDate;
  DateTime today = DateTime.now();
  int importance;
  int complexity;
  int idealStudyLenght;
  String testId;
  int morning;
  int night;
  int sweetSpotStart;
  int sweetSpotEnd;
  List<Session> finalSessions;
  bool nightOwl;
  int daysToStudy;
  int hoursNeeded;
  int sessionsNeeded;
  bool testing;
  TimeAllocation(
    this.uid,
    this.finalSessions,
    this.complexity, {
    this.idealStudyLenght = 1,
    this.sweetSpotEnd = 21,
    this.sweetSpotStart = 19,
    this.nightOwl = true,
    this.dueDate,
    this.importance = 0,
    this.testId = "",
    this.morning = 8,
    this.night = 21,
    this.testing = false,
  });

  int daysUntil(DateTime dueDate) {
    try {
      if (dueDate != null) {
        if (useToday()) {
          final dayToCompare =
              new DateTime(today.year, today.month, today.day, 8, 0, 0, 0, 0);
          var daysUntil = dueDate.difference(dayToCompare).inDays;
          return daysUntil;
        } else {
          var daysUntil = dueDate.difference(today).inDays;
          return daysUntil;
        }

        /*    if (useToday() == true) {
          daysUntil += 1;
        } */

      } else {
        return null;
      }
    } catch (e) {
      throw new Error("Error on days Until $e");
    }
  }

  int sessionsToAllocate(int hoursNeeded) {
    try {
      if (hoursNeeded > 0 && hoursNeeded != null) {
        double numSessions = 0;
        if (idealStudyLenght == 30) {
          numSessions = (hoursNeeded * 60) / 30;
        } else {
          numSessions = hoursNeeded / idealStudyLenght;
        }

        return numSessions.toInt();
      } else {
        return 0;
      }
    } catch (e) {
      throw new Error("Error on sessionsToAllocate $e");
    }
  }

  int timeToStudyNeeded(int complexity) {
    if (complexity > 0 && complexity != null) {
      int totalTimeNeeded = complexity;
      return totalTimeNeeded;
    } else {
      throw new Error("Complexity cannot be zero");
    }
  }

  bool inBetween(DateTime dateToCompare, DateTime date1, DateTime date2) {
    try {
      if (dateToCompare != null && date1 != null && date2 != null) {
        return dateToCompare.isAfter(date1) && dateToCompare.isBefore(date2);
      } else {
        throw new Error("some of the parameters on inBetween is not defined");
      }
    } catch (e) {
      throw new Error("Error on Inbetween $e");
    }
  }

  bool isSame(DateTime dateToCompare, DateTime date1) {
    try {
      if (dateToCompare != null && date1 != null) {
        return dateToCompare.compareTo(date1) == 0;
      } else {
        throw new Error("some of the parameters on isSame is not defined");
      }
    } catch (e) {
      throw new Error("error on isSame $e");
    }
  }

  bool isLessThanTwoDaysApart(DateTime date1, DateTime date2) {
    final newDate1 =
        new DateTime(date1.year, date1.month, date1.day, 0, 0, 0, 0, 0);
    final newDate2 =
        new DateTime(date2.year, date2.month, date2.day, 0, 0, 0, 0, 0);
    final diff = newDate1.difference(newDate2).inDays * -1;
    return diff < 2;
  }

  Future<List<EventFromDevice>> getEventsFromDevice() async {
    print("Events form device");
    try {
      List<EventFromDevice> eventsFromDevice = [];
      EventFromDevice device =
          EventFromDevice(daysToTest: daysUntil(this.dueDate), fromWhen: 0);

      eventsFromDevice = await device.retrieveEventsFromDevice(this.uid);
      if (eventsFromDevice != null) {
        eventsFromDevice.forEach((event) => print("$event\n"));
        return eventsFromDevice;
      } else {
        eventsFromDevice = [];
        return eventsFromDevice;
      }
    } catch (e) {
      throw new Error("error on get events from device");
    }
  }

  bool isAvailableFromDevice(
      Map session, List<EventFromDevice> eventsFromDevice) {
    try {
      var isAvailable = false;
      var locked = false;

      if (eventsFromDevice.isNotEmpty) {
        eventsFromDevice.forEach((device) {
          final sesStart = session["start"];
          final sesEnd = session["end"];
          final devStart = device.start;
          final devEnd = device.end;

          if ((inBetween(sesStart, devStart, devEnd) ||
                  inBetween(sesEnd, devStart, devEnd)) ||
              (isSame(sesStart, devStart) && isSame(sesEnd, devEnd)) ||
              (inBetween(devStart, sesStart, sesEnd) &&
                  isSame(sesEnd, devEnd)) ||
              (isSame(sesStart, devStart) &&
                  inBetween(devEnd, sesStart, sesEnd)) ||
              (inBetween(sesStart, devStart, devEnd) &&
                  isSame(sesEnd, devEnd)) ||
              (isSame(devStart, sesStart) &&
                  inBetween(sesEnd, devStart, devEnd))) {
            //reject slot is busy
            isAvailable = false;
            locked = true;
          } else {
            if (locked == false) {
              isAvailable = true;
            }
          }
        });
      } else {
        isAvailable = true;
        return isAvailable;
      }

      return isAvailable;
    } catch (e) {
      throw new Error("error on is Available");
    }
  }

  List<Map> createSweetSpotSessions() {
    try {
      final List<Map> sessions = new List();
      daysToStudy = daysUntil(this.dueDate);
      hoursNeeded = timeToStudyNeeded(this.complexity);
      sessionsNeeded = sessionsToAllocate(hoursNeeded);

      var dayBeforeTest = this.dueDate;
      dayBeforeTest = dayBeforeTest.add(new Duration(days: -1));
      /*  var localSweetSpotStart = sweetSpotStart; */

      if (sessionsNeeded > daysToStudy) sessionsNeeded = daysToStudy;
      if (daysToStudy > 0) {
        print(
            "Days to study : $daysToStudy - Number of Session: $sessionsNeeded - Total Study time (hrs): $hoursNeeded - Complexity: ${this.complexity} Test Due Date:$dueDate");
        var counter = 0;
        var counter1 = 0;
        for (var i = sessionsNeeded; i > 0; i--) {
          var start;
          var end;
          if (idealStudyLenght == 30) {
            start = dayBeforeTest.add(new Duration(days: counter));
            start = new DateTime(
              start.year,
              start.month,
              start.day,
              sweetSpotStart,
              0,
              0,
              0,
              0,
            );
            end = start.add(new Duration(minutes: 30));
          } else {
            start = dayBeforeTest.add(new Duration(days: counter));
            start = new DateTime(
              start.year,
              start.month,
              start.day,
              sweetSpotStart,
              0,
              0,
              0,
              0,
            );
            end = start.add(new Duration(hours: idealStudyLenght));
          }

          sessions.insert(counter1, {
            "uid": this.uid,
            "testId": this.testId,
            "sessionNumber": 0,
            "start": start,
            "end": end
          });
          counter--;
          counter1++;
        }
        return sessions;
      } else {
        print("not enough days to study, ending process");
        return null;
      }
    } catch (e) {
      throw new Error("error onerror create sweet spot sessions $e");
    }
  }

  Future<void> calculateSessions() async {
    try {
      DatabaseService database = new DatabaseService(this.uid);
      final userInfo = await database.getUserSettings();
      this.night = userInfo["night"];
      this.morning = userInfo["morning"];
      this.nightOwl = userInfo["nightOwl"];
      this.sweetSpotStart = userInfo["sweetSpotStart"];
      this.sweetSpotEnd = userInfo["sweetSpotEnd"];

      List<EventFromDevice> eventsFromDevice = await getEventsFromDevice();
      if (eventsFromDevice == null) eventsFromDevice = [];

      final sweetSpotSessions = createSweetSpotSessions();

      if (sweetSpotSessions == null) {
        print("not enough days to allocate ending");
      } else {
        print("sessions to create");
        sweetSpotSessions.forEach((session) => print("$session\n"));
        print("CALLING ACCOMODATE");
        await accomodateSessions(sweetSpotSessions, eventsFromDevice);
        print("ACOMMODATE FINISHED");
      }
    } catch (e) {
      print(" error on calculate Sessions $e");
    }
  }

  Map addToFinalSessions(Map session, List<EventFromDevice> eventsFromDevice) {
    try {
      /*    if (session != null) checkToday(session); */
      if (isAvailableFromDevice(session, eventsFromDevice) == true) {
        finalSessions.add(Session(
            sessionNumber: session["sessionNumber"],
            testId: testId,
            start: session["start"],
            end: session["end"],
            uid: this.uid));
        return null;
      } else {
        setToSweetSpot(session, session["start"].day);
        return session;
      }
    } catch (e) {
      throw new Error("error on addToFinalSessions $e");
    }
  }

  Map addSessionToFinalSessions(
      Session session, List<EventFromDevice> eventsFromDevice) {
    List<Map> rejectedSessions = [];
    try {
      Map mapSession = {
        "testId": session.testId,
        "sessionNumber": session.sessionNumber,
        "start": session.start,
        "end": session.end
      };
      if (isAvailableFromDevice(mapSession, eventsFromDevice) == true) {
        finalSessions.add(Session(
            sessionNumber: mapSession["sessionNumber"],
            testId: mapSession["testId"],
            start: mapSession["start"],
            end: mapSession["end"],
            uid: this.uid));
        return null;
      } else {
        rejectedSessions.add(mapSession);
        return mapSession;
      }
    } catch (e) {
      throw new Error("error on addToFinalSessions $e");
    }
  }

  bool checkSweetSpot(Map session, List<EventFromDevice> eventsFromDevice) {
    print("checking sweet spot for\n $session");
    try {
      if (session["end"].hour <= sweetSpotEnd) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw new Error("error on checkSweetSpot $e");
    }
  }

  Map addHrToSession(Map session, int hours) {
    try {
      if (session != null) {
        session["start"] = session["start"].add(new Duration(hours: hours));
        session["end"] = session["end"].add(new Duration(hours: hours));
        return session;
      } else {
        return null;
      }
    } catch (e) {
      throw new Error("error on addHrToSession  $e");
    }
  }

  // we hit this spot after tryng to allocate sweet spot all the same hour for every day needed
  // this will try to accomodate netween sweet spot on that day start on sweetSpotStart time.
  Map addIfSweetSpot(
    List<EventFromDevice> eventsFromDevice,
    Map session,
  ) {
    try {
      if (session != null) checkToday(session);
      if (finalSessions.isNotEmpty)
        this.finalSessions.sort((a, b) => b.start.compareTo(a.start));
      while (checkSweetSpot(session, eventsFromDevice) == true) {
        final isAvailable = isAvailableFromDevice(session, eventsFromDevice);
        if (isAvailable == true) {
          if (finalSessions.isNotEmpty) {
            if (isLessThanTwoDaysApart(session["start"],
                    this.finalSessions[finalSessions.length - 1].start) ==
                true) {
              addToFinalSessions(session, eventsFromDevice);
              return null;
            } else {
              break;
            }
          } else {
            addToFinalSessions(session, eventsFromDevice);
            return null;
          }
        } else {
          print("not available adding another hour");
          session = addHrToSession(session, 1);
        }
      }
      print("no session found on sweet spot exiting addIfSweetSpot");
      setToSweetSpot(session, session["start"].day);
      return session;
    } catch (e) {
      throw new Error("error on Add if sweet spot $e");
    }
  }

  Map addIfNightOwl(
    List<EventFromDevice> eventsFromDevice,
    Map<dynamic, dynamic> session,
  ) {
    print("addIfNightOwl with $session");
    try {
      if (session != null) checkToday(session);
      if (finalSessions.isNotEmpty)
        this.finalSessions.sort((a, b) => b.start.compareTo(a.start));
      session["start"] = new DateTime(
        session["start"].year,
        session["start"].month,
        session["start"].day,
        sweetSpotEnd,
        0,
        0,
        0,
        0,
      );
      session["end"] = addStudyLenght(session["start"]);
      while (session["start"].hour < night) {
        final isAvailable = isAvailableFromDevice(session, eventsFromDevice);
        print("available $isAvailable");
        if (isAvailable == true) {
          if (finalSessions.isNotEmpty) {
            if (isLessThanTwoDaysApart(session["start"],
                    this.finalSessions[finalSessions.length - 1].start) ==
                true) {
              addToFinalSessions(session, eventsFromDevice);
              return null;
            } else {
              break;
            }
          } else {
            addToFinalSessions(session, eventsFromDevice);
            return null;
          }
        } else {
          print("not available adding another hour");
          session = addHrToSession(session, 1);
        }
      }
      setToSweetSpot(session, session["start"].day);
      return session;
    } catch (e) {
      throw new Error("error on addIfNightOwl $e");
    }
  }

  DateTime setEarlyBirdStart(DateTime dayToSet) {
    dayToSet = new DateTime(dayToSet.year, dayToSet.month, dayToSet.day,
        sweetSpotStart, dayToSet.minute, 0, 0, 0);
    if (idealStudyLenght == 30) {
      return dayToSet.add(new Duration(minutes: -30));
    } else {
      return dayToSet.add(new Duration(hours: -idealStudyLenght.toInt()));
    }
  }

  Map addIfEarlyBird(
      List<EventFromDevice> eventsFromDevice, Map<dynamic, dynamic> session) {
    print("addIfEarlyBird with $session");
    try {
      if (session != null) checkToday(session);
      if (finalSessions.isNotEmpty)
        this.finalSessions.sort((a, b) => b.start.compareTo(a.start));
      session["start"] = setEarlyBirdStart(session["start"]);
      session["end"] = addStudyLenght(session["start"]);

      while (session["start"].hour >= morning) {
        final isAvailable = isAvailableFromDevice(session, eventsFromDevice);

        if (isAvailable == true) {
          if (finalSessions.isNotEmpty) {
            if (isLessThanTwoDaysApart(session["start"],
                    this.finalSessions[finalSessions.length - 1].start) ==
                true) {
              addToFinalSessions(session, eventsFromDevice);
              return null;
            } else {
              break;
            }
          } else {
            addToFinalSessions(session, eventsFromDevice);
            return null;
          }
          //check if no more sessions are left in rejected sessions
        } else {
          print("not available adding another hour");
          session = addHrToSession(session, -1);
        }
      }
      setToSweetSpot(session, session["start"].day);
      return session;
    } catch (e) {
      throw new Error("error on addIfEarlyBird $e");
    }
  }

  int getExtraDaysNeeded(List<Session> finalSessions) {
    try {
      if (finalSessions != null) {
        final sessionsLeftToAllocate =
            this.sessionsNeeded - finalSessions.length;
        return sessionsLeftToAllocate;
      } else {
        return null;
      }
    } catch (e) {
      throw new Error("error on get Extra Days Needed $e");
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return (date1.year == date2.year) &&
        (date1.month == date2.month) &&
        (date1.day == date2.day);
  }

  List<DateTime> getFinalDays(List<Map> sessions) {
    try {
      List<DateTime> finalDays = [];

      if (sessions.isNotEmpty && sessions != null) {
        sessions.forEach((element) {
          final response = finalDays
              .where((finalDay) => isSameDay(finalDay, element["start"]));
          if (response.isEmpty) {
            finalDays.add(element["start"]);
          }
        });
        finalDays.sort((a, b) => a.compareTo(b));
        return finalDays;
      } else {
        print("final sessions is empty");
        finalDays = [];
        return finalDays;
      }
    } catch (e) {
      throw new Error("error on getFinalDays $e");
    }
  }

  bool useToday() {
    try {
      return today.hour < night;
    } catch (e) {
      throw new Error("error on use Today $e");
    }
  }

  int getDiffInDays(DateTime startDate, DateTime endDate) {
    return (startDate.difference(endDate.add(new Duration(days: -1))).inDays *
        -1);
  }

  List<DateTime> getDaysUntilTest() {
    try {
      bool todayUse = useToday();
      DateTime startDay = today;
      List<DateTime> dayList = [];
      if (todayUse == true) {
        dayList.add(startDay);
      }
      final daysTilTest = getDiffInDays(startDay, dueDate);

      for (var i = 0; i < daysTilTest; i++) {
        startDay = startDay.add(new Duration(days: 1));
        dayList.add(startDay);
      }
      print(dayList);
      return dayList;
    } catch (e) {
      throw new Error("error on getDaysUntilTest $e");
    }
  }

  List<DateTime> getDiff(
    List<DateTime> dayListUntilTest,
    List<DateTime> finalDays,
  ) {
    List<DateTime> output = [];
    try {
      for (var i = 0; i < dayListUntilTest.length; i++) {
        final response = finalDays
            .where((finalDay) => isSameDay(dayListUntilTest[i], finalDay));
        if (response.isEmpty) {
          output.add(dayListUntilTest[i]);
        }
      }
      return output;
    } catch (e) {
      throw new Error("error on getDiff $e");
    }
  }

  Map<String, dynamic> getDaysToTry(Map session, List<Map> sessions) {
    try {
      List<DateTime> finalDays = getFinalDays(sessions);
      List<DateTime> dayListUntilTest = getDaysUntilTest();
      List<DateTime> diff = getDiff(
        dayListUntilTest,
        finalDays,
      );
      setToSweetSpot(session, session["start"].day);
      if (diff.isNotEmpty) {
        return {"daysToTry": diff, "session": session};
      } else {
        diff = [];
        return {"daysToTry": diff, "session": session};
      }
    } catch (e) {
      throw new Error("error on getExtraDaysAvailable $e");
    }
  }

  DateTime addStudyLenght(DateTime dateToAdd) {
    if (idealStudyLenght == 30) {
      return dateToAdd.add(new Duration(minutes: 30));
    } else {
      return dateToAdd.add(new Duration(hours: idealStudyLenght.toInt()));
    }
  }

  Map setToSweetSpot(Map sessionToSet, int dayToSet) {
    sessionToSet["start"] = new DateTime(sessionToSet["start"].year,
        sessionToSet["start"].month, dayToSet, sweetSpotStart, 0, 0, 0, 0);
    sessionToSet["end"] = addStudyLenght(sessionToSet["start"]);
    return sessionToSet;
  }

  Map nightOwlEarlyBird(
      List<EventFromDevice> eventsFromDevice, Map backFromSweetSpot) {
    print("trying nigh owl first with $backFromSweetSpot");

    try {
      final backFromNightOwl =
          addIfNightOwl(eventsFromDevice, backFromSweetSpot);
      if (backFromNightOwl == null) {
        print("session accomodated with night owl");
        return null;
      } else if (backFromNightOwl != null) {
        print(
            "could not accomodate with night owl sweet spot trying earlyBird");
        final backFromEarlyBird =
            addIfEarlyBird(eventsFromDevice, backFromNightOwl);
        if (backFromEarlyBird == null) {
          print("session accomodated with early Bird");
          return null;
        } else {
          print(
              "not accomodated with any sweet options start diff day workflow");
          return backFromSweetSpot;
        }
      } else {
        return null;
      }
    } catch (e) {
      throw new Error("error on nightOwlEarlyBird $e");
    }
  }

  Map earlyBirdNightOwl(
      List<EventFromDevice> eventsFromDevice, Map backFromSweetSpot) {
    print("start with early bird first $backFromSweetSpot");
    try {
      final backFromEarlyBird =
          addIfEarlyBird(eventsFromDevice, backFromSweetSpot);
      if (backFromEarlyBird == null) {
        print("session accomodated with early Bird");
        return null;
      } else {
        print("early bird no success, trying nightowl");
        final backFromNightOwl =
            addIfNightOwl(eventsFromDevice, backFromEarlyBird);
        if (backFromNightOwl == null) {
          print("session accomodated with night owl");
          return null;
        } else {
          print("coul not accomodate early/owl start next day workflow");
          return backFromSweetSpot;
        }
      }
    } catch (e) {
      throw new Error("error on earlyBirdNightOwl $e");
    }
  }

  void setSessionNumber(List<Session> finalSessions) {
    finalSessions.sort((a, b) => a.start.compareTo(b.start));
    var counter = 1;
    finalSessions.forEach((finalSession) {
      finalSession.sessionNumber = counter;
      counter++;
    });
    print("FINAL SESSION");
    print("=============");
    finalSessions.forEach((finalSession) {
      print("$finalSession\n");
    });
  }

  void checkToday(Map session) {
    if (session["start"].day == today.day) {
      if (useToday()) {
        session["start"] = new DateTime(
            session["start"].year,
            session["start"].month,
            session["start"].day,
            today.hour + 1,
            0,
            0,
            0,
            0);
        if (idealStudyLenght == 30) {
          session["end"] = session["start"].add(new Duration(minutes: 30));
        } else {
          session["end"] =
              session["start"].add(new Duration(hours: idealStudyLenght));
        }
      }
    }
  }

  Future<void> createSessions(List<Session> finalSessions) async {
    setSessionNumber(finalSessions);

    DatabaseService database = new DatabaseService(this.uid);
    this.finalSessions = finalSessions;
    if (testing == false) {
      await Future.forEach(finalSessions, (session) async {
        await database.createSessions(this.uid, this.testId,
            session.sessionNumber, session.start, session.end);
      });
    } else {
      print("testing enviroment, in create function");
      return null;
    }
  }

  void addHours(List<Session> finalSessions, int hoursToAdd,
      List<EventFromDevice> eventsFromDevice) {
    try {
      //divide hours to add by amount of session on finalsession
      double timePerSession = 0;
      if (hoursToAdd > 0) {
        if (idealStudyLenght == 30) {
          timePerSession = hoursToAdd * 60 / finalSessions.length;
        } else {
          timePerSession = hoursToAdd * 60 / finalSessions.length;
        }

        int fixedTime = timePerSession.ceil();

        Map sessionToTry = {};
        var allAvailable = false;
        var locked = false;
        finalSessions.forEach((session) {
          final start = session.start;
          final end = session.end;
          sessionToTry = {
            "start": start,
            "end": end.add(new Duration(minutes: fixedTime))
          };
          final response =
              isAvailableFromDevice(sessionToTry, eventsFromDevice);
          if (response == true && locked == false) {
            allAvailable = true;
          } else if (response == false) {
            allAvailable = false;
            locked = true;
          }
        });
        if (allAvailable != false) {
          finalSessions.forEach((session) {
            session.end = session.end.add(new Duration(minutes: fixedTime));
          });
        }
      } else {
        throw new Error("called add hours when no hours to add");
      }
    } catch (e) {
      throw new Error("error on add hours $e");
    }
  }

  Map tryDays(List<DateTime> daysToTry, Map session,
      List<EventFromDevice> eventsFromDevice) {
    try {
      if (daysToTry != null && session != null) {
        if (session != null) checkToday(session);
        daysToTry.sort((a, b) => b.compareTo(a));
        bool isLocked = false;
        daysToTry.forEach((day) {
          //for each available day try sweet spot first
          if (isLocked == false) {
            final Map newSession = setToSweetSpot(session, day.day);
            final backFromSweetSpot =
                addIfSweetSpot(eventsFromDevice, newSession);
            if (backFromSweetSpot == null) {
              //found a spot on sweet spot, this was already added to final session
              print(
                  "sessions allocated successfuly with the sweet spot workflow");
              isLocked = true;
            } else if (backFromSweetSpot != null) {
              final response = (nightOwl == true)
                  ? nightOwlEarlyBird(eventsFromDevice, backFromSweetSpot)
                  : earlyBirdNightOwl(eventsFromDevice, backFromSweetSpot);
              if (response == null) {
                //found a spot on night owl early bird, this session was already sent to final sessions
                print("finished on new day exit");
                isLocked = true;
              }
            }
          }
        });
        if (isLocked == true) {
          return null;
        } else {
          setToSweetSpot(session, session["start"].day);
          return session;
        }
      } else {
        throw new Error("Error on try days parameters");
      }
    } catch (e) {
      throw new Error("Error on try days $e");
    }
  }

  Future<void> accomodateSessions(
      List<Map> sessions, List<EventFromDevice> eventsFromDevice) async {
    try {
      //first try to sessions created
      int hoursToAdd = 0;
      var finished = false;

      sessions.forEach((session) {
        var result = addToFinalSessions(session, eventsFromDevice);
        if (result != null) {
          //on rejected for that session try to allocate aroun th sweet spot on same day
          Map backFromSweetSpot = addIfSweetSpot(eventsFromDevice, session);
          if (backFromSweetSpot != null) {
            //swwet spot was busy, try going later or earlier dependin on nightOwl bool
            final response = (nightOwl == true)
                ? nightOwlEarlyBird(eventsFromDevice, backFromSweetSpot)
                : earlyBirdNightOwl(eventsFromDevice, backFromSweetSpot);
            if (response != null) {
              //no more option for the same day try other days based on days between today and the test
              final extraDays = getDaysToTry(session, sessions);
              //gor each day to try sweetspot, early and night owl
              if (extraDays["daysToTry"].isNotEmpty) {
                //there are more days to try
                print("starting next day flow with $extraDays");
                List<DateTime> daysToTry = extraDays["daysToTry"];
                session = extraDays["session"];
                final response = tryDays(daysToTry, session, eventsFromDevice);
                if (response == null) {
                  print("session added");
                  finished = true;
                } else {
                  //no more options for this session, save info to add hours
                  hoursToAdd += idealStudyLenght;
                }
              } else if (extraDays["daysToTry"].isEmpty || finished != true) {
                //if there are no more days to try, we take the amount of hours for the session not allocated (this session)
                //and divide the time among all the other session
                hoursToAdd += idealStudyLenght;
                print(
                    "no more days to try adding session lenght to hoursToadd");
              }
            }
          }
        }
      });
      //once all sessions are done, check if sessions are al allocated
      print("calling create Sessions");
      if (hoursToAdd != 0) {
        addHours(finalSessions, hoursToAdd, eventsFromDevice);
      }
      await createSessions(this.finalSessions);
    } catch (e) {
      print("accomodateSessions error $e");
    }
  }
}
