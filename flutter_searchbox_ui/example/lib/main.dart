import 'package:flutter/material.dart' hide SearchController;
import 'package:searchbase/searchbase.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'package:flutter_searchbox_ui/flutter_searchbox_ui.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart' hide ClusterManager;
// Import with alias to avoid naming conflicts
import 'package:google_maps_cluster_manager_appbase_fork/google_maps_cluster_manager_appbase_fork.dart' as cluster_manager;
import 'dart:io';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };
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
            // A filter to update earthquakes by magnitude
            title: RangeInput(
              id: 'range-selector',
              beforeValueChange: (dynamic value) async {
                if (value is Map<String, dynamic>) {
                  final Map<String, dynamic> mapValue = value;
                  if (mapValue['start'] == 0 && mapValue['end'] == null) {
                    return Future.error(value);
                  }
                }
                return value;
              },
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
                start: ['other', 4, 5, 6, 7],
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
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(20.0),
            // SelectedFilters: a widget to track all active filters
            child: SelectedFilters(
              subscribeTo: const ['range-selector'],
              filterLabel: (id, value) {
                if (id == 'range-selector') {
                  return 'Range: $value';
                }
                return '$id: $value';
              },
              showClearAll: true,
              clearAllLabel: "Vanish All",
              onClearAll: () {
                // do something here
                print('Clear all called');
              },
              onClear: (id, value) {
                // do something here
                print('Filter $id with value: ${value.toString()} cleared');
              },
              resetToDefault: true,
              defaultValues: const {
                "range-selector": {'start': 5, 'end': 10}
              },
              // hideDefaultValues: false,
              // uncomment below property to render custom ui for SelectedFilters widget
              // buildFilters: (options) {
              //   List<Widget> widgets = [];
              //   options.selectedValues.forEach((id, filterValue) {
              //     widgets.add(
              //       Chip(
              //         label: Text(
              //             ' $id --- ${options.getValueAsString(filterValue)}'),
              //         onDeleted: () {
              //           options.clearValue(id);
              //         },
              //       ),
              //     );
              //   });
              //   return Wrap(
              //     spacing: 16.0,
              //     crossAxisAlignment: WrapCrossAlignment.start,
              //     // gap between adjacent chips
              //     children: widgets,
              //   );
              // },
            ),
          ),
          body: ReactiveGoogleMap(
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
            showMarkerClusters: false,
            // Build markers without clustering
            buildMarker: (Place place) {
              return Marker(
                  markerId: MarkerId(place.id), 
                  position: place.position,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange));
            },
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
            // [Optipnal] Use a default query to use Elasticsearch `geohash_grid` query.
            defaultQuery: (SearchController controller) {
              return {
                "aggregations": {
                  "location": {
                    "geohash_grid": {"field": "location", "precision": 3},
                    "aggs": {
                      "top_earthquakes": {
                        "top_hits": {
                          "_source": {
                            "includes": ["magnitude"]
                          },
                          "size": 1
                        }
                      }
                    }
                  },
                }
              };
            },
            // [Optipnal] Calculate markers from aggregation data
            calculateMarkers: (SearchController controller) {
              List<Place> places = [];
              for (var bucket
                  in controller.aggregationData.raw?["buckets"] ?? []) {
                try {
                  var locationDecode = GeoHash(bucket["key"]);
                  var source = bucket["top_earthquakes"]?["hits"]?["hits"]?[0]
                      ?["_source"];
                  places.add(
                    Place(
                        id: bucket["key"],
                        position: LatLng(locationDecode.latitude(),
                            locationDecode.longitude()),
                        source: source),
                  );
                } catch (e) {}
              }
              return places;
            },
          ),
        ),
      ),
    );
  }
}
