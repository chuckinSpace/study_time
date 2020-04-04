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
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.black12,
            appBar: AppBar(
                backgroundColor: Colors.blueGrey[800],
                title: Text("Sign Up"),
                actions: <Widget>[
                  FlatButton.icon(
                      onPressed: () {
                        widget.toggleView();
                      },
                      icon: Icon(Icons.person),
                      textColor: Colors.white,
                      label: Text("Sign In",
                          style: TextStyle(color: Colors.white)))
                ],
                elevation: 0),
            body: Container(
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
                        RaisedButton(
                          color: Colors.red[400],
                          child: Text(
                            "Register",
                            style: TextStyle(color: Colors.white),
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
