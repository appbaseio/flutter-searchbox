/// Represents an observer function that listens for the state changes.
import 'types.dart';

class Observer {
  Function callback;
  List<KeysToSubscribe>? properties;
  Observer(this.callback, this.properties) {}
}
