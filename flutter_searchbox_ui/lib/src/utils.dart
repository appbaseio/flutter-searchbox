import 'package:dart_geohash/dart_geohash.dart';
import 'package:flutter/foundation.dart';

bool isNumeric(var arg) {
  if (arg is String) {
    if (arg == null || arg.isEmpty) {
      return false;
    }
    final number = num.tryParse(arg);

    if (number == null) {
      return false;
    }

    return true;
  } else if (arg is num) {
    return true;
  } else if (arg is List) {
    for (var i = 1; i < arg.length - 1; i++) {
      // leaving out the first and last elements for other/ no_limit options
      if (isNumeric(arg[i])) {
        return true;
      } else {
        return false;
      }
    }
  }

  return false;
}

/// Represents the location object with lat and lng values.
class Location {
  final double Lat;
  final double Lng;
  Location(this.Lat, this.Lng);
}

/// Returns the location from different types of location formats supported by Elasticsearch.
Location? getLocationObject(dynamic location) {
  if (location is String) {
    if (location.contains(',')) {
      var locationSplit = location.split(',');
      if (locationSplit.length > 1) {
        var lat = double.tryParse(locationSplit[0]);
        var lng = double.tryParse(locationSplit[1]);
        if (lat != null && lng != null) {
          return Location(lat, lng);
        }
      }
    }
    var locationDecode = GeoHash(location);
    return Location(locationDecode.latitude(), locationDecode.longitude());
  } else if (location is List) {
    if (location.length > 1) {
      var lat = double.tryParse(location[0]);
      var lng = double.tryParse(location[1]);
      if (lat != null && lng != null) {
        return Location(lat, lng);
      }
    }
  } else if (location is Map) {
    var lat = double.tryParse(location["lat"]);
    var lng = double.tryParse(location["lon"]);
    if (lat != null && lng != null) {
      return Location(lat, lng);
    }
  }
}

List prepareValueList(Map value) {
  if (value.isEmpty) {
    return [];
  }
  List valueList = [];
  if (value.containsKey('start')) {
    valueList.add(value['start']);
  }
  if (value.containsKey('end')) {
    valueList.add(value['end']);
  }
  return valueList;
}

String processFilterValues(dynamic value) {
  if (value == null || value.isEmpty) {
    return "";
  }
  if (value is String) {
    return value;
  } else if (value is num) {
    return value.toString();
  } else if (value is List) {
    return value.join(", ");
  } else if (value is Map) {
    return processFilterValues(prepareValueList(value));
  } else {
    return value.toString();
  }
}

bool isEqual(dynamic value, dynamic defaultValue) {
  if (value == null || defaultValue == null) {
    return false;
  }
  if (value is String && defaultValue is String) {
    return value == defaultValue;
  } else if (value is num && defaultValue is num) {
    return value == defaultValue;
  } else if (value is List && defaultValue is List) {
    return listEquals(value, defaultValue);
  } else if (value is Map && defaultValue is Map) {
    if (value.keys.length != defaultValue.keys.length) {
      return false;
    }
    for (var key in value.keys) {
      if (!isEqual(value[key], defaultValue[key])) {
        return false;
      }
    }
    return true;
  } else {
    return false;
  }
}
