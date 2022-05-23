import 'package:searchbase/searchbase.dart';
import 'types.dart';
import 'searchcontroller.dart';
import 'constants.dart';

/// It stores the state of the SearchController at any time.
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
/// For instance, you can use this class to previous and the next(latest) state of your app widget tree.
///
/// Examples Use(s):
///    - perform side-effects based on the results states of various widgets.
///
/// For example,
/// ```dart
/// SearchStateController(
///  subscribeTo: {
///    'author-filter': [KeysToSubscribe.Value]
///  },
///  onChange: (next, prev) {
///    print("Next state");
///    print(next['author-filter']?.value;
///    print("Prev state");
///    print(prev['author-filter']?.value);
///  },
///  searchBase: searchBaseInstance,
/// )
/// ```dart
class SearchStateController {
  /// A map of widget ids and list of properties to subscribe to.
  ///
  /// This property allows users to select the widgets for which
  /// they want to listen to the state changes.
  /// For example,
  /// ```dart
  /// StateProvider(
  ///   ...
  ///   subscribeTo: {
  ///     'result-component': [KeysToSubscribe.Results, KeysToSubscribe.From]
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
  ///   onChange: (nextState, prevState) {
  ///         // do something here
  ///     },
  ///   ...
  /// )
  /// ```
  final void Function(Map<String, SearchControllerState>,
      Map<String, SearchControllerState>)? onChange;

  /// It is the reference to the [SearchBase] instance of the app.
  final SearchBase searchBase;

  /// It holds the current state of the subscribed widgets.
  final Map<String, SearchControllerState> current = {};

  /// It holds the just-previous state of the subscribed widgets.
  final Map<String, SearchControllerState> previous = {};
  // _widgetSubscribers will be used for unsubscribing in destroy lifecycle
  final Map<String, Map<String, dynamic>> _widgetSubscribers = {};

  SearchStateController({
    this.subscribeTo,
    this.onChange,
    required this.searchBase,
  }) {
    subscribeToProperties();
  }

  void dispose() {
    // Remove subscriptions
    for (var id in _widgetSubscribers.keys) {
      _widgetSubscribers[id]!['controller'].unsubscribeToStateChanges(
          _widgetSubscribers[id]!['subscriberFunction']);
    }
    ;
  }

  Map<String, SearchController> get _activeWidgets {
    return searchBase.getActiveWidgets();
  }

  void subscribeToProperties() {
    try {
      final activeWidgets = this._activeWidgets;
      for (var id in activeWidgets.keys) {
        if (this.subscribeTo != null && this.subscribeTo!.isNotEmpty) {
          if (this.subscribeTo?.keys.contains(id) == false) {
            continue;
          }
        }
        final componentInstance = activeWidgets[id];
        var subscribedKeys;
        if (this.subscribeTo?.keys.contains(id) == true) {
          subscribedKeys = this.subscribeTo![id];
        } else {
          subscribedKeys = KeysToSubscribe.values;
        }

        /* hydrating the initial state, 
        handles an edge case like when StateProvider is used in a drawer */
        current[id] = SearchControllerState(
          results: subscribedKeys.contains(KeysToSubscribe.Results)
              ? componentInstance!.results
              : null,
          aggregationData:
              subscribedKeys.contains(KeysToSubscribe.AggregationData)
                  ? componentInstance!.aggregationData
                  : null,
          requestStatus: subscribedKeys.contains(KeysToSubscribe.RequestStatus)
              ? componentInstance!.requestStatus
              : null,
          error: subscribedKeys.contains(KeysToSubscribe.Error)
              ? componentInstance!.error
              : null,
          value: subscribedKeys.contains(KeysToSubscribe.Value)
              ? componentInstance!.value
              : null,
          query: subscribedKeys.contains(KeysToSubscribe.Query)
              ? componentInstance!.query
              : null,
          dataField: subscribedKeys.contains(KeysToSubscribe.DataField)
              ? componentInstance!.dataField
              : null,
          size: subscribedKeys.contains(KeysToSubscribe.Size)
              ? componentInstance!.size
              : null,
          from: subscribedKeys.contains(KeysToSubscribe.From)
              ? componentInstance!.from
              : null,
          fuzziness: subscribedKeys.contains(KeysToSubscribe.Fuzziness)
              ? componentInstance!.fuzziness
              : null,
          includeFields: subscribedKeys.contains(KeysToSubscribe.IncludeFields)
              ? componentInstance!.includeFields
              : null,
          excludeFields: subscribedKeys.contains(KeysToSubscribe.ExcludeFields)
              ? componentInstance!.excludeFields
              : null,
          sortBy: subscribedKeys.contains(KeysToSubscribe.SortBy)
              ? componentInstance!.sortBy
              : null,
          react: subscribedKeys.contains(KeysToSubscribe.React)
              ? componentInstance!.react
              : null,
          defaultQuery: subscribedKeys.contains(KeysToSubscribe.DefaultQuery)
              ? componentInstance!.defaultQuery
              : null,
          customQuery: subscribedKeys.contains(KeysToSubscribe.CustomQuery)
              ? componentInstance!.customQuery
              : null,
        );

        /* subscriberMethod to handle state changes */
        void subscriberMethod(ChangesController changes) {
          void applyChanges() {
            previous[id] = SearchControllerState(
              results: subscribedKeys.contains(KeysToSubscribe.Results)
                  ? changes.Results?.prev
                  : null,
              aggregationData:
                  subscribedKeys.contains(KeysToSubscribe.AggregationData)
                      ? changes.AggregationData?.prev
                      : null,
              requestStatus:
                  subscribedKeys.contains(KeysToSubscribe.RequestStatus)
                      ? changes.RequestStatus?.prev
                      : null,
              error: subscribedKeys.contains(KeysToSubscribe.Error)
                  ? changes.Error?.prev
                  : null,
              value: subscribedKeys.contains(KeysToSubscribe.Value)
                  ? changes.Value?.prev
                  : null,
              query: subscribedKeys.contains(KeysToSubscribe.Query)
                  ? changes.Query?.prev
                  : null,
              dataField: subscribedKeys.contains(KeysToSubscribe.DataField)
                  ? changes.DataField?.prev
                  : null,
              size: subscribedKeys.contains(KeysToSubscribe.Size)
                  ? changes.Size?.prev
                  : null,
              from: subscribedKeys.contains(KeysToSubscribe.From)
                  ? changes.From?.prev
                  : null,
              fuzziness: subscribedKeys.contains(KeysToSubscribe.Fuzziness)
                  ? changes.Fuzziness?.prev
                  : null,
              includeFields:
                  subscribedKeys.contains(KeysToSubscribe.IncludeFields)
                      ? changes.IncludeFields?.prev
                      : null,
              excludeFields:
                  subscribedKeys.contains(KeysToSubscribe.ExcludeFields)
                      ? changes.ExcludeFields?.prev
                      : null,
              sortBy: subscribedKeys.contains(KeysToSubscribe.SortBy)
                  ? changes.SortBy?.prev
                  : null,
              react: subscribedKeys.contains(KeysToSubscribe.React)
                  ? changes.React?.prev
                  : null,
              defaultQuery:
                  subscribedKeys.contains(KeysToSubscribe.DefaultQuery)
                      ? changes.DefaultQuery?.prev
                      : null,
              customQuery: subscribedKeys.contains(KeysToSubscribe.CustomQuery)
                  ? changes.CustomQuery?.prev
                  : null,
            );

            current[id] = SearchControllerState(
              results: subscribedKeys.contains(KeysToSubscribe.Results)
                  ? changes.Results?.next
                  : null,
              aggregationData:
                  subscribedKeys.contains(KeysToSubscribe.AggregationData)
                      ? changes.AggregationData?.next
                      : null,
              requestStatus:
                  subscribedKeys.contains(KeysToSubscribe.RequestStatus)
                      ? changes.RequestStatus?.next
                      : null,
              error: subscribedKeys.contains(KeysToSubscribe.Error)
                  ? changes.Error?.next
                  : null,
              value: subscribedKeys.contains(KeysToSubscribe.Value)
                  ? changes.Value?.next
                  : null,
              query: subscribedKeys.contains(KeysToSubscribe.Query)
                  ? changes.Query?.next
                  : null,
              dataField: subscribedKeys.contains(KeysToSubscribe.DataField)
                  ? changes.DataField?.next
                  : null,
              size: subscribedKeys.contains(KeysToSubscribe.Size)
                  ? changes.Size?.next
                  : null,
              from: subscribedKeys.contains(KeysToSubscribe.From)
                  ? changes.From?.next
                  : null,
              fuzziness: subscribedKeys.contains(KeysToSubscribe.Fuzziness)
                  ? changes.Fuzziness?.next
                  : null,
              includeFields:
                  subscribedKeys.contains(KeysToSubscribe.IncludeFields)
                      ? changes.IncludeFields?.next
                      : null,
              excludeFields:
                  subscribedKeys.contains(KeysToSubscribe.ExcludeFields)
                      ? changes.ExcludeFields?.next
                      : null,
              sortBy: subscribedKeys.contains(KeysToSubscribe.SortBy)
                  ? changes.SortBy?.next
                  : null,
              react: subscribedKeys.contains(KeysToSubscribe.React)
                  ? changes.React?.next
                  : null,
              defaultQuery:
                  subscribedKeys.contains(KeysToSubscribe.DefaultQuery)
                      ? changes.DefaultQuery?.next
                      : null,
              customQuery: subscribedKeys.contains(KeysToSubscribe.CustomQuery)
                  ? changes.CustomQuery?.next
                  : null,
            );

            if (this.onChange is Function) {
              this.onChange!(current, previous);
            }
          }

          applyChanges();
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
}
