import 'package:firebase_admob/firebase_admob.dart';
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
  @override
  Widget build(BuildContext awaitcontext) {
    bool isIOS = Theme.of(awaitcontext).platform == TargetPlatform.iOS;
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
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
        builder: (BuildContext context, Widget widget) {
          createBannerAd(isIOS)
            ..load()
            ..show();

          double paddingBottom = 60.0;
          double paddingRight = 0;

          return Padding(
            child: widget,
            padding: EdgeInsets.only(
                bottom: isIOS ? paddingBottom + 30 : paddingBottom,
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
