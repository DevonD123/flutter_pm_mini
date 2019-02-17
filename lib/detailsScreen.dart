import 'package:flutter/material.dart';
import './todo.dart';
import "./passBack.dart";

class Details extends StatefulWidget {
  Todo todo;
  String _uid;

  Details(this.todo, this._uid);
  @override
  DetailsState createState() => new DetailsState(todo, _uid);
}

class DetailsState extends State<Details> {
  Todo todo;
  String _uid;
  bool shouldDelete = false;
  bool shouldEdit = false;
  bool editMode = false;

  DetailsState(this.todo, this._uid);

  TextEditingController notesController = new TextEditingController();

  @override
  void dispose() {
    super.dispose();
    notesController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: this.shouldDelete ? Colors.redAccent : Colors.blue,
        title: Text(this.shouldDelete ? "Deleted" : todo.getTask(),
            overflow: TextOverflow.ellipsis),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(
                context,
                new PassBack.all(
                    todo: todo,
                    shouldDelete: shouldDelete,
                    doUpdate: shouldEdit));
            //send PassBack back for the edits
          },
          icon: Icon(Icons.arrow_back),
        ),
        actions: <Widget>[
          _showDeleteButton(),
          _showEditButton(),
          _showCompleted()
        ],
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewPortConst) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: viewPortConst.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(todo.getTask(),
                      // overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black87, fontSize: 30.0)),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: _editUrgency(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              "DEADLINE: " +
                                  todo
                                      .getdeadLine()
                                      .toIso8601String()
                                      .split("T")[0],
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 18.0)),
                          _showPickerEdit()
                        ]),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        color: Colors.white70),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: _editNotes(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        color: Colors.white70),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "INVITES\n\t" + _getInvited(),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 20.0),
                      ),
                      //add invite button on editmode
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  String _getInvited() {
    List<String> invites = todo.getHelperList();
    if (invites != null && invites.length >= 1) {
      return todo.getHelperList().join("\n\t ");
    }
    return "None";
  }

  Future<Null> _showPicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: todo.getdeadLine(),
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime(2050));
    if (picked != null) {
      setState(() {
        shouldEdit = true;
        todo.setDate(picked);
      });
    }
  }

  Widget _showEditButton() {
    if (todo.getOwnerId() == _uid) {
      Color myColor = this.shouldDelete ? Colors.grey : Colors.white;
      if (editMode) {
        return AbsorbPointer(
          absorbing: this.shouldDelete ? true : false,
          child: IconButton(
              onPressed: () {
                setState(() {
                  todo.setNotes(notesController.text);
                  editMode = false;
                  shouldEdit = true;
                  //save values
                  //other actions -> change values on todo -> push to db -> navigation.pop pass back type PAssBack with the new todo and edit = true
                });
              },
              icon: Icon(Icons.save),
              color: myColor),
        );
      } else {
        return AbsorbPointer(
          absorbing: this.shouldDelete ? true : false,
          child: IconButton(
              onPressed: () {
                setState(() {
                  editMode = true;
                  shouldEdit = true;
                });
              },
              icon: Icon(Icons.edit),
              color: myColor),
        );
      }
    }
    return Container();
  }

  Widget _editNotes() {
    if (editMode) {
      notesController.text = todo.getNotes();
      return FractionallySizedBox(
        widthFactor: .5,
        alignment: Alignment.center,
        child: TextField(
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          controller: notesController,
          decoration: InputDecoration(labelText: "NOTES:"),
        ),
      );
    } else {
      return Text("NOTES: \n\t\t\t" + todo.getNotes(),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54, fontSize: 18.0));
    }
  }

  Widget _editUrgency() {
    Text urg = Text(
      "URGENCY: " + todo.getLvl().toString(),
      textAlign: TextAlign.center,
      style:
          TextStyle(color: _renderUrgencyColor(todo.getLvl()), fontSize: 18.0),
    );
    if (editMode) {
      return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                onPressed: () {
                  if (todo.getLvl() <= 3) {
                    setState(() {
                      todo.lvlUp();
                      shouldEdit = true;
                    });
                  }
                },
                icon: Icon(Icons.arrow_upward),
                color: todo.getLvl() <= 3 ? Colors.blue : Colors.grey),
            urg,
            IconButton(
                onPressed: () {
                  if (todo.getLvl() >= 2) {
                    setState(() {
                      todo.lvlDown();
                      shouldEdit = true;
                    });
                  }
                },
                icon: Icon(Icons.arrow_downward),
                color: todo.getLvl() >= 2 ? Colors.blue : Colors.grey)
          ]);
    } else {
      return urg;
    }
  }

  Widget _showPickerEdit() {
    if (todo.getOwnerId() == _uid && editMode) {
      return IconButton(
          onPressed: () {
            _showPicker(context);
          },
          icon: Icon(Icons.edit));
    }
    return Container();
  }

  Widget _showDeleteButton() {
    if (todo.getOwnerId() == _uid) {
      return IconButton(
          onPressed: () {
            setState(() {
              shouldDelete = !this.shouldDelete;
              editMode = false;
            });
          },
          icon: Icon(this.shouldDelete ? Icons.cancel : Icons.delete),
          color: this.shouldDelete ? Colors.white : Colors.redAccent);
    }
    return Container();
  }

  Widget _showCompleted() {
    IconData ico = Icons.check_box_outline_blank;
    if (todo.getCompleted()) {
      ico = Icons.check_box;
    }
    return AbsorbPointer(
      absorbing: this.shouldDelete ? true : false,
      child: IconButton(
          onPressed: () {
            setState(() {
              todo.toggleComplete();
              shouldEdit = true;
            });
          },
          icon: Icon(ico),
          color: this.shouldDelete ? Colors.grey : Colors.white),
    );
  }

  Color _renderUrgencyColor(int val) {
    if (val == 1) {
      return Colors.green[300];
    }
    if (val == 2) {
      return Colors.blueGrey[300];
    }
    if (val == 3) {
      return Colors.orange[300];
    }
    return Colors.red[300];
  }
}
