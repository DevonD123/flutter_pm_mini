import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './changePass.dart';
import './home.dart';

class SignUp extends StatefulWidget {
  @override
  SignUpState createState() => new SignUpState();
}

class SignUpState extends State<SignUp> {
  String errMsg = "";
  TextEditingController emailCont = new TextEditingController();
  TextEditingController p1Cont = new TextEditingController();
  TextEditingController p2Cont = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailCont.dispose();
    p1Cont.dispose();
    p2Cont.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          isLoading
              ? LinearProgressIndicator(backgroundColor: Colors.purpleAccent)
              : Container(height: 1.0),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(child: _showErrMsg()),
                Padding(
                  padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                  child: TextField(
                    controller: emailCont,
                    decoration: InputDecoration(labelText: "Email"),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                  child: TextField(
                    controller: p1Cont,
                    decoration: InputDecoration(labelText: "Password"),
                    obscureText: true,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(50.0, 10.0, 50.0, 10.0),
                  child: TextField(
                    controller: p2Cont,
                    decoration: InputDecoration(labelText: "Confirm Password"),
                    obscureText: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(child: _renderButton()),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: FlatButton(
                      child: Text("Forgot Password?"),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ChangePass()));
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _renderButton() {
    return RaisedButton(
        padding: EdgeInsets.all(10.0),
        color: isLoading ? Colors.grey : Colors.blueAccent,
        child: Text("Sign Up",
            style: TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w800,
                fontSize: 30.0)),
        onPressed: () {
          if (emailCont.text.length <= 0 ||
              p1Cont.text.length <= 0 ||
              p2Cont.text.length <= 0) {
            return setState(() {
              errMsg = "please fill in all fields";
            });
          }
          if (emailCont.text.indexOf("@") <= -1 ||
              emailCont.text.indexOf(".") <= -1) {
            return setState(() {
              errMsg = "please supply a valid email";
            });
          }
          if (p1Cont.text != p2Cont.text) {
            return setState(() {
              errMsg = "passwords must match";
            });
          }
          setState(() {
            isLoading = true;
          });
          String email = emailCont.text;
          emailCont.clear();
          String pass = p1Cont.text;
          p1Cont.clear();
          p2Cont.clear();
          _handleSignUp(email, pass)
              .then((FirebaseUser usr) => _redirectHome(usr))
              .catchError((e) => setState(() {
                    isLoading = false;
                    errMsg = "Error Signing Up";
                  }));
        });
  }

  Widget _showErrMsg() {
    return Container(
        padding: EdgeInsets.only(top: 10.0),
        height: 50.0,
        child: Text(
          errMsg,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ));
  }

  Future<FirebaseUser> _handleSignUp(String email, String pass) async {
    String emailTrim = email.trim().toLowerCase();
    final FirebaseUser fUser = await _auth.createUserWithEmailAndPassword(
        email: emailTrim, password: pass);
    Map<String, dynamic> userData = new Map<String, dynamic>();
    userData["email"] = emailTrim;
    Firestore.instance
        .collection("users")
        .document(fUser.uid)
        .setData(userData);
    return fUser;
  }

  void _redirectHome(FirebaseUser user) {
    setState(() {
      isLoading = false;
    });
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(user: user)));
  }
}
