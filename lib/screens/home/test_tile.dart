import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:test_device/helpers/TimeAllocation.dart';
import 'package:test_device/models/test.dart';
import 'package:test_device/screens/home/setting_form.dart';
import 'package:test_device/services/database.dart';
import 'package:provider/provider.dart';
import 'package:test_device/models/user.dart';
/* import "package:tutorial_coach_mark/animated_focus_light.dart";
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart'; */

// ignore: must_be_immutable
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
  GlobalKey showRemoveFromCalendar = GlobalKey();
  GlobalKey showDeleteTest = GlobalKey();
  /*  List<TargetFocus> targets = List(); */
  DatabaseService firestore;
  dynamic user;
  bool isLoading = false;
  Map userSettings;
  bool isTestTutorialSeen = false;
  @override
  void didChangeDependencies() async {
    try {
      user = Provider.of<User>(context);
      firestore = new DatabaseService(user.uid);
      await setSettings();
      if (isTestTutorialSeen == true) {
        /*  _showTutorial(); */
      }
    } catch (e) {
      print("error $e");
    }
    super.didChangeDependencies();
  }

  /* void _showTutorial() {
    TutorialCoachMark(context,
        targets: targets,
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
  } */

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
              isTestTutorialSeen = userSettings["isTestTutorialSeen"];
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
      testId: widget?.test?.testId,
      complexity: widget?.test?.complexity,
      dueDate: widget?.test?.dueDate,
      finalSessions: [],
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
            onTap: _showSettingsPanel,
            leading: widget.index == 0
                ? IconButton(
                    icon: Icon(Icons.help),
                    onPressed: () {
                      if (!widget.test.isAllocated) {
                        /*   ShowCaseWidget.of(context)
                            .startShowCase([showAddSession, showDeleteTest]); */
                      } else {
                        /*   ShowCaseWidget.of(context)
                            .startShowCase([showRemoveFromCalendar]); */
                      }
                    },
                  )
                : IconButton(
                    icon: !widget.test.isAllocated
                        ? Icon(Icons.priority_high)
                        : Icon(Icons.check),
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
                      backgroundColor: Colors.blue),
                ),
                Visibility(
                  visible: widget.test.isAllocated,
                  child: FloatingActionButton(
                    tooltip: "Remove Sessions from Calendar",
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
                    child: Image(
                      image: AssetImage("assets/delete-event.png"),
                    ),
                  ),
                ),
                Visibility(
                  visible: !widget.test.isAllocated,
                  child: FloatingActionButton(
                      heroTag: "delete${widget.test.testId}",
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
                      mini: true,
                      backgroundColor: Colors.red),
                ),
              ],
            ),
            subtitle: Text(_tileText())),
      ),
    );
  }

  /* void initTargets() {
    targets.add(TargetFocus(
      identify: "Show Calendar",
      keyTarget: showAddSession,
      contents: [
        ContentTarget(
            align: AlignContent.top,
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
                      "The best times for your sessions are already created, just click here to add them to you calendar",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.RRect,
    ));
  } */
}

typedef WritingCallback = void Function(bool isWriting);
