import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:test_device/models/test.dart';
import 'package:test_device/screens/home/test_tile.dart';
import 'package:provider/provider.dart';

class TestList extends StatefulWidget {
  @override
  _TestListState createState() => _TestListState();
}

class _TestListState extends State<TestList> {
  bool isWriting = false;

  void toggleIsWriting(bool value) {
    if (this.mounted) {
      setState(() {
        isWriting = !isWriting;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Test> tests = Provider.of<List<Test>>(context);

    if (isWriting == true) {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 250.0,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      child: new CircularProgressIndicator(),
                    ),
                  ),
                  Center(child: Text("Adding sessions to your Calendar")),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return tests?.isEmpty == true
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AutoSizeText(
                  "Please add your first test",
                  maxLines: 1,
                  style: TextStyle(fontSize: 30),
                ),
              ],
            ))
          : ListView.builder(
              itemCount: tests == null ? 0 : tests?.length,
              itemBuilder: (context, index) {
                return TestTile(
                    test: tests[index] ?? "",
                    isWriting: toggleIsWriting,
                    index: index);
              },
            );
    }
  }
}
