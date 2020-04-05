import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:test_device/models/event_from_device.dart';

import 'package:test_device/screens/wrapper.dart';
import 'package:provider/provider.dart';
import 'package:test_device/models/user.dart';
import 'package:test_device/services/auth.dart';

void main() => runApp(MyApp());

EventFromDevice device = new EventFromDevice();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  @override
  Widget build(BuildContext awaitcontext) {
    bool isIOS = Theme.of(awaitcontext).platform == TargetPlatform.iOS;
    bool isKeyboardOpen = false;

    FirebaseAdMob.instance.initialize(
        appId: isIOS
            ? "ca-app-pub-7595932337183148~3525622677"
            : "ca-app-pub-7595932337183148~8398034779",
        analyticsEnabled: true);

    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          value: AuthService().user,
        ),
      ],
      child: MaterialApp(
        navigatorObservers: <NavigatorObserver>[observer],
        theme: ThemeData(
          primaryColor: Color(0xFF75B9BE),
          accentColor: Color(0xFFEE7674),
          fontFamily: 'Raleway',
          backgroundColor: Color(0xFFD0D6B5),
          buttonColor: Color(0xFF75B9BE),
          textTheme: TextTheme(
              title: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  fontFamily: "Raleway"),
              body1: TextStyle(
                  fontSize: 14.0, fontFamily: 'Hind', color: Colors.black),
              button: TextStyle(
                  fontSize: 14.0, fontFamily: 'Hind', color: Colors.white)),
          appBarTheme: AppBarTheme(
            color: Color(0xFF75B9BE),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: Wrapper(
          analytics: analytics,
          observer: observer,
        ),
        builder: (BuildContext context, Widget widget) {
          /*     createBannerAd(isIOS)
            ..load()
            ..show(); */
          isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom != 0;

          double paddingBottom = isIOS ? 90.0 : 60.0;
          double paddingRight = 0;

          return Padding(
            child: widget,
            padding: EdgeInsets.only(
                bottom: isKeyboardOpen ? 0 : paddingBottom,
                right: paddingRight),
          );
        },
      ),
    );
  }
}

MobileAdTargetingInfo targetInfo = new MobileAdTargetingInfo(
  testDevices: <String>[],
  keywords: <String>["scheduling, time management, school,tests"],
  childDirected: true,
);

BannerAd createBannerAd(bool isIOS) {
  return new BannerAd(
      adUnitId: isIOS
          ? "ca-app-pub-7595932337183148/8586377663"
          : "ca-app-pub-7595932337183148/8039582759",
      size: AdSize.smartBanner,
      targetingInfo: targetInfo,
      listener: (MobileAdEvent event) {});
}
