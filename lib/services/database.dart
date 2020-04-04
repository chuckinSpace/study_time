import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test_device/models/event_from_device.dart';
import 'package:test_device/models/session.dart';
import 'package:test_device/models/test.dart';
import 'package:test_device/models/user.dart';

class DatabaseService {
  final String uid;

  DatabaseService(this.uid);

  // collection Reference

  final CollectionReference testCollection =
      Firestore.instance.collection("tests");

  final CollectionReference userCollection =
      Firestore.instance.collection("users");

  final CollectionReference sessionsCollection =
      Firestore.instance.collection("sessions");

  // collection methods
  Future<Map> getUserSettings() async {
    try {
      final response = await userCollection.document(uid).get();
      final data = response.data;
      if (data != null) {
        final userInfo = {
          "morning": data["morning"] ?? 0,
          "night": data["night"] ?? 0,
          "nightOwl": data["nightOwl"] ?? false,
          "sweetSpotStart": data["sweetSpotStart"] ?? 0,
          "sweetSpotEnd": data["sweetSpotEnd"] ?? 0,
          "calendarToUse": data["calendarToUse"] ?? "",
          "calendarToUseName": data["calendarToUseName"] ?? "",
          "isConfigured": data["isConfigured"] ?? false,
          "isWelcomeScreenSeen": data["isWelcomeScreenSeen"] ?? false,
        };
        return userInfo;
      } else {
        return null;
      }
    } catch (e) {
      print("error  get user settings $e");
      return null;
    }
  }

  Future updateUserData(String subject, int complexity, int importance,
      String description, DateTime dueDate, String uid) async {
    try {
      return await testCollection.document(uid).setData({
        "complexity": complexity,
        "subject": subject,
        "user": uid,
        "importance": importance,
        "description": description,
        "dueDate": dueDate,
      });
    } catch (e) {
      print("error update user date $e");
    }
  }

  Future createUserDocument(
    String email,
  ) async {
    try {
      final user = await userCollection.document(uid).get();
      if (user.exists == false) {
        await userCollection.document(uid).setData({
          "email": email,
          "isConfigured": false,
          "morning": 7,
          "night": 23,
          "nightOwl": true,
          "sweetSpotStart": 18,
          "sweetSpotEnd": 23,
          "calendarToUse": "",
          "calendarToUseName": "",
          "isWelcomeScreenSeen": false,
        });
      }
    } catch (e) {
      print("error creting new user document $e");
    }
  }

  Future deleteDocument(
    String docId,
  ) async {
    try {
      await testCollection.document(docId).delete();
    } catch (e) {
      print("error deleting $e");
    }
  }

  Future deleteDocumentWhere(
      String collection, String whereParam, String isEqualToParam) async {
    try {
      print("in delete document where");
      final results = await Firestore.instance
          .collection(collection)
          .where(whereParam, isEqualTo: isEqualToParam)
          .getDocuments();

      results.documents.forEach((doc) async => await doc.reference.delete());
    } catch (e) {
      print("error deleting $e");
    }
  }

  Future updateDocument(
      String collection, String docId, Map<String, dynamic> obj) async {
    try {
      print(" $collection,$docId,$obj");
      await Firestore.instance
          .collection(collection)
          .document(docId)
          .updateData(obj);
      print("in update");
    } catch (e) {
      print(e);
    }
  }

  Future updateDocumentWhere(String collection, String whereParam,
      String isEqualToParam, Map<String, dynamic> obj) async {
    try {
      final results = await Firestore.instance
          .collection(collection)
          .where(whereParam, isEqualTo: isEqualToParam)
          .getDocuments();
      results.documents
          .forEach((doc) async => await doc.reference.updateData(obj));
    } catch (e) {
      print("error on updateDocs where $e");
    }
  }

  Future<String> createNewTest(String subject, int complexity, int importance,
      String description, DateTime dueDate, String uid) async {
    EventFromDevice eventFromDevice = EventFromDevice();
    try {
      final userSettings = await getUserSettings();
      final test = {
        "complexity": complexity,
        "subject": subject,
        "user": uid,
        "importance": importance,
        "description": description,
        "dueDate": dueDate,
        "isAllocated": false,
        "start": dueDate,
        "end": dueDate.add(new Duration(hours: 2)),
        "calendarToUse": userSettings["calendarToUse"]
      };
      // add test
      final testCreated = await testCollection.add(test);
      //add testId as property on the test itself
      final testSnap =
          await testCollection.document(testCreated.documentID).get();

      final backTest = testSnap.data;
      final testForDevice = {
        "complexity": backTest["complexity"],
        "subject": backTest["subject"],
        "user": backTest["user"],
        "importance": backTest["importance"],
        "description": backTest["description"],
        "dueDate": backTest["dueDate"].toDate(),
        "isAllocated": backTest["isAllocated"],
        "start": backTest["dueDate"].toDate(),
        "end": backTest["end"].toDate(),
        "testId": testSnap.documentID
      };
      final calendarEventId = await eventFromDevice.createDeviceEvent(
          userSettings["calendarToUse"], testForDevice);
      if (testCreated != null) {
        await testCollection
            .document(testCreated.documentID)
            .updateData({"calendarEventId": calendarEventId});
      }
      return testCreated.documentID;
    } catch (e) {
      print("error on create New test $e");
      return "";
    }
  }

  Future createSessions(
    String uid,
    String testId,
    int sessionNumber,
    DateTime start,
    DateTime end,
  ) async {
    EventFromDevice eventFromDevice = EventFromDevice();
    try {
      final userSettings = await getUserSettings();
      final event = {
        "testId": testId,
        "sessionNumber": sessionNumber,
        "uid": uid,
        "start": start,
        "end": end,
        "calendarToUse": userSettings["calendarToUse"]
      };

      final response = await sessionsCollection.add(event);
      final calendarEventId = await eventFromDevice.createDeviceEvent(
          userSettings["calendarToUse"], event);

      if (response != null) {
        await sessionsCollection
            .document(response.documentID)
            .updateData({"calendarEventId": calendarEventId});
        await testCollection.document(testId).updateData({"isAllocated": true});
      }
    } catch (e) {
      print(e);
    }
  }

  // test list from snapshot
  List<Test> _testListFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.documents.map((doc) {
        return Test(
            subject: doc.data["subject"] ?? "",
            complexity: doc.data["complexity"] ?? 0,
            importance: doc.data["importance"] ?? 0,
            description: doc.data["description"] ?? "",
            dueDate: doc.data["dueDate"].toDate() ?? "",
            testId: doc.documentID,
            isAllocated: doc.data["isAllocated"] ?? false,
            calendarEventId: doc.data["calendarEventId"] ?? "",
            calendarToUse: doc.data["calendarToUse"] ?? "",
            start: doc.data["start"].toDate() ?? "",
            end: doc.data["end"].toDate() ?? "");
      }).toList();
    } catch (e) {
      print("error on _tests from spanoshot $e");
      return [];
    }
  }

  Future<List<Test>> getTestsByUser(String uid) async {
    try {
      QuerySnapshot result =
          await testCollection.where("user", isEqualTo: uid).getDocuments();
      final tests = _testListFromSnapshot(result);
      return tests;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> deleteDeviceEvents(testId) async {
    EventFromDevice eventFromDevice = EventFromDevice();
    try {
      final result = await Firestore.instance
          .collection("sessions")
          .where("testId", isEqualTo: testId)
          .getDocuments();

      if (result.documents.isNotEmpty) {
        result.documents.forEach((doc) async {
          //call delete device event with doc.calendarEventId
          eventFromDevice.deleteCalendarEvent(
              doc.data["calendarToUse"], doc.data["calendarEventId"]);
        });
      } else {
        print("no calendar ids found");
      }
    } catch (e) {
      print("error when deleting from device");
    }
  }

  Future<void> deleteDeviceTests(testId) async {
    EventFromDevice eventFromDevice = EventFromDevice();
    try {
      final result =
          await Firestore.instance.collection("tests").document(testId).get();

      if (result.exists) {
        //call delete device event with doc.calendarEventId
        eventFromDevice.deleteCalendarEvent(
            result.data["calendarToUse"], result.data["calendarEventId"]);
      } else {
        print("no calendar ids found");
      }
    } catch (e) {
      print("error when deleting from device");
    }
  }

  //user data from snapshot
  UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
    try {
      return UserData(
          uid: uid,
          isConfigured: snapshot.data["isConfigured"],
          email: snapshot.data["email"],
          morning: snapshot.data["morning"],
          night: snapshot.data["night"],
          nightOwl: snapshot.data["nightOwl"],
          sweetSpotEnd: snapshot.data["sweetSpotEnd"],
          sweetSpotStart: snapshot.data["sweetSpotStart"],
          calendarToUse: snapshot.data["calendarToUse"],
          calendarToUseName: snapshot.data["calendarToUseName"]);
    } catch (e) {
      print("error on userData snap $e");
      return null;
    }
  }

//session data from snapshot
  List<Session> _sessionsDataFromSnapshot(QuerySnapshot snapshot) {
    try {
      return snapshot.documents.map((doc) {
        return Session(
            uid: uid,
            testId: doc.data["testId"],
            sessionNumber: doc.data["sessionNumber"],
            start: doc.data["start"].toDate(),
            end: doc.data["end"].toDate());
      }).toList();
    } catch (e) {
      print("error session snap $e");
      return [];
    }
  }

//get tests stream
  Stream<List<Test>> get tests {
    print("uid on test stream $uid");

    try {
      return testCollection
          .where("user", isEqualTo: uid)
          .where("dueDate", isGreaterThanOrEqualTo: new DateTime.now())
          .orderBy("dueDate", descending: true)
          .snapshots()
          .map(_testListFromSnapshot);
    } catch (e) {
      print("error on test stream $e");
      return Stream.empty();
    }
  }

//get user doc stream
  Stream<UserData> get userData {
    print("uid on user stream $uid");
    try {
      if (uid != null) {
        return userCollection
            .document(uid)
            .snapshots()
            .map(_userDataFromSnapshot);
      } else {
        return null;
      }
    } catch (e) {
      print("User data streaam errir $e");
      return Stream.empty();
    }
  }

  //get user doc stream
  Stream<List<Session>> get sessionData {
    try {
      return sessionsCollection
          .where("uid", isEqualTo: uid)
          .snapshots()
          .map(_sessionsDataFromSnapshot);
    } catch (e) {
      print("error on session stream $e");
      return Stream.empty();
    }
  }
}
