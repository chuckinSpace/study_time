import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:test_device/models/user.dart';
import 'package:test_device/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instance;

  void handleRTB(String uid) {
    try {
      var userStatusDatabaseRef = database.reference().child('/status/' + uid);

// We'll create two constants which we will write to
// the Realtime database when this device is offline
// or online.
      var isOfflineForDatabase = {
        "state": 'offline',
        "last_changed": ServerValue.timestamp
      };

      var isOnlineForDatabase = {
        "state": 'online',
        "last_changed": ServerValue.timestamp,
      };

// Create a reference to the special '.info/connected' path in
// Realtime Database. This path returns `true` when connected
// and `false` when disconnected.
      final infoRef = database.reference().child('.info/connected');
      infoRef.once().then((DataSnapshot snapshot) async {
        // If we're not currently connected, don't do anything.
        if (snapshot.value == false) {
          return;
        }

        // If we are currently connected, then use the 'onDisconnect()'
        // method to add a set which will only trigger once this
        // client has disconnected by closing the app,
        // losing internet, or any other means.
        await userStatusDatabaseRef.onDisconnect().set(isOfflineForDatabase);
        // The promise returned from .onDisconnect().set() will
        // resolve as soon as the server acknowledges the onDisconnect()
        // request, NOT once we've actually disconnected:
        // https://firebase.google.com/docs/reference/js/firebase.database.OnDisconnect

        // We can now safely set ourselves as 'online' knowing that the
        // server will mark us as offline once we lose connection.
        await userStatusDatabaseRef.set(isOnlineForDatabase);
      });
    } catch (e) {
      print(e);
    }
  }

  // create user obj based on FirebaseUser
  User _userFromFirebaseUser(FirebaseUser user) {
    try {
      /*    handleRTB(user.uid); */
      return user != null ? User(uid: user.uid) : null;
    } catch (e) {
      print(e);
      return User();
    }
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
