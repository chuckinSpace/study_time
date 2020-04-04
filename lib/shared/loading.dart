import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      /*   color: Colors.black38, */
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
