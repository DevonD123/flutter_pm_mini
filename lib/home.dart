import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "./detailsScreen.dart";
import "./passBack.dart";
import "./addTodo.dart";
import "./todo.dart";
import "./notification.dart";

class HomeScreen extends StatefulWidget {
  final FirebaseUser user;
  HomeScreen({this.user});
  @override
  HomeScreenState createState() => new HomeScreenState(user: user);
}

class HomeScreenState extends State<HomeScreen> {
  FirebaseUser user;
  List<Todo> list;
  List<Note> notes;
  HomeScreenState({this.user});
  bool isLoading = false;
  String errMsg = "";
  CollectionReference _listRef;
  CollectionReference _noteRef;
  CollectionReference _helperRef;
  int _pageIndex = 0;

  @override
  void initState() {
    isLoading = true;
    errMsg = "";
    try {
      list = new List<Todo>();
      _listRef = Firestore.instance.collection("users/${user.uid}/todos");
      _noteRef =
          Firestore.instance.collection("users/${user.uid}/notifications");
      _helperRef =
          Firestore.instance.collection("users/${user.uid}/helperTodos");
      _fetchTodos(); //get all todos => add helper todos
      _fetchNotes(); //get all notifications
    } catch (e) {
      errMsg = "something went wrong";
      isLoading = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            _pageIndex == 0 ? _renderTodoAppBar() : _renderNotificationAppBar(),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              isLoading
                  ? LinearProgressIndicator(backgroundColor: Colors.purple)
                  : Container(
                      height: 5.0,
                    ),
              errMsg.length >= 1
                  ? Text(errMsg,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent, fontSize: 12.0))
                  : Container(),
              Expanded(
                child: _pageIndex == 0 ? _renderTodoList() : _renderNoteList(),
              ),
            ]),
        bottomNavigationBar: _renderBottomNav());
  }

  Widget _renderTodoList() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: list != null && list.length >= 1
          ? ListView.builder(
              padding: EdgeInsets.all(5.00),
              itemCount: list == null ? 0 : list.length,
              itemBuilder: (BuildContext context, int index) {
                return _todoTileBuild(index);
              })
          : Center(
              child: Text(
              isLoading ? "Loading" : "No Tasks",
              style: TextStyle(color: Colors.blue, fontSize: 20.0),
            )),
    );
  }

  Widget _renderNoteList() {
    return notes != null && notes.length >= 1
        ? Container(
            child: ListView.builder(
                padding: EdgeInsets.all(5.00),
                itemCount: notes == null ? 0 : notes.length,
                itemBuilder: (BuildContext context, int index) {
                  return _noteTileBuild(index);
                }))
        : Center(
            child: Text(
            "No Notifications",
            style: TextStyle(color: Colors.green, fontSize: 20.0),
          ));
  }

  Widget _noteTileBuild(index) {
    // return Container(
    //   color: index % 2 == 0 ? Colors.white70 : Colors.white10,
    // child:
    return ListTile(
      title: Text(notes[index].getSenderEmail() ?? "error"),
      contentPadding: EdgeInsets.all(5.0),
      subtitle: Container(
          child: Text(
        notes[index].getTask() ?? "",
        overflow: TextOverflow.ellipsis,
      )),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          RaisedButton(
            child: Text(
              "Accept",
              style: TextStyle(color: Colors.white, fontSize: 12.0),
            ),
            color: Colors.green,
            onPressed: () {
              _noteResponse(true, notes[index], index);
            },
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.0),
            child: RaisedButton(
              child: Text(
                "Decline",
                style: TextStyle(color: Colors.white, fontSize: 12.0),
              ),
              color: Colors.red,
              onPressed: () {
                _noteResponse(false, notes[index], index);
              },
            ),
          )
        ],
      ),
      // ),
    );
  }

  Widget _todoTileBuild(index) {
    Todo curTodo = list[index];
    bool isComplete = curTodo.getCompleted();
    TextStyle curStyle = TextStyle(
      color: _renderTextColor(curTodo.getLvl(), isComplete),
    );
    return Container(
        color: _renderTileBg(curTodo, index),
        child: ListTile(
          contentPadding: EdgeInsets.all(5.0),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 5.0),
                child: _pastDue(curTodo.getdeadLine())),
            Text(
              curTodo.getdeadLine().toIso8601String().split("T")[0] ?? "error",
              style: curStyle,
              textAlign: TextAlign.center,
            )
          ]),
          title: Row(
            children: <Widget>[
              isComplete
                  ? Icon(Icons.check)
                  : Container(width: 20.0, height: 20.0),
              Flexible(
                child: Container(
                  child: Text(
                    curTodo.getTask(), //add trimming to fit screen
                    style: curStyle,
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: 1.25,
                  ),
                ),
              ),
            ],
          ),
          leading: Text(
            curTodo.getOwnerId() == user.uid ? "Owner" : "Helper",
            style: TextStyle(color: Colors.grey, fontSize: 12.0),
            textAlign: TextAlign.center,
          ),
          onTap: () {
            setState(() {
              curTodo.toggleComplete();
              list = _sortList(list);
            });
            _firebaseToggleCompleted(curTodo);
          },
          onLongPress: () async {
            PassBack res = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        Details(curTodo, user.uid)));
            if (res != null) {
              if (res.shouldDeleteTodo()) {
                list.removeAt(index);
                _firebaseDelete(res.getTodo());
              } else if (res.shouldUpdate()) {
                //get todo by id and update
                try {
                  List<Todo> newList = new List<Todo>();
                  newList.addAll(list);
                  _firebaseUpdate(res.getTodo());
                  // newList.replaceRange(index--, index, [res.getTodo()]); ===> NOT NEEDED TO TO PASS BY ref
                  setState(() {
                    list = newList;
                  });
                } catch (e) {
                  genErr();
                }
              }
            }
          },
        ));
  }

  Widget _renderBottomNav() {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (int tapped) {
          setState(() {
            _pageIndex = tapped;
          });
        },
        currentIndex: _pageIndex,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text(" ")),
          BottomNavigationBarItem(
              icon: Icon(notes != null && notes.length >= 1
                  ? Icons.notifications_active
                  : Icons.notifications_paused),
              title: Text(" ")),
        ]);
  }

  Widget _renderNotificationAppBar() {
    return AppBar(
        title: Text("Task Invites"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchNotes,
          ),
          Container()
        ],
        leading: Container());
  }

  Widget _renderTodoAppBar() {
    return AppBar(
      leading: _backButton(),
      title: Text("My Work"),
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.all(5.0),
            child: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  _fetchTodos();
                })),
        Padding(
            padding: EdgeInsets.all(5.0),
            child: IconButton(
              onPressed: () async {
                //navigate to add screen
                Todo res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            AddScreen(user.uid)));
                //add todo to todolist
                if (res != null) {
                  //adding like this to limit calls to db
                  list.add(res); //add before page new frame
                  setState(() {
                    list = _sortList(list);
                  });
                  _addTodoToFireStore(res);
                  //add a sort
                  if (res.getHelperList().length >= 1) {
                    _inviteOthers(res);
                  }
                }
              },
              icon: Icon(Icons.add),
            ))
      ],
    );
  }

  /// back button/logout
  Widget _backButton() {
    return IconButton(
      onPressed: () {
        FirebaseAuth.instance.signOut();
        Navigator.pop(context);
      },
      icon: Icon(Icons.exit_to_app),
    );
  }

  /// sort function (called on popback and toggle) + fetch
  List<Todo> _sortList(List<Todo> sortingList) {
    sortingList.sort((a, b) {
      if (!a.getCompleted() || !b.getCompleted()) {
        int a2 = a.getCompleted() ? 0 : 1;
        int b2 = b.getCompleted() ? 0 : 1;
        return b2 - a2;
      }

      DateTime dA = a.getdeadLine();
      DateTime dB = b.getdeadLine();
      int date = dA.compareTo(dB);
      if (date != 0) {
        return date; //good
      }
      return b.getLvl() - a.getLvl(); //good
    });
    return sortingList;
  }

  /// bg color renders

  Color _renderTileBg(Todo curTodo, int i) {
    if (curTodo.getCompleted()) {
      return Colors.grey;
    }
    if (i % 2 == 0) {
      return Colors.white70;
    }
    return Colors.white10;
  }

  /// txt color render

  Color _renderTextColor(int val, bool isCompleted) {
    if (isCompleted) {
      return Colors.white;
    }

    if (val == 1) {
      return Colors.green[300];
    } else if (val == 2) {
      return Colors.blueGrey[300];
    } else if (val == 3) {
      return Colors.orange[300];
    }
    return Colors.red[300];
  }

  /////////////////////////////////////////////////////////////////// TODOS ///////////////////////////////////////////////////////////////////
  Todo _parseTodo(DocumentSnapshot snap, {String helperItemId, bool isHelper}) {
    if (snap.data == null) {
      if (isHelper != null && isHelper) {
        //if the helper has been deleted on the owners end it will delete here
        Firestore.instance
            .collection("users/${user.uid}/helperTodos")
            .document(helperItemId)
            .delete();
      }
      return null;
    } else {
      List<String> dateString = snap.data["deadline"].split("T")[0].split("-");
      Todo passedTodo = new Todo(
          isComplete: snap.data["isComplete"],
          deadLine: DateTime(int.parse(dateString[0]), int.parse(dateString[1]),
              int.parse(dateString[2])),
          lvl: snap.data["lvl"],
          notes: snap.data["notes"],
          task: snap.data["task"],
          ownerId: snap.data["ownerId"],
          id: snap.documentID);
      if (snap.data["helpers"].length >= 1) {
        List<String> helperList = new List<String>.from(snap.data["helpers"]);
        passedTodo.addHelperList(helperList); //adds email list to task
      }
      return passedTodo;
    }
  }

  Widget _pastDue(DateTime due) {
    List<String> strD =
        DateTime.now().toIso8601String().split("T")[0].split("-");
    DateTime cur = new DateTime(
        int.parse(strD[0]), int.parse(strD[1]), int.parse(strD[2]));
    if (due.compareTo(cur) <= -1) {
      return Icon(
        Icons.assignment_late,
        color: Colors.red,
      );
    }
    return Container();
  }

  void _fetchHelperList(List<Todo> fetchedList) {
    try {
      _helperRef.getDocuments().then((snap) {
        List<Future> gets = new List<Future<Todo>>();
        snap.documents.forEach((helperInfo) {
          gets.add(_addSingleHelperTodo(
              helperInfo.data["todoId"], helperInfo.data["todoOwnerId"],
              isHelper: true, helperDocId: helperInfo.documentID));
        });
        Future.wait(gets).then((todoList) {
          List<Todo> helperTodoList = new List<Todo>(); //replace with list
          helperTodoList.addAll(fetchedList); //remove
          todoList.forEach((todoo) {
            if (todoo != null) {
              //null check if the todo is deleted will return null
              helperTodoList.add(todoo);
            }
          });
          List<Todo> newList = _sortList(helperTodoList);
          if (this.mounted) {
            setState(() {
              list = newList;
            });
          } else {
            list = newList;
          }
          clearLoad();
        }).catchError((e) {
          genErr();
        });
      });
    } catch (e) {
      setState(() {
        errMsg = "Error please refresh or log out and back in";
      });
    }
  }

  Future<Todo> _addSingleHelperTodo(String todoId, String todoOwner,
      {String helperDocId, bool isHelper}) async {
    Todo helperAddTodo;
    try {
      DocumentSnapshot snap = await Firestore.instance
          .collection("users/${todoOwner}/todos")
          .document(todoId)
          .get();
      helperAddTodo = _parseTodo(snap,
          helperItemId: helperDocId,
          isHelper:
              isHelper); //will return null if todo was deleted which will padss down and catch at next lvl
      return helperAddTodo;
    } catch (e) {
      genErr();
      return helperAddTodo;
    }
  }

///////============>>>> ISSUE WITH FETCHING INITIAL TODOS <<<<<
  void _fetchTodos() {
    if (!isLoading) {
      setState(() {
        isLoading = true;
        errMsg = "";
      });
    }
    List<Todo> fetchedList = new List<Todo>();
    _listRef.getDocuments().then((snap) {
      //add check if data is there
      snap.documents.forEach((f) {
        fetchedList.add(_parseTodo(f));
      });
      /*List<Todo> sortedFetchedList = _sortList(fetchedList);
      if (this.mounted) {
        setState(() {
          //list = sortedFetchedList;
          list = fetchedList;
        });
      } else {
        // list = sortedFetchedList;
        list = fetchedList;
      }*/
      _fetchHelperList(fetchedList); //also adds to state
    }).catchError((e) => genErr());
  }

  void _getHelperTodos() async {
    List<Todo> addList = new List<Todo>();
    try {
      QuerySnapshot helpers = await _helperRef.getDocuments();
      helpers.documents.forEach((item) async {
        DocumentSnapshot todoToAdd = await Firestore.instance
            .collection("users/${item.data["todoOwnerId"]}/todos")
            .document(item.data["todoId"])
            .get();
        addList.add(_parseTodo(todoToAdd));
        print(todoToAdd.data.toString());
      });
      if (this.mounted) {
        List<Todo> newList = new List<Todo>();
        if (list != null) {
          newList.addAll(list);
        }
        newList.addAll(addList);
        setState(() {
          list = newList;
          isLoading = false;
          errMsg = "";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errMsg = "error";
      });
    }
  }

  void _addTodoToFireStore(Todo todoAdd) {
    Map<String, dynamic> addMap = todoAdd.getMappedVals();
    addMap["ownerId"] = user.uid;
    //task id is set as firestore document key
    _listRef.document(todoAdd.getId()).setData(addMap);
  }

  void _firebaseDelete(Todo todoDelete) {
    if (todoDelete.getOwnerId().compareTo(user.uid) == 0) {
      //uid == ownerid ==> double check
      _listRef.document(todoDelete.getId()).delete();
    }
  }

  void _firebaseUpdate(Todo todoUpdate) {
    Map<String, dynamic> updated = todoUpdate.getMappedVals();
    // updated["ownerId"] = user.uid;
    if (todoUpdate.getOwnerId() == user.uid) {
      _listRef
          .document(todoUpdate.getId())
          .updateData(updated)
          .catchError((e) => genErr());
    } else {
      Firestore.instance
          .collection("users/${todoUpdate.getOwnerId()}/todos")
          .document(todoUpdate.getId())
          .updateData(updated)
          .catchError((e) => genErr());
    }
  }

  void _firebaseToggleCompleted(Todo toggleTodo) {
    Map<String, dynamic> isCompMap = new Map<String, dynamic>();
    isCompMap["isComplete"] = toggleTodo.getCompleted();
    Firestore.instance
        .collection("users/${toggleTodo.getOwnerId()}/todos")
        .document(toggleTodo.getId())
        .updateData(isCompMap)
        .catchError((e) => genErr());
  }

  /////////////////////////////////////////////////////////////////// NOTIFICATIONS ///////////////////////////////////////////////////////////////////
  void _fetchNotes() {
    List<Note> fetchedList = new List<Note>();
    _noteRef.getDocuments().then((snap) {
      //add check if data is there
      snap.documents.forEach((f) {
        Map<String, dynamic> vals = f.data;
        fetchedList.add(new Note(vals["senderEmail"], vals["todoOwnerId"],
            vals["todoId"], f.documentID, vals["task"]));
      });
      if (this.mounted) {
        setState(() {
          notes = fetchedList;
        });
      } else {
        notes = fetchedList;
      }
    }).catchError((e) => genErr());
    //add query for all that include uid in the todo arrays/may add to user field
  }

  void _noteResponse(bool answer, Note note, int index) async {
    try {
      setState(() {
        notes.removeAt(index);
      });
      _noteRef.document(note.getNoteId()).delete(); //err handle ++
      if (answer) {
        //add to helperTodo
        Map<String, dynamic> addedHelper = new Map<String, dynamic>();

        addedHelper["todoId"] = note.getTaskId();
        addedHelper["todoOwnerId"] = note.getSenderId();
        _helperRef.add(addedHelper);
        Todo addMe =
            await _addSingleHelperTodo(note.getTaskId(), note.getSenderId());
        setState(() {
          list.add(addMe);
        });
      }
    } catch (e) {
      setState(() {
        errMsg = "error";
        isLoading = false;
      });
    }
  }

  void _inviteOthers(Todo todoInvite) async {
    List<String> invites = todoInvite.getHelperList();
    Map<String, dynamic> newInvite = new Map<String, dynamic>();
    newInvite["todoId"] = todoInvite.getId();
    newInvite["todoOwnerId"] = user.uid;
    newInvite["senderEmail"] = user.email;
    newInvite["task"] = todoInvite.getTask();
    QuerySnapshot query =
        await Firestore.instance.collection("users").getDocuments();
    query.documents.forEach((allUsers) {
      //gets all users and checks each email (change if i actually get users)
      invites.forEach((x) {
        //loops over the invite list in the todos
        if (allUsers.data["email"].toString().compareTo(x) == 0) {
          Firestore.instance
              .collection("users/${allUsers.documentID}/notifications")
              .add(newInvite);
        }
      });
    });
  }

  void genErr() {
    setState(() {
      errMsg = "error";
      isLoading = false;
    });
  }

  void clearLoad() {
    setState(() {
      errMsg = "";
      isLoading = false;
    });
  }
}
