class Note {
  String _senderId;
  String _senderEmail;
  String _taskId;
  String _noteId;
  String _task;

  Note(this._senderEmail, this._senderId, this._taskId, this._noteId,
      this._task);

  String getSenderEmail() {
    return _senderEmail;
  }

  String getSenderId() {
    return _senderId;
  }

  String getTaskId() {
    return _taskId;
  }

  String getTask() {
    return _task;
  }

  String getNoteId() {
    return this._noteId;
  }

  @override
  String toString() {
    return this._senderEmail + " : " + this._task;
  }
}
