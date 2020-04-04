import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:test_device/screens/home/home.dart';
import 'package:test_device/services/auth.dart';
import 'package:test_device/shared/constants.dart';
import 'package:test_device/shared/loading.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  SignIn({this.toggleView});

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
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
            backgroundColor: Colors.black12,
            appBar: AppBar(
                backgroundColor: Colors.blueGrey[800],
                title: Text("Sign In"),
                actions: <Widget>[
                  FlatButton.icon(
                      onPressed: () {
                        widget.toggleView();
                      },
                      icon: Icon(
                        Icons.person,
                      ),
                      textColor: Colors.white,
                      label: Text(
                        "Register",
                        style: TextStyle(color: Colors.white),
                      ))
                ],
                elevation: 0),
            body: _retrievePassword == true
                ? SingleChildScrollView(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 15),
                            Text(
                              "Enter you email",
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
                                  setState(() => recoverEmail = val);
                                }),
                            SizedBox(height: 20),
                            RaisedButton(
                                color: Colors.red[400],
                                child: Text(
                                  "Send",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(() => loading = true);

                                    final response = await _auth
                                        .recoverPassword(recoverEmail);
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
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 50),
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
                              color: Colors.blue[400],
                              child: Text(
                                "Sign In With Google",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                setState(() => loading = true);
                                dynamic result = await _auth.signInWithGoogle();

                                if (result == false && this.mounted) {
                                  setState(() {
                                    error = "Google sign in failed, try again";
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
                              color: Colors.red[400],
                              child: Text(
                                "Sign In",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                setState(() {
                                  error = "";
                                });
                                if (_formKey.currentState.validate()) {
                                  setState(() {
                                    loading = true;
                                  });
                                  dynamic result =
                                      await _auth.signInWithEmailandPassword(
                                          email.trim(), password);
                                  if (result == null) {
                                    setState(() {
                                      error =
                                          "Incorrect combination email and password please try again";
                                      loading = false;
                                    });
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
