import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './home.dart';
import './signup.dart';
import './changePass.dart';

class SignIn extends StatefulWidget {
  @override
  SignInState createState() => new SignInState();
}

class SignInState extends State<SignIn> {
  String errMsg = "";
  TextEditingController emailCont = new TextEditingController();
  TextEditingController p1Cont = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
    emailCont.dispose();
    p1Cont.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In"), actions: <Widget>[
        FlatButton(
          child: Text("Sign Up", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) => SignUp()));
          },
        )
      ]),
      body: SingleChildScrollView(
        child: Column(children: <Widget>[
          isLoading
              ? LinearProgressIndicator(backgroundColor: Colors.purpleAccent)
              : Container(
                  height: 1.0,
                ),
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
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Center(
                    child: RaisedButton(
                        padding: EdgeInsets.all(10.0),
                        color: isLoading ? Colors.grey : Colors.blueAccent,
                        child: Text("Sign In",
                            style: TextStyle(
                                color: Colors.white54,
                                fontWeight: FontWeight.w800,
                                fontSize: 30.0)),
                        onPressed: () {
                          if (emailCont.text.length <= 0 ||
                              p1Cont.text.length <= 0) {
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
                          setState(() {
                            isLoading = true;
                          });
                          String email = emailCont.text.trim();
                          emailCont.clear();
                          String pass = p1Cont.text.trim();
                          p1Cont.clear();
                          _handleSignIn(email, pass)
                              .then((FirebaseUser usr) => _redirectHome(usr))
                              .catchError((e) => setState(() {
                                    isLoading = false;
                                    errMsg = "Error signing in";
                                  }));
                        }),
                  ),
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
          )
        ]),
      ),
    );
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

  Future<FirebaseUser> _handleSignIn(String email, String pass) async {
    final FirebaseUser fUser =
        await _auth.signInWithEmailAndPassword(email: email, password: pass);
    setState(() {
      isLoading = false;
    });
    return fUser;
  }

  void _redirectHome(FirebaseUser user) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen(user: user)));
  }
}
