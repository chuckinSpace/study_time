import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:test_device/helpers/TimeAllocation.dart';
import 'package:test_device/models/test.dart';
import 'package:test_device/screens/home/setting_form.dart';
import 'package:test_device/services/database.dart';
import 'package:provider/provider.dart';
import 'package:test_device/models/user.dart';
import "package:tutorial_coach_mark/animated_focus_light.dart";
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TestTile extends StatefulWidget {
  final Test test;

  TestTile({this.test, this.isWriting, this.index});
  final WritingCallback isWriting;
  final index;
  @override
  _TestTileState createState() => _TestTileState();
}

class _TestTileState extends State<TestTile> {
  GlobalKey showAddSession = GlobalKey();
  GlobalKey showTest = GlobalKey();
  GlobalKey showRemoveFromCalendar = GlobalKey();
  GlobalKey showDeleteTest = GlobalKey();
  List<TargetFocus> isAllocatedTutorials = List();
  List<TargetFocus> isNotAllocatedTutorials = List();
  DatabaseService firestore;
  dynamic user;
  bool isLoading = false;
  Map userSettings;

  @override
  void didChangeDependencies() async {
    try {
      user = Provider.of<User>(context);
      firestore = new DatabaseService(user.uid);
      initTargets();
      await setSettings();
    } catch (e) {
      print("error $e");
    }
    super.didChangeDependencies();
  }

  void _showAllocatedTutorial() {
    TutorialCoachMark(context,
        targets: isAllocatedTutorials,
        colorShadow: Colors.red,
        textSkip: "QUIT",
        paddingFocus: 10,
        opacityShadow: 0.8, finish: () {
      print("finish");
    }, clickTarget: (target) {
      print(target);
    }, clickSkip: () {
      print("skip");
    })
      ..show();
  }

  void _showNotAllocatedTutorial() {
    TutorialCoachMark(context,
        targets: isNotAllocatedTutorials,
        colorShadow: Colors.red,
        textSkip: "QUIT",
        paddingFocus: 10,
        opacityShadow: 0.8, finish: () {
      print("finish");
    }, clickTarget: (target) {
      print(target);
    }, clickSkip: () {
      print("skip");
    })
      ..show();
  }

  Future<void> setSettings() async {
    try {
      setState(() {
        isLoading = true;
      });
      if (user != null) {
        userSettings = await firestore.getUserSettings();
        if (userSettings != null) {
          if (this.mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print("error $e");
    }
  }

  void _showSettingsPanel() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: SettingsForm(test: widget.test),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    TimeAllocation timeAllocation = TimeAllocation(
      user?.uid,
      [],
      widget?.test?.complexity,
      testId: widget?.test?.testId,
      dueDate: widget?.test?.dueDate,
    );

    String _tileText() {
      String text;
      int daysToTest = timeAllocation.daysUntil(widget.test.dueDate);

      if (daysToTest == 0) {
        text = "Due Today!";
      } else if (daysToTest == 1) {
        text = "Due Tomorrow!";
      } else if (daysToTest < 0) {
        text = "Past Due";
      } else {
        text = "Due in $daysToTest days";
      }
      return text;
    }

    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Card(
        margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: ListTile(
            key: showTest,
            onTap: _showSettingsPanel,
            leading: widget.index == 0
                ? IconButton(
                    icon: Tooltip(
                        message: "Help with tests", child: Icon(Icons.help)),
                    onPressed: () {
                      widget.test.isAllocated
                          ? _showAllocatedTutorial()
                          : _showNotAllocatedTutorial();
                    },
                  )
                : IconButton(
                    icon: !widget.test.isAllocated
                        ? Tooltip(
                            message: "Not Allocated",
                            child: Icon(Icons.priority_high))
                        : Tooltip(
                            message: "Allocated in Calendar",
                            child: Icon(Icons.check)),
                    onPressed: () {},
                  ),
            title: AutoSizeText(
              "${widget.test.description} ${widget.test.subject}",
              maxLines: 1,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Visibility(
                  visible: !widget.test.isAllocated,
                  child: FloatingActionButton(
                      tooltip: "Add Sessions to calendar",
                      heroTag: "add${widget.test.testId}",
                      key: showAddSession,
                      onPressed: () async {
                        widget.isWriting(true);
                        await timeAllocation.calculateSessions();
                        widget.isWriting(false);
                      },
                      child: Image(
                        image: AssetImage("assets/add-event.png"),
                      ),
                      mini: true,
                      backgroundColor: Theme.of(context).accentColor),
                ),
                Visibility(
                  visible: widget.test.isAllocated,
                  child: FloatingActionButton(
                    tooltip: "Remove Sessions from Calendar",
                    key: showRemoveFromCalendar,
                    mini: true,
                    heroTag: "remove${widget.test.testId}",
                    onPressed: () async {
                      print("test allocated");
                      await firestore.deleteDeviceEvents(widget.test.testId);
                      await firestore.deleteDocumentWhere(
                          "sessions", "testId", widget.test.testId);
                      await firestore.updateDocument(
                          "tests", widget.test.testId, {"isAllocated": false});
                    },
                    backgroundColor: Theme.of(context).accentColor,
                    child: Image(
                      image: AssetImage("assets/delete-event.png"),
                    ),
                  ),
                ),
                Visibility(
                  visible: !widget.test.isAllocated,
                  child: FloatingActionButton(
                      heroTag: "delete${widget.test.testId}",
                      tooltip: "Delete test",
                      key: showDeleteTest,
                      onPressed: () async {
                        // delete sessions
                        await firestore.deleteDocumentWhere(
                            "sessions", "testId", widget.test.testId);
                        //delete test event from device
                        await firestore.deleteDeviceTests(widget.test.testId);
                        // delete test
                        await firestore.deleteDocument(widget.test.testId);
                      },
                      child: Icon(Icons.delete),
                      foregroundColor: Colors.white,
                      mini: true,
                      backgroundColor: Colors.red),
                ),
              ],
            ),
            subtitle: Text(_tileText())),
      ),
    );
  }

  void initTargets() {
    isAllocatedTutorials.add(TargetFocus(
      identify: "Remove Sessions",
      keyTarget: showRemoveFromCalendar,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Sessions Created!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Your sessions were created! go check your device's calendar or the Calendar here,also if you click here you can delete those sessions from your calendar",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
    isNotAllocatedTutorials.add(TargetFocus(
      identify: "Test",
      keyTarget: showTest,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Test",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "This is your test created, here you can add and delete the study sessions for this test from your calendars",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));

    isNotAllocatedTutorials.add(TargetFocus(
      identify: "Add Sessions",
      keyTarget: showAddSession,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Add Sessions",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Add your sessions for this test to your calendar",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
    isNotAllocatedTutorials.add(TargetFocus(
      identify: "Delete test",
      keyTarget: showDeleteTest,
      contents: [
        ContentTarget(
            align: AlignContent.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Delete Test",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "This will delete you test completly",
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

typedef WritingCallback = void Function(bool isWriting);
