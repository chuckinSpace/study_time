import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFd0d6b5),
            Color(0xFF75b9be),
            Color(0xFF987284),
          ],
          stops: [
            0,
            55,
            100,
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          child: SpinKitChasingDots(color: Theme.of(context).primaryColor),
          height: 200,
          width: 200,
        ),
      ),
    );
  }
}
