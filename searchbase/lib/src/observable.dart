import 'observer.dart';

/// Observable class holds the registered callbacks and invokes them when `next` method is called.
class Observable {
  List<Observer> observers;

  Observable() {
    this.observers = [];
  }

  /// To subscribe a function for updates.
  subscribe(Function fn, [List<String> propertiesToSubscribe]) {
    this.observers.add(new Observer(fn, propertiesToSubscribe));
  }

  /// To unsubscribe a function to avoid further updates.
  unsubscribe([Function fn]) {
    if (fn != null) {
      this.observers = this.observers.where((Observer item) {
        if (item.callback != fn) {
          return true;
        }
        return false;
      }).toList();
    } else {
      this.observers = [];
    }
  }

  /// To broadcast an update. All the subscribed methods would be invoked.
  next(dynamic o, String property) {
    this.observers.forEach((Observer item) {
      // filter by subscribed properties
      if (item.properties == null) {
        item.callback(o);
      } else if (item.properties.length != 0 &&
          item.properties.indexOf(property) != -1) {
        item.callback(o);
      }
    });
  }
}
