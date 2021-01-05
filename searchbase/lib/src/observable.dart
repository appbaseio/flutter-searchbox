import 'observer.dart';

class Observable {
  List<Observer> observers;

  Observable() {
    this.observers = [];
  }

  subscribe(Function fn, [List<String> propertiesToSubscribe]) {
    this.observers.add(new Observer(fn, propertiesToSubscribe));
  }

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
