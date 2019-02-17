class Todo {
  List<String> inviteList = new List<String>(); //==> holds emails
  String task;
  String id;
  String ownerId;
  bool isComplete;
  DateTime deadLine;
  int lvl;
  String notes;

  Todo(
      {this.task,
      this.id,
      this.ownerId,
      this.isComplete,
      this.deadLine,
      this.lvl,
      this.notes});

  Todo.bareBones({String task, String id, String ownerId}) {
    this.task = task;
    this.id = id;
    this.ownerId = ownerId;
    this.isComplete = false;
    this.deadLine = new DateTime.now().add(new Duration(days: 1));
    this.lvl = 1;
    this.notes = "";
  }

  String getTask() {
    return this.task;
  }

  String getNotes() {
    return this.notes;
  }

  bool getCompleted() {
    return this.isComplete;
  }

  int getLvl() {
    return this.lvl;
  }

  DateTime getdeadLine() {
    return this.deadLine;
  }

  String getOwnerId() {
    return this.ownerId;
  }

  void toggleComplete() {
    this.isComplete = !this.isComplete;
  }

  void setDate(DateTime date) {
    this.deadLine = date;
  }

  void setNotes(String newNotes) {
    this.notes = newNotes;
  }

  void lvlUp() {
    if (this.lvl <= 3) {
      this.lvl++;
    }
  }

  void lvlDown() {
    if (this.lvl >= 1) {
      this.lvl--;
    }
  }

  List<String> getInvites() {
    return this.inviteList;
  }

  void addInvite(String p) {
    if (inviteList.contains(p)) {
      return;
    }
    inviteList.add(p);
  }

  String getId() {
    return this.id;
  }

  Map<String, dynamic> getMappedVals() {
    Map<String, dynamic> value = new Map();
    value["deadline"] = deadLine.toIso8601String();
    value["lvl"] = lvl;
    value["isComplete"] = isComplete;
    value["notes"] = notes;
    value["task"] = task;
    value["helpers"] = inviteList;
    return value;
  }

  void addHelperList(List<String> ppl) {
    this.inviteList = ppl;
  }

  List<String> getHelperList() {
    return this.inviteList;
  }

  @override
  String toString() {
    return "Task:${this.lvl}::${this.task}";
  }
}
