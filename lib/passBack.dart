import './todo.dart';

class PassBack {
  bool doUpdate = false;
  bool shouldDelete = false;
  Todo todo;

  PassBack({this.todo});
  PassBack.all({this.todo, this.doUpdate, this.shouldDelete});

  Todo getTodo() {
    return this.todo;
  }

  bool shouldUpdate() {
    return this.doUpdate;
  }

  bool shouldDeleteTodo() {
    return this.shouldDelete;
  }

  void setUpdate(bool doUpdate) {
    this.doUpdate = doUpdate;
  }

  void delete(bool doDelete) {
    this.shouldDelete = doDelete;
  }

  void replaceTodo(Todo todo) {
    this.todo = todo;
  }
}
