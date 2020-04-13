import 'package:auto_size_text/auto_size_text.dart';
import "package:flutter/material.dart";
import 'package:test_device/helpers/TimeAllocation.dart';
import 'package:test_device/models/event_from_device.dart';
import 'package:test_device/screens/authenticate/authenticate.dart';
import 'package:test_device/services/auth.dart';
import 'package:test_device/services/database.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'package:test_device/models/user.dart';
import "package:tutorial_coach_mark/animated_focus_light.dart";
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  GlobalKey _showCalendarToUse = GlobalKey();
  GlobalKey _showCutOff = GlobalKey();
  GlobalKey _showSweet = GlobalKey();
  GlobalKey _showNightOwl = GlobalKey();
  TimeAllocation time;
  DatabaseService database;
  var isLoading = false;
  List<TargetFocus> targets = List();
  int _morningValue = 0;
  int _nightValue = 1;
  int _sweetStart = 0;
  int _sweetEnd = 1;
  bool _nightOwl = true;
  String _calendarToUse = "";
  String _calendarToUseName = "";
  List<Map> _calendars = [];
  List<Map<String, bool>> calendarsSelected = [];
  bool isCalendarId = false;
  String _textForCalendars = "";
  bool isConfigured = false;
  bool useForWeekends = true;
  Authenticate authenticate = Authenticate();
  final device = new EventFromDevice();
  ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    initTargets();
    _scrollController = new ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
  }

  Future<void> _toTop() async {
    await _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    return;
  }

  didChangeDependencies() async {
    super.didChangeDependencies();
    final user = Provider.of<User>(context);
    if (user != null) {
      database = new DatabaseService(user.uid);

      setState(() {
        isLoading = true;
      });
      _calendars = await device.retrieveCalendars();
      await _setUserSettings(user.uid);

      setState(() {
        isLoading = false;
      });
    }
  }

  void _showTutorial() async {
    await _toTop();
    TutorialCoachMark(context,
        targets: targets,
        colorShadow: Colors.red,
        textSkip: "QUIT",
        paddingFocus: 10,
        opacityShadow: 1, finish: () {
      print("finish");
    }, clickTarget: (target) {
      print(target);
    }, clickSkip: () {
      print("skip");
    })
      ..show();
  }

  bool _searchGoogle(String stringToSearch) {
    return stringToSearch.contains("gmail");
  }

  Map _setCalendar(_calendars) {
    Map calendarToReturn = {};
    _calendars.forEach((calendar) {
      if (_searchGoogle(calendar["name"])) {
        calendar["inUse"] = true;
        calendarToReturn = {
          "calendarToUse": calendar["id"],
          "calendarToUseName": calendar["name"]
        };
      }
    });
    return calendarToReturn;
  }

  Future _setUserSettings(String uid) async {
    setState(() {
      isLoading = true;
    });
    final user = await database.getUserSettings();

    if (user != null) {
      setState(() {
        _morningValue = user["morning"];
        _nightValue = user["night"];
        _sweetStart = user["sweetSpotStart"];
        _sweetEnd = user["sweetSpotEnd"];
        _nightOwl = user["nightOwl"];

        isConfigured = user["isConfigured"];
        if (isCalendarId == true && _calendars.isNotEmpty) {
          _textForCalendars = "Choose your Calendar";
        } else if (isCalendarId == false && _calendars.isNotEmpty) {
          _textForCalendars = "Choose your Calendar *";
        } else {
          _textForCalendars = "No Calendars Found on this Device";
        }
      });
      Map calendarToSet = _setCalendar(_calendars);
      if (!isConfigured && calendarToSet.isNotEmpty) {
        setState(() {
          _calendarToUse = calendarToSet["calendarToUse"];
          _calendarToUseName = calendarToSet["calendarToUseName"];
          isCalendarId = true;
        });
      } else {
        setState(() {
          _calendarToUse = user["calendarToUse"];
          _calendarToUseName = user["calendarToUseName"];
          isCalendarId = _calendarToUse != "";
        });
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  void _setNightOwl(bool value) {
    print("value $value");
    setState(() {
      _nightOwl = value;
    });
  }

  void _showMorning() {
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: 1,
            maxValue: 22,
            title: new Text("Pick your morning cut off"),
            initialIntegerValue: 1,
          );
        }).then((int value) {
      if (value != null) {
        setState(() {
          _morningValue = value;
        });
      }
    });
  }

  void _showNight() {
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: _morningValue + 1,
            maxValue: 23,
            title: new Text("Select your night cut off"),
            initialIntegerValue: _morningValue + 1,
          );
        }).then((int value) {
      if (value != null) {
        setState(() {
          _nightValue = value;
        });
      }
    });
  }

  void _showSweetStart() {
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: 1,
            maxValue: _sweetEnd - 1,
            title: new Text("Select your sweet spot Start"),
            initialIntegerValue: _sweetStart + 1,
          );
        }).then((int value) {
      if (value != null) {
        setState(() {
          _sweetStart = value;
        });
      }
    });
  }

  void _showSweetEnd() {
    showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return new NumberPickerDialog.integer(
            minValue: _sweetStart + 1,
            maxValue: 23,
            title: new Text("Select your sweet spot End"),
            initialIntegerValue: _sweetStart + 1,
          );
        }).then((int value) {
      if (value != null) {
        setState(() {
          _sweetEnd = value;
        });
      }
    });
  }

  Future<void> _saveUserSettings(uid) async {
    final objToSend = {
      "sweetSpotStart": _sweetStart,
      "sweetSpotEnd": _sweetEnd,
      "nightOwl": _nightOwl,
      "morning": _morningValue,
      "night": _nightValue,
      "calendarToUse": _calendarToUse,
      "calendarToUseName": _calendarToUseName,
      "isConfigured": true,
    };
    await database.updateDocument("users", uid, objToSend);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return new Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () {
                _showTutorial();
              },
              icon: Tooltip(
                message: "Show Settings Tutorial",
                child: Icon(
                  Icons.help,
                ),
              ),
            )
          ],
          title: Text("Settings"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: isLoading == true
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Center(
                        child: SizedBox(
                          child: CircularProgressIndicator(),
                          height: 200,
                          width: 200,
                        ),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        key: _showCutOff,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Cut Off times",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 10),
                          Text(
                            "Morning cut off :",
                            style: TextStyle(fontSize: 15),
                          ),
                          FlatButton(
                            splashColor: Colors.blueGrey,
                            onPressed: _showMorning,
                            child: Text(
                              _morningValue.toString(),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            _morningValue < 12 ? "AM" : "PM",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _morningValue != 0
                          ? Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                Text(
                                  "Night cut off :",
                                  style: TextStyle(fontSize: 15),
                                ),
                                SizedBox(width: 20),
                                _morningValue != 1
                                    ? FlatButton(
                                        onPressed: _showNight,
                                        child: Text(
                                          _nightValue.toString(),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      )
                                    : null,
                                Text(
                                  _nightValue < 12 ? "AM" : "PM",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            )
                          : Text(
                              "Set morning first",
                              style: TextStyle(fontSize: 15),
                            ),
                      SizedBox(height: 10),
                      Row(
                        key: _showSweet,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Sweet Spot",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          SizedBox(width: 10),
                          Text(
                            "Start :",
                            style: TextStyle(fontSize: 15),
                          ),
                          FlatButton(
                            splashColor: Colors.blueGrey,
                            onPressed: _showSweetStart,
                            child: Text(
                              _sweetStart.toString(),
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            _sweetStart < 12 ? "AM" : "PM",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      _sweetStart != 0
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(width: 10),
                                Text(
                                  "End :",
                                  style: TextStyle(fontSize: 15),
                                ),
                                SizedBox(width: 10),
                                _sweetStart != 1
                                    ? FlatButton(
                                        onPressed: _showSweetEnd,
                                        child: Text(
                                          _sweetEnd.toString(),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      )
                                    : null,
                                Text(
                                  _sweetEnd < 12 ? "AM" : "PM",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            )
                          : Text(
                              "Set Start first",
                              style: TextStyle(fontSize: 15),
                            ),
                      SizedBox(height: 10),
                      Row(
                        key: _showNightOwl,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Prefer Morning or Night study?",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(width: 10),
                          Text("Night Owl", style: TextStyle(fontSize: 15)),
                          Checkbox(value: _nightOwl, onChanged: _setNightOwl),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          AutoSizeText(
                            _textForCalendars,
                            key: _showCalendarToUse,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 20,
                                color: isCalendarId == false
                                    ? Colors.red
                                    : Colors.black),
                          ),
                          isCalendarId == true
                              ? FlatButton.icon(
                                  onPressed: () {
                                    _calendars.forEach((calendar) {
                                      calendar["inUse"] = false;
                                    });
                                    setState(() {
                                      isCalendarId = false;
                                    });
                                  },
                                  icon: Icon(Icons.edit),
                                  label: Text(""))
                              : Text(""),
                        ],
                      ),
                      isCalendarId == false
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: _calendars?.length ?? 0,
                              itemBuilder: (BuildContext context, int index) {
                                if (_calendars.isEmpty || _calendars == null) {
                                  return AutoSizeText(
                                      "I could not retrieve your calendars,please check your system settings");
                                } else {
                                  return CheckboxListTile(
                                      title:
                                          Text(_calendars[index]["name"] ?? ""),
                                      value: _calendars[index]["inUse"] ?? "",
                                      onChanged: (bool newValue) {
                                        setState(() {
                                          _calendars[index]["inUse"] = newValue;
                                          _calendarToUse =
                                              _calendars[index]["id"];
                                          _calendarToUseName =
                                              _calendars[index]["name"];
                                          isCalendarId = true;
                                        });
                                      });
                                }
                              })
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(height: 40.0),
                                AutoSizeText(
                                  "   I am using : $_calendarToUseName",
                                  style: TextStyle(fontSize: 15),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                      FlatButton.icon(
                        onPressed: () async {
                          AuthService _auth = new AuthService();
                          await _auth.signOut();
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.exit_to_app),
                        textColor: Colors.red,
                        label: Tooltip(
                          message: "Sign Out",
                          child:
                              Text("Sign Out", style: TextStyle(fontSize: 10)),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        floatingActionButton: isLoading == false && _calendarToUse != ""
            ? Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: FloatingActionButton(
                  tooltip: "Save Preferences",
                  onPressed: () async {
                    await _saveUserSettings(user?.uid);
                    Navigator.pop(
                      context,
                      false,
                    );
                  },
                  backgroundColor: isConfigured == false
                      ? Colors.red
                      : Theme.of(context).buttonColor,
                  child: Icon(Icons.save),
                ),
              )
            : Text(""),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop);
  }

  void initTargets() {
    targets.add(TargetFocus(
      identify: "Cut Off Times",
      keyTarget: _showCutOff,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Cut Off Times",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Study Planner will not accomodate any sessions before morning Cut off or after Night Cut off, usually used for bed time.\nHint: \nYou can use the morning cut off to take your classes into account!\nExample: Your classes end every day around 4pm, set the morning cut off to 4pm",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    targets.add(TargetFocus(
      identify: "Sweet Spot",
      keyTarget: _showSweet,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Sweet Spot",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Set the perfect time for you to study, Study Planner will always try to set up sessions during these times as the first option.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Night Owl",
      keyTarget: _showNightOwl,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Night Owl",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Select if you would rather have sessions later in the day (Night Owl). \nAfter Study Planner tried to allocate on the sweet spot, it will try later in the night if this option is active, otherwise will try earlier in the morning.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
    targets.add(TargetFocus(
      identify: "Calendars",
      keyTarget: _showCalendarToUse,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Calendars",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "The most important part, select here, wich one is the calendar that you use, the list showing here are your device's current calendars. Study Planner will retrieve events from the calendar selected to check for availability,and also will write the tests and sessions created.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
  }
}
