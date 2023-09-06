/// Represents an observer function that listens for the state changes.
import 'types.dart';

class Observer {
  late Function callback;
  late List<KeysToSubscribe>? properties;
  Observer(this.callback, this.properties) {}
}
