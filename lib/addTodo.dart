import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import './todo.dart';

class AddScreen extends StatefulWidget {
  final String _uid;

  AddScreen(this._uid);

  @override
  AddScreenState createState() => new AddScreenState(_uid);
}

class AddScreenState extends State<AddScreen> {
  DateTime dueDate;
  int urgency = 1;
  final String _curUserId;

  AddScreenState(this._curUserId);

  final taskController = TextEditingController();
  final noteController = TextEditingController();
  final inviteController = TextEditingController();

  @override
  void initState() {
    setState(() {
      dueDate = DateTime.now();
    });
  }

  @override
  void dispose() {
    taskController.dispose();
    noteController.dispose();
    inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Add A Task"),
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(50.00, 5.00, 50.00, 0.00),
          child: Column(
            children: <Widget>[
              TextField(
                style: TextStyle(color: _renderUgrencyColor()),
                decoration: InputDecoration(
                    hasFloatingPlaceholder: true, labelText: "Task"),
                controller: taskController,
              ),
              TextField(
                style: TextStyle(color: _renderUgrencyColor()),
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  hasFloatingPlaceholder: true,
                  labelText: "Notes",
                ),
                controller: noteController,
              ),
              TextField(
                style: TextStyle(color: _renderUgrencyColor()),
                decoration: InputDecoration(
                    hasFloatingPlaceholder: true,
                    labelText: "Invites",
                    suffixText: "b@a.com,c@e.com"),
                controller: inviteController,
              ),
              Center(
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.00),
                      child: Text(
                        "Urgency: " + urgency.toString(),
                        style: TextStyle(
                            color: _renderUgrencyColor(), fontSize: 15.0),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          if (urgency <= 3) {
                            setState(() {
                              urgency++;
                            });
                          }
                        },
                        color: urgency == 4 ? Colors.grey : Colors.blueAccent,
                        icon: Icon(Icons.arrow_upward)),
                    IconButton(
                        onPressed: () {
                          if (urgency >= 2) {
                            setState(() {
                              urgency--;
                            });
                          }
                        },
                        color: urgency == 1 ? Colors.grey : Colors.blueAccent,
                        icon: Icon(Icons.arrow_downward))
                  ],
                ),
              ),
              Row(children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Deadline : " + dueDate.toIso8601String().split("T")[0],
                    style:
                        TextStyle(color: _renderUgrencyColor(), fontSize: 15.0),
                  ),
                ),
                RaisedButton(
                    onPressed: () {
                      _showPicker(context);
                    },
                    color: Colors.blueAccent,
                    child: Icon(Icons.calendar_today)),
              ]),
              Padding(
                padding: const EdgeInsets.only(top: 20.00),
                child: RaisedButton(
                    onPressed: () {
                      List<String> invites = inviteController.text
                          .trim()
                          // .replaceAll(new RegExp("\s"), "")
                          .split(",");
                      //add todo
                      Todo addingTodo = new Todo(
                          task: taskController.text,
                          id: _hashForId(taskController.text, dueDate),
                          ownerId: _curUserId,
                          deadLine: dueDate,
                          lvl: urgency,
                          isComplete: false,
                          notes: noteController.text);
                      addingTodo.addHelperList(invites);
                      Navigator.pop(context, addingTodo);
                    },
                    color: Colors.greenAccent,
                    child: Text(
                      "ADD",
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _hashForId(String task, DateTime date) {
    //to hash for id
    var toHash = utf8.encode(task + date.toIso8601String() + _curUserId);
    return sha1.convert(toHash).bytes.join("").toString();
  }

  Future<Null> _showPicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: dueDate,
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime(2050));
    if (picked != null && picked != dueDate) {
      setState(() {
        dueDate = picked;
      });
    }
  }

  ColorSwatch _renderUgrencyColor() {
    if (urgency == 1) {
      return Colors.green;
    } else if (urgency == 2) {
      return Colors.blueGrey;
    } else if (urgency == 3) {
      return Colors.orange;
    } else {
      return Colors.redAccent;
    }
  }
}
