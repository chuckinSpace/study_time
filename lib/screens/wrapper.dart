import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:test_device/screens/authenticate/authenticate.dart';
import 'package:test_device/screens/home/home.dart';
import 'package:provider/provider.dart';
import 'package:test_device/models/user.dart';

class Wrapper extends StatelessWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  Wrapper({this.analytics, this.observer});
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    // return eurhter home or autheticate depeending on auth
    if (user == null) {
      return Authenticate();
    } else {
      return Home(
        analytics: analytics,
        observer: observer,
      );
    }
  }
}
