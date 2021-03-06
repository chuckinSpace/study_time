import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:test_device/models/event_from_device.dart';
import 'package:test_device/models/test.dart';
import 'package:test_device/screens/home/welcome.dart';
import 'package:test_device/models/user.dart';
import 'package:test_device/screens/calendar/calendar.dart';
import 'package:test_device/screens/home/test_list.dart';
import 'package:test_device/screens/home/setting_form.dart';
import 'package:test_device/screens/settings/settings.dart';
import 'package:test_device/services/database.dart';
import 'package:provider/provider.dart';
import 'package:test_device/shared/loading.dart';
import 'package:tutorial_coach_mark/animated_focus_light.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

const String testDevice = "";

class Home extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  Home({
    this.analytics,
    this.observer,
  });

  @override
  _HomeState createState() => _HomeState(analytics, observer);
}

class _HomeState extends State<Home> {
  bool isWriting = false;

  void toggleIsWriting(bool value) {
    if (this.mounted) {
      setState(() {
        print("fired on home with $value");
        isWriting = !isWriting;
      });
    }
  }

  _HomeState(this.analytics, this.observer);
  GlobalKey _testKey = GlobalKey();
  GlobalKey _calendarKey = GlobalKey();
  GlobalKey _settingsKey = GlobalKey();
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  final EventFromDevice device = new EventFromDevice();

  DatabaseService database;
  bool isConfigured = false;
  Map userSettings;

  bool firstShow = false;
  dynamic user;
  bool isLoading = false;
  List<TargetFocus> targets = List();
  List<TargetFocus> settings = List();
  bool isWelcomeScreenSeen = false;

  bool showHomeBool = false;

  @override
  void initState() {
    super.initState();
    initTargets();
  }

  didChangeDependencies() async {
    await analytics.logEvent(name: "Home");
    super.didChangeDependencies();
    try {
      user = Provider.of<User>(context, listen: false);
      if (user != null && this.mounted) {
        database = new DatabaseService(user.uid);
        await setSettings();
      }
    } catch (e) {
      print("error $e");
    }
  }

  Future<void> setTutorialSeen() async {
    try {
      await Firestore.instance
          .collection("users")
          .document(user.uid)
          .updateData({"isWelcomeScreenSeen": true});
    } catch (e) {
      print("error in tutorial seen $e");
    }
  }

  void showTutorial() async {
    await analytics.logTutorialBegin();

    TutorialCoachMark(context,
        targets: targets,
        colorShadow: Colors.red,
        textSkip: "QUIT",
        paddingFocus: 10,
        opacityShadow: 0.8, finish: () async {
      await analytics.logTutorialComplete();
    }, clickTarget: (target) {
      print(target);
    }, clickSkip: () async {
      await analytics.logEvent(name: "Main_Tutorial_Skipped");
    })
      ..show();
  }

  void showSettings() async {
    await analytics.logEvent(name: "Settings_Warning_from_Home");
    TutorialCoachMark(context,
        targets: settings,
        colorShadow: Colors.red,
        textSkip: "QUIT",
        paddingFocus: 10,
        opacityShadow: 0.9,
        finish: () async {}, clickTarget: (target) {
      print(target);
    }, clickSkip: () async {})
      ..show();
  }

  Future<void> setSettings() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (user != null) {
        userSettings = await database.getUserSettings();
        if (userSettings != null) {
          setState(() {
            isConfigured = userSettings["isConfigured"];
            isWelcomeScreenSeen = userSettings["isWelcomeScreenSeen"] ?? false;
          });
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("error $e");
    }
  }

  void showHome() {
    if (this.mounted) {
      setState(() {
        showHomeBool = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    void _showSettingsPanel() async {
      if (isConfigured == false) {
        showSettings();
      } else {
        await analytics.logEvent(name: "Open_Add_test_modal");
        showModalBottomSheet(
            isDismissible: false,
            context: context,
            builder: (context) {
              return SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      child: SettingsForm(),
                    ),
                  ],
                ),
              );
            });
      }
    }

    return MultiProvider(
      providers: [
        StreamProvider<List<Test>>.value(
          value: DatabaseService(user?.uid).tests,
        ),
      ],
      child: isLoading
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      child: Loading(),
                    ),
                  ),
                ],
              ),
            )
          : Scaffold(
              appBar: AppBar(
                title: Text("Study Planner",
                    style: Theme.of(context).textTheme.title),
                elevation: 0,
                actions: <Widget>[
                  Visibility(
                    visible:
                        isWelcomeScreenSeen == false && showHomeBool == true,
                    child: IconButton(
                      onPressed: () async {
                        await setTutorialSeen();
                        setState(() {
                          isWelcomeScreenSeen = true;
                        });
                        showTutorial();
                      },
                      icon: Tooltip(
                        message: "Home Screen",
                        child: Icon(
                          Icons.home,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isWelcomeScreenSeen == true,
                    key: _settingsKey,
                    child: IconButton(
                      onPressed: () async {
                        await analytics.logEvent(name: "Go_to_settings");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Settings()),
                        );
                      },
                      icon: Tooltip(
                        message: "Go To Settings",
                        child: Icon(
                          Icons.settings,
                          color:
                              isConfigured == false ? Colors.red : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isWelcomeScreenSeen == true,
                    child: IconButton(
                      onPressed: () {
                        showTutorial();
                      },
                      icon: Tooltip(
                        message: "Show Tutorial",
                        child: Icon(
                          Icons.help,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: isWelcomeScreenSeen == false
                  ? WelcomeScreen(uid: user?.uid, showHome: showHome)
                  : Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor),
                      child: TestList(
                        isWriting: toggleIsWriting,
                      ),
                    ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Visibility(
                      visible:
                          isWelcomeScreenSeen == true && isWriting == false,
                      child: FloatingActionButton(
                        tooltip: "Show Calendar",
                        heroTag: "calendar",
                        key: _calendarKey,
                        onPressed: () async {
                          if (isConfigured == false) {
                            showSettings();
                          } else {
                            await analytics.logEvent(name: "Go_to_Calendar");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Calendar()),
                            );
                          }
                        },
                        child: Icon(
                          Icons.calendar_today,
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    Visibility(
                      visible:
                          isWelcomeScreenSeen == true && isWriting == false,
                      child: FloatingActionButton(
                        tooltip: "Add New Test",
                        key: _testKey,
                        heroTag: "add",
                        onPressed: _showSettingsPanel,
                        child: Icon(
                          Icons.add,
                        ),
                        backgroundColor: Theme.of(context).accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void initTargets() {
    targets.add(TargetFocus(
      identify: "Show Calendar",
      keyTarget: _calendarKey,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Show Calendar",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "You can use this calendar, or your device's. They will be in sync, all your tests and study sessions will be there",
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
      identify: "Add Test",
      keyTarget: _testKey,
      contents: [
        ContentTarget(
            align: AlignContent.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Add Test",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Add a new test, It will be added to your device's calendar also",
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
      identify: "Settings",
      keyTarget: _settingsKey,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Settings",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Use you settings to define what Calendar should we use to write and read events, set you best times to study, cut offs and more",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
    settings.add(TargetFocus(
      identify: "Settings_mandatory",
      keyTarget: _settingsKey,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Settings",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Before we Start please select what Calendar should we use here",
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
