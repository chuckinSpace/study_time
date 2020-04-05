import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:test_device/screens/home/home.dart';
import 'package:test_device/services/auth.dart';
import 'package:test_device/shared/constants.dart';
import 'package:test_device/shared/loading.dart';

class SignIn extends StatefulWidget {
  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  final Function toggleView;
  SignIn({this.toggleView, this.analytics, this.observer});

  @override
  _SignInState createState() => _SignInState(analytics, observer);
}

class _SignInState extends State<SignIn> {
  _SignInState(this.analytics, this.observer);
  final FirebaseAnalyticsObserver observer;
  final FirebaseAnalytics analytics;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String recoverEmail = "";
  String password = "";
  String error = "";
  bool loading = false;
  bool _retrievePassword = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
                title: Text(
                  _retrievePassword == true ? "Recover Password" : "Sign In",
                  style: Theme.of(context).textTheme.title,
                ),
                actions: <Widget>[
                  Visibility(
                    visible: _retrievePassword == true,
                    child: FlatButton.icon(
                        onPressed: () {
                          setState(() {
                            _retrievePassword = false;
                          });
                        },
                        icon: Icon(Icons.person),
                        label: Text("Log In")),
                  ),
                  Visibility(
                    visible: _retrievePassword == false,
                    child: FlatButton.icon(
                        onPressed: () async {
                          await analytics.logLogin();
                          widget.toggleView();
                        },
                        icon: Icon(
                          Icons.person,
                        ),
                        textColor: Colors.black,
                        label: Text(
                          "Register",
                          style: TextStyle(color: Colors.black),
                        )),
                  )
                ],
                elevation: 0),
            body: _retrievePassword == true
                ? Container(
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
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: 15),
                          Text(
                            "Enter you email",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                              decoration: textInputDecoration.copyWith(
                                hintText: "Email",
                              ),
                              validator: (val) =>
                                  val.isEmpty ? "Enter an email" : null,
                              onChanged: (val) {
                                setState(() => recoverEmail = val);
                              }),
                          SizedBox(height: 20),
                          RaisedButton(
                              child: Text(
                                "Send",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  setState(() => loading = true);

                                  final response =
                                      await _auth.recoverPassword(recoverEmail);
                                  if (response.isNotEmpty) {
                                    setState(() {
                                      error = response;
                                      setState(() => loading = false);
                                    });
                                  } else {
                                    setState(() {
                                      loading = false;
                                      _retrievePassword = false;
                                      error = "Email sent";
                                    });
                                  }
                                }
                              }),
                          SizedBox(height: 12),
                          Text(error,
                              style: TextStyle(
                                  color: Colors.redAccent, fontSize: 20))
                        ],
                      ),
                    ),
                  )
                : Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                      Color(0xFFd0d6b5),
                      Color(0xFF75b9be),
                      Color(0xFF987284),
                    ], stops: [
                      0,
                      55,
                      100,
                    ])),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Text(
                              "Let's Start right away",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            SizedBox(height: 15),
                            RaisedButton(
                              child: Text("Sign In With Google",
                                  style: Theme.of(context).textTheme.button),
                              onPressed: () async {
                                await analytics.logEvent(name: "Google_Button");
                                setState(() => loading = true);
                                dynamic result = await _auth.signInWithGoogle();

                                if (result == false && this.mounted) {
                                  setState(() {
                                    error = "Google sign in failed, try again";
                                    loading = false;
                                  });
                                } else {
                                  if (this.mounted && result) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Home()),
                                    );
                                  }
                                }
                              },
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text("Or",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white)),
                              ],
                            ),
                            SizedBox(height: 20),
                            AutoSizeText(
                              "Old fashion? Register on the top to use user and password",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            ),
                            SizedBox(height: 15),
                            TextFormField(
                                decoration: textInputDecoration.copyWith(
                                    hintText: "Email"),
                                validator: (val) =>
                                    val.isEmpty ? "Enter an email" : null,
                                onChanged: (val) {
                                  setState(() => email = val);
                                }),
                            SizedBox(height: 20),
                            TextFormField(
                              decoration: textInputDecoration.copyWith(
                                  hintText: "Password"),
                              validator: (val) => val.length < 6
                                  ? "Enter a password 6+ chars long"
                                  : null,
                              onChanged: (val) {
                                setState(() => password = val);
                              },
                              obscureText: true,
                            ),
                            SizedBox(height: 20),
                            FlatButton(
                              child: Text(
                                "Forgot your password?",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.yellow),
                              ),
                              onPressed: () {
                                setState(() {
                                  _retrievePassword = true;
                                });
                              },
                            ),
                            SizedBox(height: 20),
                            RaisedButton(
                              child: Text("Sign In",
                                  style: Theme.of(context).textTheme.button),
                              onPressed: () async {
                                setState(() {
                                  error = "";
                                });
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  await analytics.logLogin();
                                  dynamic result =
                                      await _auth.signInWithEmailandPassword(
                                          email.trim(), password);
                                  if (result == null) {
                                    setState(() {
                                      error =
                                          "Incorrect combination email and password please try again";
                                      loading = false;
                                    });
                                  } else {
                                    if (this.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Home()),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                            SizedBox(height: 12),
                            Text(error,
                                style: TextStyle(
                                    color: Colors.redAccent, fontSize: 20))
                          ],
                        ),
                      ),
                    ),
                  ),
          );
  }
}
