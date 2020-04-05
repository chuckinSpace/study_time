import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:test_device/helpers/TimeAllocation.dart';
import 'package:test_device/models/test.dart';
import 'package:test_device/models/user.dart';
import 'package:test_device/services/database.dart';
import "package:test_device/shared/constants.dart";
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test_device/shared/loading.dart';

class SettingsForm extends StatefulWidget {
  final Test test;
  SettingsForm({this.test});
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  FocusNode myFocusNode = new FocusNode();

  String _currentSubject;
  int _currentComplexity = 1;
  int _currentImportance = 1;
  String _currentDescription = "";
  DateTime _currentDueDate =
      DateTime.now().add(new Duration(days: 1)).add(new Duration(hours: 1));

  String _parsedDueDate = "";

  bool isLoading = false;

  @override
  void didChangeDependencies() {
    if (widget.test != null) {
      setState(() {
        _currentSubject = widget.test.subject;
        _currentComplexity = widget.test.complexity;
        _currentImportance = widget.test.importance;
        _currentDescription = widget.test.description;
        final dueDateParse =
            new DateFormat("MMMM, d H:mm").format(widget.test.dueDate);
        _parsedDueDate = dueDateParse;
      });
    }
    super.didChangeDependencies();
  }

  void _showDateTimePicker() async {
    final dueDateParse = new DateFormat("MMMM, d H:mm").format(_currentDueDate);
    _parsedDueDate = dueDateParse;

    DatePicker.showDatePicker(
      context,

      minDateTime:
          DateTime.now().add(new Duration(days: 1)).add(new Duration(hours: 1)),
      initialDateTime: widget.test?.start ??
          DateTime.now().add(new Duration(days: 1)).add(new Duration(hours: 1)),
      dateFormat: 'MMM dd EEE H mm',

      pickerMode: DateTimePickerMode.datetime, // show TimePicker
      onCancel: () {
        debugPrint('onCancel');
      },
      onChange: (dateTime, List<int> index) {
        setState(() {
          print(dateTime);
          _parsedDueDate = new DateFormat("MMMM,EEEE d ").format(dateTime);
        });
      },
      onConfirm: (dateTime, List<int> index) {
        print("here $_currentDueDate");
        setState(() {
          _currentDueDate = dateTime;
        });
      },
    );
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    myFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: isLoading
            ? Container(child: Center(child: Loading()))
            : Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Flexible(
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          initialValue: widget.test?.subject ?? "",
                          decoration: textInputDecoration.copyWith(
                              hintText: "Course Code"),
                          validator: (val) =>
                              val.isEmpty ? "Please enter subject" : null,
                          onChanged: (val) =>
                              setState(() => _currentSubject = val),
                        ),
                      ),
                      SizedBox(width: 10),
                      new Flexible(
                        child: TextFormField(
                          onEditingComplete: () => myFocusNode.requestFocus(),
                          initialValue: widget.test?.description ?? "",
                          decoration: textInputDecoration.copyWith(
                              hintText: "Description"),
                          validator: (val) =>
                              val.isEmpty ? "Please enter description" : null,
                          onChanged: (val) {
                            setState(() => _currentDescription = val);
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  Visibility(
                    visible: widget.test == null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        FloatingActionButton(
                          focusNode: myFocusNode,
                          heroTag: "test calendar",
                          onPressed: _showDateTimePicker,
                          tooltip: 'Due Date',
                          child: Icon(Icons.calendar_today),
                          foregroundColor: Colors.white,
                          backgroundColor: _parsedDueDate == ""
                              ? Theme.of(context).accentColor
                              : Theme.of(context).buttonColor,
                          elevation: 0,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Due Date :",
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                        Text(
                          _parsedDueDate == ""
                              ? " Pick a Date"
                              : " $_parsedDueDate",
                          style: TextStyle(
                              color: _parsedDueDate == ""
                                  ? Colors.red
                                  : Colors.black,
                              fontSize: _parsedDueDate == "" ? 16 : 15),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Complexity"),
                  Slider(
                    value: _currentComplexity.toDouble(),
                    activeColor: Colors.red[_currentComplexity * 100 ?? 0],
                    inactiveColor: Colors.red[_currentComplexity * 100 ?? 0],
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (val) => setState(
                      () => _currentComplexity = val.round(),
                    ),
                  ),
                  Text("Importance"),
                  Slider(
                    value: _currentImportance.toDouble(),
                    activeColor: Colors.blue[_currentImportance * 100 ?? 0],
                    inactiveColor: Colors.blue[_currentImportance * 100 ?? 0],
                    min: 1,
                    max: 5,
                    divisions: 4,
                    onChanged: (val) => setState(
                      () => _currentImportance = val.round(),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel"),
                        color: Theme.of(context).accentColor,
                      ),
                      Visibility(
                        visible: _parsedDueDate != "",
                        child: RaisedButton(
                            child: Text(widget.test != null
                                ? "Update Test"
                                : "Add Test"),
                            onPressed: () async {
                              if (_formKey.currentState.validate() &&
                                  _parsedDueDate != "" &&
                                  isLoading == false) {
                                if (widget.test == null) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  final testId = await DatabaseService(user.uid)
                                      .createNewTest(
                                          _currentSubject ?? "",
                                          _currentComplexity ?? 0,
                                          _currentImportance ?? 0,
                                          _currentDescription ?? "",
                                          _currentDueDate,
                                          user.uid);
                                  await TimeAllocation(
                                          user.uid, [], _currentComplexity,
                                          dueDate: _currentDueDate,
                                          testId: testId)
                                      .calculateSessions();
                                  if (this.mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.pop(context);
                                  }
                                } else {
                                  if (isLoading == false) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await DatabaseService(user.uid)
                                        .updateDocument(
                                            "tests", widget.test.testId, {
                                      "subject": _currentSubject ?? "",
                                      "complexity": _currentComplexity ?? 0,
                                      "importance": _currentImportance ?? 0,
                                      "description": _currentDescription ?? "",
                                      "user": user.uid
                                    });
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.pop(context);
                                  }
                                }
                              }
                            }),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
