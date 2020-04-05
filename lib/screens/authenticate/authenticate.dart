import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import "package:flutter/material.dart";
import 'package:test_device/screens/authenticate/register.dart';
import 'package:test_device/screens/authenticate/sign_in.dart';

class Authenticate extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;
  Authenticate({this.analytics, this.observer});
  @override
  _AuthenticateState createState() => _AuthenticateState(analytics, observer);
}

class _AuthenticateState extends State<Authenticate> {
  _AuthenticateState(this.analytics, this.observer);
  bool showSignIn = true;
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return Container(
          child: SignIn(
              toggleView: toggleView,
              analytics: analytics,
              observer: observer));
    } else {
      return Container(
          child: Register(
              toggleView: toggleView,
              analytics: analytics,
              observer: observer));
    }
  }
}
