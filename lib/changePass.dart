import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePass extends StatefulWidget {
  @override
  ChangePassState createState() => new ChangePassState();
}

class ChangePassState extends State<ChangePass> {
  TextEditingController emailCont;
  String errMsg = "";
  String compMsg = "";
  @override
  void initState() {
    super.initState();
    emailCont = new TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    emailCont.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Change Password")),
        body: SingleChildScrollView(
          child: Center(
              child: Column(children: <Widget>[
            Text(
              errMsg.length >= 2 ? errMsg : "",
              style: TextStyle(color: Colors.redAccent, fontSize: 14.0),
            ),
            Text(
              compMsg.length >= 2 ? compMsg : "",
              style: TextStyle(color: Colors.greenAccent, fontSize: 16.0),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                controller: emailCont,
                decoration: InputDecoration(labelText: "Email"),
              ),
            ),
            RaisedButton(
              onPressed: () {
                String msg = "";
                if (!emailCont.text.contains("@") ||
                    !emailCont.text.contains(".") ||
                    emailCont.text.length <= 3) {
                  msg = "please use a valid email";
                  emailCont.clear();
                }
                setState(() {
                  errMsg = msg;
                  compMsg = "";
                });
                if (msg.length <= 1) {
                  FirebaseAuth.instance
                      .sendPasswordResetEmail(email: emailCont.text)
                      .then((val) {
                    emailCont.clear();
                    setState(() {
                      compMsg = "Reset email sent";
                    });
                  }).catchError((e) {
                    emailCont.clear();
                    setState(() {
                      errMsg = "user does not exist";
                    });
                  });
                }
              },
              color: Colors.blue,
              child: Text(
                "Reset Password",
                style: TextStyle(color: Colors.white70),
              ),
            )
          ])),
        ));
  }
}
