## Flutter SearchBox UI

[flutter_searchbox_ui](https://github.com/appbaseio/flutter-searchbox/tree/master/flutter_searchbox_ui) provides UI widgets for Elasticsearch and Appbase.io, with the ability to make different types of queries.

Currently, We support [RangeInput] and [ReactiveGoogleMap] components

## Installation

To install `flutter_searchbox_ui`, please follow the following steps:

1. Depend on it

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_searchbox: ^2.2.3-nullsafety
  searchbase: ^2.2.2
  flutter_searchbox_ui: 1.0.11-alpha
```

2. Install it

You can install packages from the command line:

```bash
$ flutter pub get
```

3. To use [ReactiveGoogleMap] please follow the installation guide mentioned at [here](https://pub.dev/packages/google_maps_flutter).

## Basic usage

### ReactiveGoogleMap example with RangeInput

<p float="left" style="margin-top: 50px">
  <img alt="Basic Example" src="https://raw.githubusercontent.com/appbaseio/flutter-assets/master/map.gif" width="250" />
</p>

The following example renders a `RangeInput` ui widget from the `flutter_searchbox_ui` library with id `range-filter` to render a range input selector,. This widget is being used by `map-widget` to filter the earthquakes markers data based on the range of `magnitude` of earthquakes, selected in `range-filter`(check the `react` property).

```dart
import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'package:flutter_searchbox_ui/flutter_searchbox_ui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'results.dart';

void main() {
  runApp(FlutterSearchBoxUIApp());
}

class FlutterSearchBoxUIApp extends StatelessWidget {
  // Avoid creating searchbase instance in build method
  // to preserve state on hot reloading
  final searchbaseInstance = SearchBase(
      'earthquakes',
      'https://appbase-demo-ansible-abxiydt-arc.searchbase.io',
      'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61',
      appbaseConfig: AppbaseSettings(
          recordAnalytics: true,
          // Use unique user id to personalize the recent searches
          userId: 'jon@appbase.io'));

  FlutterSearchBoxUIApp({Key? key}) : super(key: key);

  // Function to build cluster icon
  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.orange;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  @override
  Widget build(BuildContext context) {
    // The SearchBaseProvider should wrap your MaterialApp or WidgetsApp. This will
    // ensure all routes have access to the store.
    return SearchBaseProvider(
      // Pass the searchbase instance to the SearchBaseProvider. Any ancestor `SearchWidgetConnector`
      // widgets will find and use this value as the `SearchController`.
      searchbase: searchbaseInstance,
      child: MaterialApp(
        title: "SearchBox Demo",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: RangeInput(
              id: 'range-selector',
              buildTitle: () {
                return const Text(
                  "Filter by Magnitude",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.amber,
                  ),
                );
              },
              buildRangeLabel: () {
                return const Text(
                  "to",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.blue,
                  ),
                );
              },
              dataField: 'magnitude',
              range: const RangeType(
                start: 4,
                end: 10,
              ),
              rangeLabels: RangeLabelsType(
                start: (value) {
                  return value == 'other'
                      ? 'Custom Other'
                      : (value == 'no_limit' ? 'No Limit' : '$value');
                },
                end: (value) {
                  return value == 'other'
                      ? 'Custom Other'
                      : (value == 'no_limit' ? 'No Limit' : '$value');
                },
              ),
              validateRange: (start, end) {
                if (start < end) {
                  return true;
                }
                return false;
              },
              buildErrorMessage: (start, end) {
                return Text(
                  'Custom error $start > $end',
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.yellowAccent,
                  ),
                );
              },
              inputStyle: const TextStyle(
                fontSize: 18,
                height: 1,
                color: Colors.deepPurple,
              ),
              dropdownStyle: const TextStyle(
                fontSize: 18,
                height: 1,
                color: Colors.deepPurpleAccent,
              ),
              customContainer: (showError, childWidget) {
                return Container(
                  padding: const EdgeInsets.only(left: 6.0, right: 1.0),
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: showError ? Colors.orangeAccent : Colors.black,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: childWidget,
                );
              },
              closeIcon: () {
                return const Text(
                  "X",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.blueAccent,
                  ),
                );
              },
              dropdownIcon: (showError) {
                return Icon(
                  Icons.arrow_drop_down,
                  color: showError ? Colors.red : Colors.black,
                );
              },
            ),
            toolbarHeight: 120,
            backgroundColor: Colors.white.withOpacity(.9),
          ),
          body: Center(
            // A custom UI widget to render earthquakes markers
            child: ReactiveGoogleMap(
              id: 'map-widget',
              // To update markers when magnitude gets changed
              react: const {
                "and": "range-selector",
              },
              // initial map center
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.42796133580664, -122.085749655962),
                zoom: 4,
              ),
              // To enable markers' clustering
              showMarkerClusters: true,
              // Build cluster marker
              // Here we are displaying the [Marker] icon and text based on the number of items present in a cluster.
              buildClusterMarker: (Cluster cluster) async {
                return Marker(
                  markerId: MarkerId(cluster.getId()),
                  position: cluster.location,
                  icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
                      text:
                          cluster.isMultiple ? cluster.count.toString() : null),
                );
              },
              // To build marker when `showMarkerClusters` is set to `false`
              // buildMarker: (Place place) {
              //   return Marker(
              //       markerId: MarkerId(place.id), position: place.position);
              // },
              // Database field mapped to geo points.
              dataField: 'location',
              // Size of Elasticsearch hits
              // We set the `size` as zero because we're using aggregations to build markers.
              size: 0,
              // Size of Elasticsearch aggregations
              aggregationSize: 50,
              // To fetch initial results
              triggerQueryOnInit: true,
              // To update markers when map bounds change
              searchAsMove: true,
              // Use a default query to use Elasticsearch `geohash_grid` query.
              defaultQuery: (SearchController controller) {
                return {
                  "aggregations": {
                    "location": {
                      "geohash_grid": {"field": "location", "precision": 3}
                    }
                  }
                };
              },
              // Calculate markers from aggregation data
              calculateMarkers: (SearchController controller) {
                List<Place> places = [];
                for (var bucket in controller.aggregationData?.data ?? []) {
                  try {
                    var locationDecode = GeoHash(bucket["_key"]);
                    places.add(Place(
                        id: bucket["_key"],
                        position: LatLng(locationDecode.latitude(),
                            locationDecode.longitude())));
                  } catch (e) {}
                }
                return places;
              },
            ),
          ),
        ),
      ),
    );
  }
}
```
