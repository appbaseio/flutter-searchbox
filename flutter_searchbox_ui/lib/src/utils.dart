import 'package:dart_geohash/dart_geohash.dart';

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
    for (var i = 1; i < arg.length; i++) {
      // leaving out the first element for other options
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
