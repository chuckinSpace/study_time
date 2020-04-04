import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_device/models/user.dart';
import 'package:test_device/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user obj based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  //auth change user stream
  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  //sign in with email and pass
  Future signInWithEmailandPassword(String email, String password) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = authResult.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<AuthCredential> getCredentials(GoogleSignInAccount account) async {
    AuthCredential auth = GoogleAuthProvider.getCredential(
        idToken: (await account.authentication).idToken,
        accessToken: (await account.authentication).accessToken);
    return auth;
  }

  Future<bool> signInWithGoogle() async {
    try {
      GoogleSignIn google = new GoogleSignIn(
        scopes: [
          'email',
        ],
      );

      GoogleSignInAccount account = await google.signIn();
      if (account == null) {
        return false;
      } else {
        final credentials = await getCredentials(account);

        AuthResult res = await _auth.signInWithCredential(credentials);

        if (res.user == null) {
          return false;
        } else {
          FirebaseUser user = res.user;
          await DatabaseService(user.uid).createUserDocument(user.email);
          _userFromFirebaseUser(user);

          return true;
        }
      }
    } catch (e) {
      print("error signing with google $e");
      return false;
    }
  }

  //register with email and pass
  Future<String> registerWithEmailandPassword(
      String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      FirebaseUser user = authResult.user;

      //create a new documnet for the user iwh uid

      await DatabaseService(user.uid).createUserDocument(email);
      _userFromFirebaseUser(user);
      return "";
    } catch (e) {
      if (e.code == "ERROR_INVALID_EMAIL") {
        return "Invalid Email";
      } else if (e.code == "ERROR_WEAK_PASSWORD") {
        return "Password must be at least 7 characters";
      } else if (e.code == "ERROR_EMAIL_ALREADY_IN_USE") {
        return "Email is already registered, please retrieve your password in the sign in page";
      } else {
        return "User not found";
      }
    }
  }

  Future<String> recoverPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);

      //create a new documnet for the user iwh uid
      return "";
    } catch (e) {
      if (e.code == "ERROR_INVALID_EMAIL") {
        return "Invalid Email";
      } else {
        return "User not found";
      }
    }
  }

  //signout
  Future signOut() async {
    try {
      GoogleSignIn google = new GoogleSignIn(
        scopes: [
          'email',
        ],
      );
      await google.signOut();
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
