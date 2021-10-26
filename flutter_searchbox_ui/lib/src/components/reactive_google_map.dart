import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils.dart';

/// It represents the marker representation of Elasticsearch response.
class Place with ClusterItem {
  /// Represents a unique identifier for each marker.
  final String id;

  /// Position of the marker.
  final LatLng position;

  /// Elasticsearch source object.
  final Map? source;

  // Use it to store any meta data.
  final Map? meta;

  Place({required this.id, required this.position, this.source, this.meta});

  @override
  LatLng get location => position;
}

class ReactiveMap extends StatefulWidget {
  final SearchController searchController;

  /// To draw the marker on Map when `showMarkerClusters` is not set to `true`.
  ///
  /// For example,
  /// ```dart
  ///   buildMarker: (Place place) {
  ///     return Marker(
  ///             markerId: MarkerId(place.id),
  ///             position: place.position
  ///     );
  ///   }
  /// ```dart
  final Marker Function(Place place)? buildMarker;

  /// Whether to aggregate and form a cluster of nearby markers. Defaults to `false`.
  ///
  /// The `buildClusterMarker` property is required when `showMarkerClusters` is `true`.
  final bool showMarkerClusters;

  /// To draw the marker on Map when `showMarkerClusters` is set to `true`.
  ///
  /// For example,
  /// ```dart
  /// // Function to build icon
  /// Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
  ///   if (kIsWeb) size = (size / 2).floor();
  ///
  ///   final PictureRecorder pictureRecorder = PictureRecorder();
  ///   final Canvas canvas = Canvas(pictureRecorder);
  ///   final Paint paint1 = Paint()..color = Colors.orange;
  ///   final Paint paint2 = Paint()..color = Colors.white;
  ///
  ///   canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
  ///   canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
  ///   canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);
  ///
  ///   if (text != null) {
  ///     TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
  ///    painter.text = TextSpan(
  ///      text: text,
  ///      style: TextStyle(
  ///         fontSize: size / 3,
  ///         color: Colors.white,
  ///         fontWeight: FontWeight.normal),
  ///   );
  ///   painter.layout();
  ///   painter.paint(
  ///     canvas,
  ///     Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
  ///   );
  ///  }
  ///
  ///  final img = await pictureRecorder.endRecording().toImage(size, size);
  ///  final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

  ///   return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  /// }
  ///
  /// // Define `buildClusterMarker` in [RecativeGoogleMap]
  /// buildClusterMarker: (Cluster cluster) async {
  ///     return Marker(
  ///             markerId: MarkerId(cluster.getId()),
  ///             position: cluster.location,
  ///             icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
  ///             text:
  ///               cluster.isMultiple ? cluster.count.toString() : null),
  ///      );
  ///  }
  /// ```dart
  final Future<Marker> Function(Cluster<Place> cluster)? buildClusterMarker;

  /// whether to auto center the map based on the geometric center of all the location markers. Defaults to false.
  final bool autoCenter;

  /// If set to `true` then it would update the results as the map bounds change. Defaults to `false`.
  final bool searchAsMove;

  /// The [ReactiveGoogleMap] component uses the ElasticSearch hits to render the markers, if you wish to override the default markers then ``calculateMarkers` prop is the way.
  ///
  /// The below example uses the `aggregations` data to calculate the markers.
  ///
  /// ```dart
  /// calculateMarkers: (SearchController controller) {
  ///             List<Place> places = [];
  ///             for (var bucket in controller.aggregationData?.data ?? []) {
  ///               try {
  ///                 // To get coordinates from GeoHash
  ///                 var locationDecode = GeoHash(bucket["_key"]);
  ///                 places.add(Place(
  ///                     name: bucket["_key"],
  ///                     id: bucket["_key"],
  ///                     position: LatLng(locationDecode.latitude(),
  ///                         locationDecode.longitude())));
  ///               } catch (e) {
  ///                 print(e);
  ///               }
  ///             }
  ///             return places;
  ///          }
  /// ```
  final List<Place> Function(SearchController searchController)?
      calculateMarkers;

  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [GoogleMapController] for this [GoogleMap].
  final MapCreatedCallback? onMapCreated;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if the map should show a toolbar when you interact with the map. Android only.
  final bool mapToolbarEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should show zoom controls. This includes two buttons
  /// to zoom in and zoom out. The default value is to show zoom controls.
  ///
  /// This is only supported on Android. And this field is silently ignored on iOS.
  final bool zoomControlsEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should be in lite mode. Android only.
  ///
  /// See https://developers.google.com/maps/documentation/android-sdk/lite#overview_of_lite_mode for more details.
  final bool liteModeEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// Padding to be set on map. See https://developers.google.com/maps/documentation/android-sdk/map#map_padding for more details.
  final EdgeInsets padding;

  /// Polygons to be placed on the map.
  final Set<Polygon> polygons;

  /// Polylines to be placed on the map.
  final Set<Polyline> polylines;

  /// Circles to be placed on the map.
  final Set<Circle> circles;

  /// Tile overlays to be placed on the map.
  final Set<TileOverlay> tileOverlays;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback? onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback? onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback? onCameraIdle;

  /// Called every time a [GoogleMap] is tapped.
  final ArgumentCallback<LatLng>? onTap;

  /// Called every time a [GoogleMap] is long pressed.
  final ArgumentCallback<LatLng>? onLongPress;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Enables or disables the traffic layer of the map
  final bool trafficEnabled;

  /// Enables or disables showing 3D buildings where available
  final bool buildingsEnabled;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  const ReactiveMap({
    Key? key,
    required this.searchController,
    this.showMarkerClusters = true,
    this.autoCenter = false,
    this.searchAsMove = false,
    this.calculateMarkers,
    this.buildMarker,
    this.buildClusterMarker,
    // Google map props
    required this.initialCameraPosition,
    this.mapType = MapType.normal,
    this.compassEnabled = true,
    this.onMapCreated,
    this.mapToolbarEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.liteModeEnabled = false,
    this.tiltGesturesEnabled = true,

    /// If no padding is specified default padding will be 0.
    this.padding = const EdgeInsets.all(0),
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.polygons = const <Polygon>{},
    this.polylines = const <Polyline>{},
    this.circles = const <Circle>{},
    this.onCameraMoveStarted,
    this.tileOverlays = const <TileOverlay>{},
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  })  : assert(!(showMarkerClusters && buildClusterMarker == null)),
        assert(!(!showMarkerClusters && buildMarker == null)),
        super(key: key);

  @override
  State<ReactiveMap> createState() => ReactiveMapState();
}

class ReactiveMapState extends State<ReactiveMap> {
  ClusterManager? _manager;

  final Completer<GoogleMapController> _controller = Completer();

  Set<Marker> markers = Set();

  List<Place> items = [];

  @override
  void initState() {
    if (widget.showMarkerClusters) {
      _manager = _initClusterManager();
    }
    // subscribe to the results and aggregationData to update markers
    widget.searchController.subscribeToStateChanges((changes) {
      setMarkers();
    }, ["results", "aggregationData"]);
    // trigger map query
    triggerQuery();
    super.initState();
  }

  ClusterManager _initClusterManager() {
    return ClusterManager<Place>(items, _updateMarkers,
        markerBuilder: _markerBuilder);
  }

  void triggerQuery() async {
    final GoogleMapController controller = await _controller.future;
    // apply map bounds
    LatLngBounds bounds = await controller.getVisibleRegion();

    String north = bounds.northeast.latitude.toString();
    String south = bounds.southwest.latitude.toString();
    String east = bounds.northeast.longitude.toString();
    String west = bounds.southwest.longitude.toString();

    var value = {
      "geoBoundingBox": {
        "topLeft": north + "," + west,
        "bottomRight": south + "," + east,
      }
    };
    widget.searchController.setValue(value,
        options: Options(
          triggerDefaultQuery: true,
        ));
  }

  void setMarkers() async {
    List<Place> items = [];
    if (widget.calculateMarkers != null) {
      items = widget.calculateMarkers!(widget.searchController);
    } else {
      // update markers
      for (var hit in widget.searchController.results?.data ?? []) {
        if (hit[widget.searchController.dataField] != null) {
          Location? location =
              getLocationObject(hit[widget.searchController.dataField]);
          if (location != null) {
            items.add(Place(
                id: hit["_id"],
                source: hit,
                position: LatLng(location.Lat, location.Lng)));
          }
        }
      }
    }

    if (widget.showMarkerClusters) {
      _manager?.setItems(items);
    } else {
      // set markers to map
      Set<Marker> markers = {};
      // populate markers
      for (var item in items) {
        markers.add(widget.buildMarker!(item));
      }
      _updateMarkers(markers);
    }

    // Change the camera position to first hit
    if (items.isNotEmpty && widget.autoCenter) {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(
              items[0].position.latitude, items[0].position.longitude))));
    }
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      this.markers = markers;
    });
  }

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        return widget.buildClusterMarker!(cluster);
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GoogleMap(
      mapType: widget.mapType,
      initialCameraPosition: widget.initialCameraPosition,
      markers: markers,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        _manager?.setMapId(controller.mapId);
        // invoke prop
        if (widget.onMapCreated != null) {
          widget.onMapCreated!(controller);
        }
      },
      onCameraMove: (CameraPosition cameraPosition) {
        _manager?.onCameraMove(cameraPosition);
        if (widget.onCameraMove != null) {
          widget.onCameraMove!(cameraPosition);
        }
      },
      onCameraIdle: () {
        if (widget.searchAsMove) {
          triggerQuery();
        }
        _manager?.updateMap();
        // invoke prop
        if (widget.onCameraIdle != null) {
          widget.onCameraIdle!();
        }
      },
      compassEnabled: widget.compassEnabled,
      mapToolbarEnabled: widget.mapToolbarEnabled,
      cameraTargetBounds: widget.cameraTargetBounds,
      minMaxZoomPreference: widget.minMaxZoomPreference,
      rotateGesturesEnabled: widget.rotateGesturesEnabled,
      scrollGesturesEnabled: widget.scrollGesturesEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      zoomGesturesEnabled: widget.zoomGesturesEnabled,
      liteModeEnabled: widget.liteModeEnabled,
      tiltGesturesEnabled: widget.tiltGesturesEnabled,
      padding: widget.padding,
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      indoorViewEnabled: widget.indoorViewEnabled,
      trafficEnabled: widget.trafficEnabled,
      buildingsEnabled: widget.buildingsEnabled,
      polygons: widget.polygons,
      polylines: widget.polylines,
      circles: widget.circles,
      onCameraMoveStarted: widget.onCameraMoveStarted,
      tileOverlays: widget.tileOverlays,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      gestureRecognizers: widget.gestureRecognizers,
    ));
  }
}

class _ReactiveGoogleMapState extends State<ReactiveGoogleMap> {
  @override
  Widget build(BuildContext context) {
    return SearchWidgetConnector(
      id: widget.id,
      builder: (context, searchController) {
        return ReactiveMap(
          searchController: searchController,
          // map specific
          showMarkerClusters: widget.showMarkerClusters,
          autoCenter: widget.autoCenter,
          searchAsMove: widget.searchAsMove,
          calculateMarkers: widget.calculateMarkers,
          buildMarker: widget.buildMarker,
          buildClusterMarker: widget.buildClusterMarker,
          // google map specific
          mapType: widget.mapType,
          initialCameraPosition: widget.initialCameraPosition,
          onMapCreated: widget.onMapCreated,
          onCameraMove: widget.onCameraMove,
          onCameraIdle: widget.onCameraIdle,
          compassEnabled: widget.compassEnabled,
          mapToolbarEnabled: widget.mapToolbarEnabled,
          cameraTargetBounds: widget.cameraTargetBounds,
          minMaxZoomPreference: widget.minMaxZoomPreference,
          rotateGesturesEnabled: widget.rotateGesturesEnabled,
          scrollGesturesEnabled: widget.scrollGesturesEnabled,
          zoomControlsEnabled: widget.zoomControlsEnabled,
          zoomGesturesEnabled: widget.zoomGesturesEnabled,
          liteModeEnabled: widget.liteModeEnabled,
          tiltGesturesEnabled: widget.tiltGesturesEnabled,
          padding: widget.padding,
          myLocationEnabled: widget.myLocationEnabled,
          myLocationButtonEnabled: widget.myLocationButtonEnabled,
          indoorViewEnabled: widget.indoorViewEnabled,
          trafficEnabled: widget.trafficEnabled,
          buildingsEnabled: widget.buildingsEnabled,
          polygons: widget.polygons,
          polylines: widget.polylines,
          circles: widget.circles,
          onCameraMoveStarted: widget.onCameraMoveStarted,
          tileOverlays: widget.tileOverlays,
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          gestureRecognizers: widget.gestureRecognizers,
        );
      },
      subscribeTo: widget.subscribeTo,
      // Avoid fetching query for each open/close action instead call it manually
      triggerQueryOnInit: false,
      shouldListenForChanges: widget.shouldListenForChanges,
      destroyOnDispose: widget.destroyOnDispose,
      index: widget.index,
      url: widget.url,
      credentials: widget.credentials,
      headers: widget.headers,
      appbaseConfig: widget.appbaseConfig,
      type: QueryType.geo,
      react: widget.react,
      queryFormat: widget.queryFormat,
      dataField: widget.dataField,
      categoryField: widget.categoryField,
      categoryValue: widget.categoryValue,
      nestedField: widget.nestedField,
      from: widget.from,
      size: widget.size,
      sortBy: widget.sortBy,
      // Initialize with default value
      value: widget.value,
      aggregationField: widget.aggregationField,
      aggregationSize: widget.aggregationSize,
      after: widget.after,
      includeNullValues: widget.includeNullValues,
      includeFields: widget.includeFields,
      excludeFields: widget.excludeFields,
      fuzziness: widget.fuzziness,
      searchOperators: widget.searchOperators,
      highlight: widget.highlight,
      highlightField: widget.highlightField,
      customHighlight: widget.customHighlight,
      interval: widget.interval,
      aggregations: widget.aggregations,
      showMissing: widget.showMissing,
      missingLabel: widget.missingLabel,
      defaultQuery: widget.defaultQuery,
      customQuery: widget.customQuery,
      enableSynonyms: widget.enableSynonyms,
      selectAllLabel: widget.selectAllLabel,
      pagination: widget.pagination,
      queryString: widget.queryString,
      enablePopularSuggestions: widget.enablePopularSuggestions,
      maxPopularSuggestions: widget.maxPopularSuggestions,
      showDistinctSuggestions: widget.showDistinctSuggestions,
      preserveResults: widget.preserveResults,
      clearOnQueryChange: widget.clearOnQueryChange,
      results: widget.results,
      transformRequest: widget.transformRequest,
      transformResponse: widget.transformResponse,
      distinctField: widget.distinctField,
      distinctFieldConfig: widget.distinctFieldConfig,
      beforeValueChange: widget.beforeValueChange,
      onValueChange: widget.onValueChange,
      onResults: widget.onResults,
      onAggregationData: widget.onAggregationData,
      onError: widget.onError,
      onRequestStatusChange: widget.onRequestStatusChange,
      onQueryChange: widget.onQueryChange,
    );
  }
}

/// It creates a data-driven map UI component using Google Maps. It is the key component for building map based experiences.

/// Example uses:
/// - showing a map of user checkins by city and topics for powering discovery based experiences.
/// - displaying restaurants filtered by a nearby distance query on a map.
///
/// Follow the installation steps mentioned at [here](https://pub.dev/packages/google_maps_flutter).
class ReactiveGoogleMap extends StatefulWidget {
  /// This property allows to define a list of properties of [SearchController] class which can trigger the re-build when any changes happen.
  ///
  /// For example, if `subscribeTo` is defined as `['results']` then it'll only update the UI when results property would change.
  final List<String>? subscribeTo;

  /// It can be used to prevent the default query execution at the time of initial build.
  ///
  /// Defaults to `true`.
  final bool? triggerQueryOnInit;

  /// It can be used to prevent state updates.
  ///
  /// Defaults to `true`. If set to `false` then no rebuild would be performed.
  final bool? shouldListenForChanges;

  /// If set to `false` then after dispose the component will not get removed from seachbase context i.e can actively participate in query generation.
  ///
  /// Defaults to `true`.
  final bool? destroyOnDispose;

  /// A unique identifier of the component, can be referenced in other widgets' `react` prop to reactively update data.
  final String id;

  /// Refers to an index of the Elasticsearch cluster.
  ///
  /// If not defined, then value will be inherited from [SearchBaseProvider].
  /// `Note:` Multiple indexes can be connected to Elasticsearch by specifying comma-separated index names.
  final String? index;

  /// URL for the Elasticsearch cluster.
  ///
  /// If not defined, then value will be inherited from [SearchBaseProvider].
  final String? url;

  /// Basic Auth credentials if required for authentication purposes.
  ///
  /// It should be a string of the format `username:password`. If you are using an appbase.io cluster, you will find credentials under the `Security > API credentials` section of the appbase.io dashboard.
  /// If you are not using an appbase.io cluster, credentials may not be necessary - although having open access to your Elasticsearch cluster is not recommended.
  /// If not defined, then value will be inherited from [SearchBaseProvider].
  final String? credentials;

  /// Set custom headers to be sent with each server request as key/value pairs.
  ///
  /// If not defined then value will be inherited from [SearchBaseProvider].
  final Map<String, String>? headers;

  /// It allows you to customize the analytics experience when appbase.io is used as a backend.
  ///
  /// If not defined then value will be inherited from [SearchBaseProvider].
  final AppbaseSettings? appbaseConfig;

  /// It is useful for components whose data view should reactively update when on or more dependent components change their states.
  ///
  /// For example, a widget to display the results can depend on the search widget to filter the results.
  ///  -   **key** `string`
  ///      one of `and`, `or`, `not` defines the combining clause.
  ///      -   **and** clause implies that the results will be filtered by matches from **all** of the associated widget states.
  ///      -   **or** clause implies that the results will be filtered by matches from **at least one** of the associated widget states.
  ///      -   **not** clause implies that the results will be filtered by an **inverse** match of the associated widget states.
  ///  -   **value** `string or Array or Object`
  ///      -   `string` is used for specifying a single widget by its `id`.
  ///      -   `Array` is used for specifying multiple components by their `id`.
  ///      -   `Object` is used for nesting other key clauses.

  /// An example of a `react` clause where all three clauses are used and values are `Object`, `Array` and `string`.

  ///  ```dart
  /// {
  ///		'and': {
  ///			'or': ['CityComp', 'TopicComp'],
  ///			'not': 'BlacklistComp',
  ///		},
  ///	}
  /// ```

  /// Here, we are specifying that the results should update whenever one of the blacklist items is not present and simultaneously any one of the city or topics matches.
  final Map<String, dynamic>? react;

  /// Sets the query format, can be **or** or **and**.
  ///
  /// Defaults to **or**.
  ///
  /// -   **or** returns all the results matching **any** of the search query text's parameters. For example, searching for "bat man" with **or** will return all the results matching either "bat" or "man".
  /// -   On the other hand with **and**, only results matching both "bat" and "man" will be returned. It returns the results matching **all** of the search query text's parameters.
  final String? queryFormat;

  /// The index field(s) to be connected to the component’s UI view.
  ///
  /// It accepts an `List<String>` in addition to `<String>`, which is useful for searching across multiple fields with or without field weights.
  ///
  /// Field weights allow weighted search for the index fields. A higher number implies a higher relevance weight for the corresponding field in the search results.
  /// You can define the `dataField` property as a `List<Map>` of to set the field weights. The object must have the `field` and `weight` keys.
  /// For example,
  /// ```dart
  /// [
  ///   {
  ///     'field': 'original_title',
  ///     'weight': 1
  ///   },
  ///   {
  ///     'field': 'original_title.search',
  ///     'weight': 3
  ///   },
  /// ]
  /// ```
  final dynamic dataField;

  /// Index field mapped to the category value.
  final String? categoryField;

  /// This is the selected category value. It is used for informing the search result.
  final String? categoryValue;

  /// Sets the `nested` field path that allows an array of objects to be indexed in a way that can be queried independently of each other.
  ///
  /// Applicable only when dataField's mapping is of `nested` type.
  final String? nestedField;

  /// To define from which page to start the results, it is important to implement pagination.
  final int? from;

  /// Number of suggestions and results to fetch per request.
  final int? size;

  /// Sorts the results by either [SortType.asc], [SortType.desc] or [SortType.count] order.
  ///
  /// Please note that the [SortType.count] is only applicable for [QueryType.term] type of search widgets.
  final SortType? sortBy;

  /// Represents the value for a particular [QueryType].
  ///
  /// Depending on the query type, the value format would differ.
  /// You can refer to the different value formats over [here](https://docs.appbase.io/docs/search/reactivesearch-api/reference#value).
  final dynamic value;

  /// It enables you to get `DISTINCT` results (useful when you are dealing with sessions, events, and logs type data).
  ///
  /// It utilizes [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) which are newly introduced in ES v6 and offer vast performance benefits over a traditional terms aggregation.
  final String? aggregationField;

  /// To set the number of buckets to be returned by aggregations.
  ///
  /// > Note: This is a new feature and only available for appbase versions >= 7.41.0.
  final int? aggregationSize;

  /// This property can be used to implement the pagination for `aggregations`.
  ///
  /// We use the [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) of `Elasticsearch` to execute the aggregations' query,
  /// the response of composite aggregations includes a key named `after_key` which can be used to fetch the next set of aggregations for the same query.
  /// You can read more about the pagination for composite aggregations at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html#_pagination).
  final Map? after;

  /// If you have sparse data or documents or items not having the value in the specified field or mapping, then this prop enables you to show that data.
  final bool? includeNullValues;

  // It allows to define fields to be included in search results.
  final List<String>? includeFields;

  // It allows to define fields to be excluded in search results.
  final List<String>? excludeFields;

  /// Useful for showing the correct results for an incorrect search parameter by taking the fuzziness into account.
  ///
  /// For example, with a substitution of one character, `fox` can become `box`.
  /// Read more about it in the elastic search https://www.elastic.co/guide/en/elasticsearch/guide/current/fuzziness.html.
  final dynamic fuzziness;

  /// If set to `true`, then you can use special characters in the search query to enable the advanced search.
  ///
  /// Defaults to `false`.
  /// You can read more about this property at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-simple-query-string-query.html).
  final bool? searchOperators;

  /// To define whether highlighting should be enabled in the returned results.
  ///
  /// Defaults to `false`.
  final bool? highlight;

  /// If highlighting is enabled, this property allows specifying the fields which should be returned with the matching highlights.
  ///
  /// When not specified, it defaults to applying highlights on the field(s) specified in the **dataField** property.
  /// It can be of type `String` or `List<String>`.
  final dynamic highlightField;

  /// It can be used to set the custom highlight settings.
  ///
  /// You can read the `Elasticsearch` docs for the highlight options at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-highlighting.html).
  final Map? customHighlight;

  /// To set the histogram bar interval for [QueryType.range] type of widgets, applicable when [aggregations](/docs/search/reactivesearch-api/reference/#aggregations) value is set to `["histogram"]`.
  ///
  /// Defaults to `Math.ceil((range.end - range.start) / 100) || 1`.
  final int? interval;

  /// It helps you to utilize the built-in aggregations for [QueryType.range] type of widgets directly, valid values are:
  /// -   `max`: to retrieve the maximum value for a `dataField`,
  /// -   `min`: to retrieve the minimum value for a `dataField`,
  /// -   `histogram`: to retrieve the histogram aggregations for a particular `interval`
  final List<String>? aggregations;

  /// When set to `true` then it also retrieves the aggregations for missing fields.
  ///
  /// Defaults to `false`.
  final bool? showMissing;

  /// It allows you to specify a custom label to show when [showMissing](/docs/search/reactivesearch-api/reference/#showmissing) is set to `true`.
  ///
  /// Defaults to `N/A`.
  final String? missingLabel;

  /// It is a callback function that takes the [SearchController] instance as parameter and **returns** the data query to be applied to the source component, as defined in Elasticsearch Query DSL, which doesn't get leaked to other components.
  ///
  /// In simple words, `defaultQuery` is used with data-driven components to impact their own data.
  /// It is meant to modify the default query which is used by a component to render the UI.
  ///
  ///  Some of the valid use-cases are:
  ///
  ///  -   To modify the query to render the `suggestions` or `results` in [QueryType.search] type of components.
  ///  -   To modify the `aggregations` in [QueryType.term] type of components.
  ///
  ///  For example, in a [QueryType.term] type of component showing a list of cities, you may only want to render cities belonging to `India`.
  ///
  ///```dart
  /// Map (SearchController searchController) => ({
  ///   		'query': {
  ///   			'terms': {
  ///   				'country': ['India'],
  ///   			},
  ///   		},
  ///   	}
  ///   )
  ///```
  final Map Function(SearchController searchController)? defaultQuery;

  /// It takes [SearchController] instance as parameter and **returns** the query to be applied to the dependent widgets by `react` prop, as defined in Elasticsearch Query DSL.
  ///
  /// For example, the following example has two components **search-widget**(to render the suggestions) and **result-widget**(to render the results).
  /// The **result-widget** depends on the **search-widget** to update the results based on the selected suggestion.
  /// The **search-widget** has the `customQuery` prop defined that will not affect the query for suggestions(that is how `customQuery` is different from `defaultQuery`)
  /// but it'll affect the query for **result-widget** because of the `react` dependency on **search-widget**.
  ///
  /// ```dart
  /// SearchWidgetConnector(
  ///   id: "search-widget",
  ///   dataField: ["original_title", "original_title.search"],
  ///   customQuery: (SearchController searchController) => ({
  ///     'timeout': '1s',
  ///      'query': {
  ///       'match_phrase_prefix': {
  ///         'fieldName': {
  ///           'query': 'hello world',
  ///           'max_expansions': 10,
  ///         },
  ///       },
  ///     },
  ///   })
  /// )
  ///
  /// SearchWidgetConnector(
  ///   id: "result-widget",
  ///   dataField: "original_title",
  ///   react: {
  ///    'and': ['search-component']
  ///   }
  /// )
  /// ```
  final Map Function(SearchController searchController)? customQuery;

  /// This property can be used to control (enable/disable) the synonyms behavior for a particular query.
  ///
  /// Defaults to `true`, if set to `false` then fields having `.synonyms` suffix will not affect the query.
  final bool? enableSynonyms;

  /// This property allows you to add a new property in the list with a particular value in such a way that
  /// when selected i.e `value` is similar/contains to that label(`selectAllLabel`) then [QueryType.term] query will make sure that
  /// the `field` exists in the `results`.
  final String? selectAllLabel;

  /// This property allows you to implement the `pagination` for [QueryType.term] type of queries.
  ///
  /// If `pagination` is set to `true` then appbase will use the [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) of Elasticsearch
  /// instead of [terms aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html).
  final bool? pagination;

  /// If set to `true` than it allows you to create a complex search that includes wildcard characters, searches across multiple fields, and more.
  ///
  /// Defaults to `false`.
  /// Read more about it [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html).
  final bool? queryString;

  /// It can be useful to curate search suggestions based on actual search queries that your users are making.
  ///
  /// Defaults to `false`. You can read more about it over [here](https://docs.appbase.io/docs/analytics/popular-suggestions).
  final bool? enablePopularSuggestions;

  /// It can be used to configure the size of popular suggestions.
  ///
  /// The default size is `5`.
  final int? maxPopularSuggestions;

  /// To display one suggestion per document.
  ///
  /// If set to `false` multiple suggestions may show up for the same document as the searched value might appear in multiple fields of the same document,
  /// this is true only if you have configured multiple fields in `dataField` prop. Defaults to `true`.
  ///
  ///  **Example** if you have `showDistinctSuggestions` is set to `false` and have the following configurations
  ///
  ///  ```dart
  ///  // Your document:
  ///  {
  ///  	"name": "Warn",
  ///  	"address": "Washington"
  ///  }
  ///  // SearchWidgetConnector:
  ///  dataField: ['name', 'address']
  ///
  ///  // Search Query:
  ///  "wa"
  ///  ```

  ///  Then there will be 2 suggestions from the same document
  ///  as we have the search term present in both the fields
  ///  specified in `dataField`.
  ///
  ///  ```
  ///  Warn
  ///  Washington
  ///  ```
  final bool? showDistinctSuggestions;

  /// It set to `true` then it preserves the previously loaded results data that can be used to persist pagination or implement infinite loading.
  final bool? preserveResults;

  /// When set to `true`, the controller's value would get cleared whenever the query of a watcher controller(which is set via react prop) changes.
  ///
  /// The default value is `false`
  final bool clearOnQueryChange;

  /// A list of map to pre-populate results with static data.
  ///
  /// Data must be in form of Elasticsearch response.
  final List<Map>? results;

  // callbacks

  /// Enables transformation of network request before execution.
  ///
  /// This function will give you the request object as the param and expect an updated request in return, for execution.
  /// For example, we will add the `credentials` property in the request using `transformRequest`.
  ///
  /// ```dart
  /// Future (Map request) =>
  ///      Future.value({
  ///          ...request,
  ///          'credentials': 'include',
  ///      })
  ///  }
  /// ```
  final TransformRequest? transformRequest;

  /// Enables transformation of search network response before rendering them.
  ///
  /// It is an asynchronous function which will accept an Elasticsearch response object as param and is expected to return an updated response as the return value.
  /// For example:
  /// ```dart
  /// Future (Map elasticsearchResponse) async {
  ///	 final ids = elasticsearchResponse['hits']['hits'].map(item => item._id);
  ///	 final extraInformation = await getExtraInformation(ids);
  ///	 final hits = elasticsearchResponse['hits']['hits'].map(item => {
  ///		final extraInformationItem = extraInformation.find(
  ///			otherItem => otherItem._id === item._id,
  ///		);
  ///		return Future.value({
  ///			...item,
  ///			...extraInformationItem,
  ///		};
  ///	}));
  ///
  ///	return Future.value({
  ///		...elasticsearchResponse,
  ///		'hits': {
  ///			...elasticsearchResponse.hits,
  ///			hits,
  ///		},
  ///	});
  ///}
  /// ```
  final TransformResponse? transformResponse;

  /// This prop returns only the distinct value documents for the specified field.
  /// It is equivalent to the DISTINCT clause in SQL. It internally uses the collapse feature of Elasticsearch.
  /// You can read more about it over here - https://www.elastic.co/guide/en/elasticsearch/reference/current/collapse-search-results.html
  final String? distinctField;

  /// This prop allows specifying additional options to the distinctField prop.
  /// Using the allowed DSL, one can specify how to return K distinct values (default value of K=1),
  /// sort them by a specific order, or return a second level of distinct values.
  /// distinctFieldConfig object corresponds to the inner_hits key's DSL.
  /// You can read more about it over here - https://www.elastic.co/guide/en/elasticsearch/reference/current/collapse-search-results.html
  ///
  /// For example,
  /// ```dart
  /// SearchBox(
  ///   ...
  ///   distinctField: 'authors.keyword',
  ///   distinctFieldConfig: {
  ///     'inner_hits': {
  ///       'name': 'other_books',
  ///       'size': 5,
  ///       'sort': [
  ///         {'timestamp': 'asc'}
  ///       ],
  ///     },
  ///   'max_concurrent_group_searches': 4, },
  /// )
  /// ```
  final Map? distinctFieldConfig;

  /* ---- callbacks to create the side effects while querying ----- */

  /// It is a callback function which accepts component's future **value** as a
  /// parameter and **returns** a [Future].
  ///
  /// It is called every-time before a component's value changes.
  /// The promise, if and when resolved, triggers the execution of the component's query and if rejected, kills the query execution.
  /// This method can act as a gatekeeper for query execution, since it only executes the query after the provided promise has been resolved.
  ///
  /// For example:
  /// ```dart
  /// Future (value) {
  ///   // called before the value is set
  ///   // returns a [Future]
  ///   // update state or component props
  ///   return Future.value(value);
  ///   // or Future.error()
  /// }
  /// ```
  final Future Function(String value)? beforeValueChange;

  /* ------------- change events -------------------------------- */

  /// It is called every-time the widget's value changes.
  ///
  /// This property is handy in cases where you want to generate a side-effect on value selection.
  /// For example: You want to show a pop-up modal with the valid discount coupon code when a user searches for a product in a [SearchBox].
  final void Function(String next, {String prev})? onValueChange;

  /// It can be used to listen for the `results` changes.
  final void Function(List<Map> next, {List<Map> prev})? onResults;

  /// It can be used to listen for the `aggregationData` property changes.
  final void Function(List<Map> next, {List<Map> prev})? onAggregationData;

  /// It gets triggered in case of an error occurs while fetching results.
  final void Function(dynamic error)? onError;

  /// It can be used to listen for the request status changes.
  final void Function(String next, {String prev})? onRequestStatusChange;

  /// It is a callback function which accepts widget's **prevQuery** and **nextQuery** as parameters.
  ///
  /// It is called everytime the widget's query changes.
  /// This property is handy in cases where you want to generate a side-effect whenever the widget's query would change.
  final void Function(Map next, {Map prev})? onQueryChange;

  // Google Map Props
  /// Callback method for when the map is ready to be used.
  ///
  /// Used to receive a [GoogleMapController] for this [GoogleMap].
  final MapCreatedCallback? onMapCreated;

  /// The initial position of the map's camera.
  final CameraPosition initialCameraPosition;

  /// True if the map should show a compass when rotated.
  final bool compassEnabled;

  /// True if the map should show a toolbar when you interact with the map. Android only.
  final bool mapToolbarEnabled;

  /// Geographical bounding box for the camera target.
  final CameraTargetBounds cameraTargetBounds;

  /// Type of map tiles to be rendered.
  final MapType mapType;

  /// Preferred bounds for the camera zoom level.
  ///
  /// Actual bounds depend on map data and device.
  final MinMaxZoomPreference minMaxZoomPreference;

  /// True if the map view should respond to rotate gestures.
  final bool rotateGesturesEnabled;

  /// True if the map view should respond to scroll gestures.
  final bool scrollGesturesEnabled;

  /// True if the map view should show zoom controls. This includes two buttons
  /// to zoom in and zoom out. The default value is to show zoom controls.
  ///
  /// This is only supported on Android. And this field is silently ignored on iOS.
  final bool zoomControlsEnabled;

  /// True if the map view should respond to zoom gestures.
  final bool zoomGesturesEnabled;

  /// True if the map view should be in lite mode. Android only.
  ///
  /// See https://developers.google.com/maps/documentation/android-sdk/lite#overview_of_lite_mode for more details.
  final bool liteModeEnabled;

  /// True if the map view should respond to tilt gestures.
  final bool tiltGesturesEnabled;

  /// Padding to be set on map. See https://developers.google.com/maps/documentation/android-sdk/map#map_padding for more details.
  final EdgeInsets padding;

  /// Polygons to be placed on the map.
  final Set<Polygon> polygons;

  /// Polylines to be placed on the map.
  final Set<Polyline> polylines;

  /// Circles to be placed on the map.
  final Set<Circle> circles;

  /// Tile overlays to be placed on the map.
  final Set<TileOverlay> tileOverlays;

  /// Called when the camera starts moving.
  ///
  /// This can be initiated by the following:
  /// 1. Non-gesture animation initiated in response to user actions.
  ///    For example: zoom buttons, my location button, or marker clicks.
  /// 2. Programmatically initiated animation.
  /// 3. Camera motion initiated in response to user gestures on the map.
  ///    For example: pan, tilt, pinch to zoom, or rotate.
  final VoidCallback? onCameraMoveStarted;

  /// Called repeatedly as the camera continues to move after an
  /// onCameraMoveStarted call.
  ///
  /// This may be called as often as once every frame and should
  /// not perform expensive operations.
  final CameraPositionCallback? onCameraMove;

  /// Called when camera movement has ended, there are no pending
  /// animations and the user has stopped interacting with the map.
  final VoidCallback? onCameraIdle;

  /// Called every time a [GoogleMap] is tapped.
  final ArgumentCallback<LatLng>? onTap;

  /// Called every time a [GoogleMap] is long pressed.
  final ArgumentCallback<LatLng>? onLongPress;

  /// True if a "My Location" layer should be shown on the map.
  ///
  /// This layer includes a location indicator at the current device location,
  /// as well as a My Location button.
  /// * The indicator is a small blue dot if the device is stationary, or a
  /// chevron if the device is moving.
  /// * The My Location button animates to focus on the user's current location
  /// if the user's location is currently known.
  ///
  /// Enabling this feature requires adding location permissions to both native
  /// platforms of your app.
  /// * On Android add either
  /// `<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />`
  /// or `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`
  /// to your `AndroidManifest.xml` file. `ACCESS_COARSE_LOCATION` returns a
  /// location with an accuracy approximately equivalent to a city block, while
  /// `ACCESS_FINE_LOCATION` returns as precise a location as possible, although
  /// it consumes more battery power. You will also need to request these
  /// permissions during run-time. If they are not granted, the My Location
  /// feature will fail silently.
  /// * On iOS add a `NSLocationWhenInUseUsageDescription` key to your
  /// `Info.plist` file. This will automatically prompt the user for permissions
  /// when the map tries to turn on the My Location layer.
  final bool myLocationEnabled;

  /// Enables or disables the my-location button.
  ///
  /// The my-location button causes the camera to move such that the user's
  /// location is in the center of the map. If the button is enabled, it is
  /// only shown when the my-location layer is enabled.
  ///
  /// By default, the my-location button is enabled (and hence shown when the
  /// my-location layer is enabled).
  ///
  /// See also:
  ///   * [myLocationEnabled] parameter.
  final bool myLocationButtonEnabled;

  /// Enables or disables the indoor view from the map
  final bool indoorViewEnabled;

  /// Enables or disables the traffic layer of the map
  final bool trafficEnabled;

  /// Enables or disables showing 3D buildings where available
  final bool buildingsEnabled;

  /// Which gestures should be consumed by the map.
  ///
  /// It is possible for other gesture recognizers to be competing with the map on pointer
  /// events, e.g if the map is inside a [ListView] the [ListView] will want to handle
  /// vertical drags. The map will claim gestures that are recognized by any of the
  /// recognizers on this list.
  ///
  /// When this set is empty, the map will only handle pointer events for gestures that
  /// were not claimed by any other gesture recognizer.
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;

  // Map specific props

  /// To draw the marker on Map when `showMarkerClusters` is not set to `true`.
  ///
  /// For example,
  /// ```dart
  ///   buildMarker: (Place place) {
  ///     return Marker(
  ///             markerId: MarkerId(place.id),
  ///             position: place.position
  ///     );
  ///   }
  /// ```dart
  final Marker Function(Place place)? buildMarker;

  /// Whether to aggregate and form a cluster of nearby markers. Defaults to `false`.
  ///
  /// The `buildClusterMarker` property is required when `showMarkerClusters` is `true`.
  final bool showMarkerClusters;

  /// To draw the marker on Map when `showMarkerClusters` is set to `true`.
  ///
  /// For example,
  /// ```dart
  /// // Function to build icon
  /// Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
  ///   if (kIsWeb) size = (size / 2).floor();
  ///
  ///   final PictureRecorder pictureRecorder = PictureRecorder();
  ///   final Canvas canvas = Canvas(pictureRecorder);
  ///   final Paint paint1 = Paint()..color = Colors.orange;
  ///   final Paint paint2 = Paint()..color = Colors.white;
  ///
  ///   canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
  ///   canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
  ///   canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);
  ///
  ///   if (text != null) {
  ///     TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
  ///    painter.text = TextSpan(
  ///      text: text,
  ///      style: TextStyle(
  ///         fontSize: size / 3,
  ///         color: Colors.white,
  ///         fontWeight: FontWeight.normal),
  ///   );
  ///   painter.layout();
  ///   painter.paint(
  ///     canvas,
  ///     Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
  ///   );
  ///  }
  ///
  ///  final img = await pictureRecorder.endRecording().toImage(size, size);
  ///  final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

  ///   return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  /// }
  ///
  /// // Define `buildClusterMarker` in [RecativeGoogleMap]
  /// buildClusterMarker: (Cluster cluster) async {
  ///     return Marker(
  ///             markerId: MarkerId(cluster.getId()),
  ///             position: cluster.location,
  ///             icon: await _getMarkerBitmap(cluster.isMultiple ? 125 : 75,
  ///             text:
  ///               cluster.isMultiple ? cluster.count.toString() : null),
  ///      );
  ///  }
  /// ```dart
  final Future<Marker> Function(Cluster<Place> cluster)? buildClusterMarker;

  /// whether to auto center the map based on the geometric center of all the location markers. Defaults to false.
  final bool autoCenter;

  /// If set to `true` then it would update the results as the map bounds change. Defaults to `false`.
  final bool searchAsMove;

  /// The [ReactiveGoogleMap] component uses the ElasticSearch hits to render the markers, if you wish to override the default markers then ``calculateMarkers` prop is the way.
  ///
  /// The below example uses the `aggregations` data to calculate the markers.
  ///
  /// ```dart
  /// calculateMarkers: (SearchController controller) {
  ///             List<Place> places = [];
  ///             for (var bucket in controller.aggregationData?.data ?? []) {
  ///               try {
  ///                 // To get coordinates from GeoHash
  ///                 var locationDecode = GeoHash(bucket["_key"]);
  ///                 places.add(Place(
  ///                     name: bucket["_key"],
  ///                     id: bucket["_key"],
  ///                     position: LatLng(locationDecode.latitude(),
  ///                         locationDecode.longitude())));
  ///               } catch (e) {
  ///                 print(e);
  ///               }
  ///             }
  ///             return places;
  ///          }
  /// ```
  final List<Place> Function(SearchController searchController)?
      calculateMarkers;

  const ReactiveGoogleMap({
    Key? key,
    required this.id,
    this.showMarkerClusters = true,
    this.autoCenter = false,
    this.searchAsMove = false,
    this.calculateMarkers,
    this.buildMarker,
    this.buildClusterMarker,
    this.subscribeTo,
    this.triggerQueryOnInit,
    this.shouldListenForChanges,
    this.destroyOnDispose,
    // properties to configure search component
    this.credentials,
    this.index,
    this.url,
    this.appbaseConfig,
    this.transformRequest,
    this.transformResponse,
    this.headers,
    this.react,
    this.queryFormat,
    this.dataField,
    this.categoryField,
    this.categoryValue,
    this.nestedField,
    this.from,
    this.size,
    this.sortBy,
    this.aggregationField,
    this.aggregationSize,
    this.after,
    this.includeNullValues,
    this.includeFields,
    this.excludeFields,
    this.fuzziness,
    this.searchOperators,
    this.highlight,
    this.highlightField,
    this.customHighlight,
    this.interval,
    this.aggregations,
    this.missingLabel,
    this.showMissing,
    this.enableSynonyms,
    this.selectAllLabel,
    this.pagination,
    this.queryString,
    this.defaultQuery,
    this.customQuery,
    this.beforeValueChange,
    this.onValueChange,
    this.onResults,
    this.onAggregationData,
    this.onError,
    this.onRequestStatusChange,
    this.onQueryChange,
    this.enablePopularSuggestions,
    this.maxPopularSuggestions,
    this.showDistinctSuggestions,
    this.preserveResults,
    this.clearOnQueryChange = false,
    this.value,
    this.results,
    this.distinctField,
    this.distinctFieldConfig,

    // Google map props
    required this.initialCameraPosition,
    this.mapType = MapType.normal,
    this.compassEnabled = true,
    this.onMapCreated,
    this.mapToolbarEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.zoomControlsEnabled = true,
    this.zoomGesturesEnabled = true,
    this.liteModeEnabled = false,
    this.tiltGesturesEnabled = true,

    /// If no padding is specified default padding will be 0.
    this.padding = const EdgeInsets.all(0),
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = true,
    this.indoorViewEnabled = false,
    this.trafficEnabled = false,
    this.buildingsEnabled = true,
    this.polygons = const <Polygon>{},
    this.polylines = const <Polyline>{},
    this.circles = const <Circle>{},
    this.onCameraMoveStarted,
    this.tileOverlays = const <TileOverlay>{},
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.onLongPress,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
  }) : super(key: key);

  @override
  _ReactiveGoogleMapState createState() => _ReactiveGoogleMapState();
}
