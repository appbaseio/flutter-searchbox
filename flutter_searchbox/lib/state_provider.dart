import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'package:searchbase/searchbase.dart';

class SearchControllerState {
  final Aggregations? aggregationData;
  final Results? results;
  final RequestStatus? requestStatus;
  final dynamic error;
  final dynamic value;
  final List<Map<dynamic, dynamic>>? query;
  final dynamic dataField;
  final int? size;
  final int? from;
  final dynamic fuzziness;
  final List<String>? includeFields;
  final List<String>? excludeFields;
  final SortType? sortBy;
  final Map<String, dynamic>? react;
  final Map Function(SearchController searchController)? defaultQuery;
  final Map Function(SearchController searchController)? customQuery;

  SearchControllerState(
      {this.aggregationData,
      this.results,
      this.requestStatus,
      this.error,
      this.value,
      this.query,
      this.dataField,
      this.size,
      this.from,
      this.fuzziness,
      this.includeFields,
      this.excludeFields,
      this.sortBy,
      this.react,
      this.defaultQuery,
      this.customQuery,});

}

/// It allows you to access the current state of your widgets along with the search results.
/// For instance, you can use this component to create results/no results or query/no query pages.
///
/// Examples Use(s):
///    - perform side-effects based on the results states of various widgets.
///    - render custom UI based on the current state of app.
class StateProvider extends StatefulWidget {
  /// A map of widget ids and list of properties to subscribe to.
  /// [Optional]
  /// This property allows users to select the widgets for which
  /// they want to listen to the state changes.
  /// For example,
  /// ```dart
  /// StateProvider(
  ///   ...
  ///   subscribeTo: {
  ///     'result-component': ['results', 'from']
  ///   },
  ///   ...
  /// )
  /// ```
  final Map<String, List<String>>? subscribeTo;

  /// Callback function,  is a callback function called when the search state changes
  /// and accepts the previous and next search state as arguments.
  /// For example,
  /// ```dart
  /// StateProvider(
  ///   ...
  ///   onChange: (prevState, nextState) {
  ///         // do something here
  ///     },
  ///   ...
  /// )
  /// ```
  final void Function(Map<String, SearchControllerState>,
      Map<String, SearchControllerState>)? onChange;

  /// It is used for rendering a custom UI based on updated state
  /// For example,
  /// ```dart
  /// StateProvider(
  ///   ...
  ///   build: (controllerState) {
  ///     return Text(
  ///       'Total results on screen--- ${controllerState["result-widget"]?.results?.data?.length ?? ''} ',
  ///       style: TextStyle(
  ///         fontSize: 19.0,
  ///         color: Colors.red,
  ///       ),
  ///     );
  ///   },
  ///   ...
  /// )
  /// ```
  final Widget Function(Map<String, SearchControllerState>)? build;

  StateProvider({
    this.subscribeTo,
    this.onChange,
    this.build,
    Key? key,
  }) : super(key: key) {
    if (subscribeTo == null) {
      throw ("subscribeTo property is required.");
    }
    if ((subscribeTo is Map) && subscribeTo!.isEmpty) {
      throw ("subscribeTo property cannot be empty.");
    }
    
  }

  @override
  _StateProviderState createState() => _StateProviderState();
}

class _StateProviderState extends State<StateProvider> {
  final Map<String, SearchControllerState> _controllersState = {};
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => subscribeToProperties());
  }

  Map<String, SearchController> get activeWidgets {
    return SearchBaseProvider.of(context).getActiveWidgets();
  }

  void subscribeToProperties() {
    print('subscripotion initiated');
    try {
      final activeWidgets = this.activeWidgets;
      for (var id in activeWidgets.keys) {
        if (widget.subscribeTo != null && widget.subscribeTo!.isNotEmpty) {
          if (!widget.subscribeTo!.keys.contains(id)) {
            continue;
          }
        }
        final componentInstance = activeWidgets[id];
        // // the block below is added to initialize the values
        // // after that, subscription method takes charge to update values
        // if (mounted) {
        //   setState(() {
        //     _controllersState[id] = SearchControllerState(
        //       results: widget.subscribeTo![id]!.contains('results')
        //           ? componentInstance!.results
        //           : null,
        //       aggregationData:
        //           widget.subscribeTo![id]!.contains('aggregationData')
        //               ? componentInstance!.aggregationData
        //               : null,
        //       requestStatus: widget.subscribeTo![id]!.contains('requestStatus')
        //           ? componentInstance!.requestStatus
        //           : null,
        //       error: widget.subscribeTo![id]!.contains('error')
        //           ? componentInstance!.error
        //           : null,
        //       value: widget.subscribeTo![id]!.contains('value')
        //           ? componentInstance!.value
        //           : null,
        //       query: widget.subscribeTo![id]!.contains('query')
        //           ? componentInstance!.query
        //           : null,
        //       dataField: widget.subscribeTo![id]!.contains('dataField')
        //           ? componentInstance!.dataField
        //           : null,
        //       size: widget.subscribeTo![id]!.contains('size')
        //           ? componentInstance!.size
        //           : null,
        //       from: widget.subscribeTo![id]!.contains('from')
        //           ? componentInstance!.from
        //           : null,
        //       fuzziness: widget.subscribeTo![id]!.contains('fuzziness')
        //           ? componentInstance!.fuzziness
        //           : null,
        //       includeFields: widget.subscribeTo![id]!.contains('includeFields')
        //           ? componentInstance!.includeFields
        //           : null,
        //       excludeFields: widget.subscribeTo![id]!.contains('excludeFields')
        //           ? componentInstance!.excludeFields
        //           : null,
        //       sortBy: widget.subscribeTo![id]!.contains('sortBy')
        //           ? componentInstance!.sortBy
        //           : null,
        //       react: widget.subscribeTo![id]!.contains('react')
        //           ? componentInstance!.react
        //           : null,
        //       defaultQuery: widget.subscribeTo![id]!.contains('defaultQuery')
        //           ? componentInstance!.defaultQuery
        //           : null,
        //       customQuery: widget.subscribeTo![id]!.contains('customQuery')
        //           ? componentInstance!.customQuery
        //           : null,
        //     );
        //   });
        // }
        // initialization block ends
        componentInstance?.subscribeToStateChanges((changes) {
          void applyChanges() {
            final prevState = {..._controllersState};

            _controllersState[id] = SearchControllerState(
              results: widget.subscribeTo![id]!.contains('results')
                  ? changes['results']?.next
                  : null,
              aggregationData:
                  widget.subscribeTo![id]!.contains('aggregationData')
                      ? changes['aggregationData']?.next
                      : null,
              requestStatus: widget.subscribeTo![id]!.contains('requestStatus')
                  ? changes['requestStatus']?.next
                  : null,
              error: widget.subscribeTo![id]!.contains('error')
                  ? changes['error']?.next
                  : null,
              value: widget.subscribeTo![id]!.contains('value') 
                  ? changes['value']?.next
                  : null,
              query: widget.subscribeTo![id]!.contains('query')
                  ? changes['query']?.next
                  : null,
              dataField: widget.subscribeTo![id]!.contains('dataField')
                  ? changes['dataField']?.next
                  : null,
              size: widget.subscribeTo![id]!.contains('size')
                  ? changes['size']?.next
                  : null,
              from: widget.subscribeTo![id]!.contains('from')
                  ? changes['from']?.next
                  : null,
              fuzziness: widget.subscribeTo![id]!.contains('fuzziness')
                  ? changes['fuzziness']?.next
                  : null,
              includeFields: widget.subscribeTo![id]!.contains('includeFields')
                  ? changes['includeFields']?.next
                  : null,
              excludeFields: widget.subscribeTo![id]!.contains('excludeFields')
                  ? changes['excludeFields']?.next
                  : null,
              sortBy: widget.subscribeTo![id]!.contains('sortBy')
                  ? changes['sortBy']?.next
                  : null,
              react: widget.subscribeTo![id]!.contains('react')
                  ? changes['react']?.next
                  : null,
              defaultQuery: widget.subscribeTo![id]!.contains('defaultQuery')
                  ? changes['defaultQuery']?.next
                  : null,
              customQuery: widget.subscribeTo![id]!.contains('customQuery')
                  ? changes['customQuery']?.next
                  : null,
            );

            if (widget.onChange is Function) {
              widget.onChange!(prevState, _controllersState);
            }
          }

          if (mounted) {
            setState(() {
              applyChanges();
            });
          } else {
            applyChanges();
          }
        }, widget.subscribeTo![id] ?? []);
      }
    } catch (e) {
      print('error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.build != null) {
      return widget.build!(_controllersState);
    }
    return SizedBox.shrink();
  }
}
