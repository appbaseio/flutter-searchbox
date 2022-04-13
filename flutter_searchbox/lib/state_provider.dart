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

  SearchControllerState({
    this.aggregationData,
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
    this.customQuery,
  });
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
  final Map<String, List<KeysToSubscribe>>? subscribeTo;

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
    if (build == null && onChange == null) {
      throw ("Atleast one, build or onChange prop is required.");
    }
  }

  @override
  _StateProviderState createState() => _StateProviderState();
}

class _StateProviderState extends State<StateProvider> {
  final Map<String, SearchControllerState> _controllersState = {};
  // _widgetSubscribers will be used for unsubscrbing in destroy lifecycle
  final Map<String, Map<String, dynamic>> _widgetSubscribers = {};

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance
        ?.addPostFrameCallback((_) => subscribeToProperties());
  }

  Map<String, SearchController> get activeWidgets {
    return SearchBaseProvider.of(context).getActiveWidgets();
  }

  @override
  void dispose() {
    // Remove subscriptions
    for (var id in _widgetSubscribers.keys) {
      _widgetSubscribers[id]!['controller'].unsubscribeToStateChanges(
          _widgetSubscribers[id]!['subscriberFunction']);
    }
    super.dispose();
  }

  void subscribeToProperties() {
    print('subscripotion initiated');
    try {
      final activeWidgets = this.activeWidgets;
      for (var id in activeWidgets.keys) {
        if (widget.subscribeTo != null && widget.subscribeTo!.isNotEmpty) {
          if (widget.subscribeTo?.keys.contains(id) == false) {
            continue;
          }
        }
        final componentInstance = activeWidgets[id];
        var subscribedKeys;
        if (widget.subscribeTo?.keys.contains(id) == true) {
          subscribedKeys = widget.subscribeTo![id];
        } else {
          subscribedKeys = KeysToSubscribe.values;
        }
        print('$subscribedKeys------- ${subscribedKeys.contains(KeysToSubscribe.Results.name)}');
        void subscriberMethod(changes) {
          void applyChanges() {
            final prevState = {..._controllersState};

            _controllersState[id] = SearchControllerState(
              results: subscribedKeys.contains(KeysToSubscribe.Results)
                  ? changes[KeysToSubscribe.Results.name]?.next
                  : null,
              aggregationData:
                  subscribedKeys.contains(KeysToSubscribe.AggregationData)
                      ? changes[KeysToSubscribe.AggregationData.name]?.next
                      : null,
              requestStatus:
                  subscribedKeys.contains(KeysToSubscribe.RequestStatus)
                      ? changes[KeysToSubscribe.RequestStatus.name]?.next
                      : null,
              error: subscribedKeys.contains(KeysToSubscribe.Error)
                  ? changes[KeysToSubscribe.Error.name]?.next
                  : null,
              value: subscribedKeys.contains(KeysToSubscribe.Value)
                  ? changes[KeysToSubscribe.Value.name]?.next
                  : null,
              query: subscribedKeys.contains(KeysToSubscribe.Query)
                  ? changes[KeysToSubscribe.Query.name]?.next
                  : null,
              dataField: subscribedKeys.contains(KeysToSubscribe.DataField)
                  ? changes[KeysToSubscribe.DataField.name]?.next
                  : null,
              size: subscribedKeys.contains(KeysToSubscribe.Size)
                  ? changes[KeysToSubscribe.Size.name]?.next
                  : null,
              from: subscribedKeys.contains(KeysToSubscribe.From)
                  ? changes[KeysToSubscribe.From.name]?.next
                  : null,
              fuzziness: subscribedKeys.contains(KeysToSubscribe.Fuzziness)
                  ? changes[KeysToSubscribe.Fuzziness.name]?.next
                  : null,
              includeFields:
                  subscribedKeys.contains(KeysToSubscribe.IncludeFields)
                      ? changes[KeysToSubscribe.IncludeFields.name]?.next
                      : null,
              excludeFields:
                  subscribedKeys.contains(KeysToSubscribe.ExcludeFields)
                      ? changes[KeysToSubscribe.ExcludeFields.name]?.next
                      : null,
              sortBy: subscribedKeys.contains(KeysToSubscribe.SortBy)
                  ? changes[KeysToSubscribe.SortBy.name]?.next
                  : null,
              react: subscribedKeys.contains(KeysToSubscribe.React)
                  ? changes[KeysToSubscribe.React.name]?.next
                  : null,
              defaultQuery:
                  subscribedKeys.contains(KeysToSubscribe.DefaultQuery)
                      ? changes[KeysToSubscribe.DefaultQuery.name]?.next
                      : null,
              customQuery:
                  subscribedKeys.contains(KeysToSubscribe.CustomQuery)
                      ? changes[KeysToSubscribe.CustomQuery.name]?.next
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
        }

        _widgetSubscribers[id] = {
          "controller": componentInstance,
          "subscriberFunction": subscriberMethod,
        };

        componentInstance?.subscribeToStateChanges(
            subscriberMethod, subscribedKeys);
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
