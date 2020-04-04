import 'package:flutter/material.dart';
import 'package:test_device/services/auth.dart';
import 'package:test_device/shared/constants.dart';
import 'package:test_device/shared/loading.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String error = "";
  String retype = "";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
                title:
                    Text("Sign Up", style: Theme.of(context).textTheme.title),
                actions: <Widget>[
                  FlatButton.icon(
                      onPressed: () {
                        widget.toggleView();
                      },
                      icon: Icon(Icons.person),
                      textColor: Colors.black,
                      label: Text("Sign In",
                          style: TextStyle(color: Colors.black)))
                ],
                elevation: 0),
            body: Container(
              height: double.infinity,
              width: double.infinity,
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
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 20),
                        TextFormField(
                            decoration:
                                textInputDecoration.copyWith(hintText: "Email"),
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
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                              hintText: "Re Type Password"),
                          validator: (val) =>
                              val != password ? "Password do not match" : null,
                          onChanged: (val) {
                            setState(() => retype = val);
                          },
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        RaisedButton(
                          child: Text(
                            "Register",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() => loading = true);
                              dynamic result =
                                  await _auth.registerWithEmailandPassword(
                                      email.trim(), password);
                              if (result != "") {
                                setState(() {
                                  error = result;
                                  loading = false;
                                });
                              }
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        Text(error,
                            style: TextStyle(color: Colors.red, fontSize: 20))
                      ],
                    ),
                  )),
            ),
          );
  }
}
