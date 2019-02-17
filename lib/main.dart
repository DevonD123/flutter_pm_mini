import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './signIn.dart';
import "./home.dart";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: _getStartPage(), debugShowCheckedModeBanner: false);
  }

  Widget _getStartPage() {
    return StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snap) {
          if (snap.hasData) {
            //if(snap.data.isEmailVerified){
            FirebaseAuth.instance
                .currentUser()
                .then((usr) => HomeScreen(user: usr))
                .catchError((e) {
              print(e);
              return SignIn();
            });
            //}
          }
          return SignIn();
        });
  }
}
