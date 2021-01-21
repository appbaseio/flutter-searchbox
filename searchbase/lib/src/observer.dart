/// Represents an observer function that listens for the state changes.
class Observer {
  Function callback;
  List<String> properties;
  Observer(this.callback, this.properties) {}
}
