import 'searchbase.dart';
import 'aggregations.dart';
import 'results.dart';
import 'types.dart';
import 'searchcontroller.dart';
import 'constants.dart';

/// It stores the state of the SearchController at any time.
class SearchControllerState {
  /// An object that contains the aggregations data for [QueryType.term] queries.
  final Aggregations? aggregationData;

  /// It is an object that represents the elasticsearch query response.
  final Results? results;

  /// It represents the current status of the request.
  final RequestStatus? requestStatus;

  /// Represents the error response returned by elasticsearch.
  final dynamic error;

  /// Represents the value for a particular [QueryType].
  ///
  /// Depending on the query type, the value format would differ.
  /// You can refer to the different value formats over [here](https://docs.appbase.io/docs/search/reactivesearch-api/reference#value).
  final dynamic value;

  /// Represents a map of reactivesearch queries associated with the widget.
  final List<Map<dynamic, dynamic>>? query;

  /// The index field(s) to be connected to the component’s UI view.
  ///
  /// It accepts a `List<String>` in addition to `<String>`, which is useful for searching across multiple fields with or without field weights.
  ///
  /// Field weights allow weighted search for the index fields. A higher number implies a higher relevance weight for the corresponding field in the search results.
  /// You can define the `dataField` property as a `List<Map>` to set the field weights. The object must have the `field` and `weight` keys.
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

  /// Number of suggestions and results to fetch per request.
  final int? size;

  /// To define from which page to start the results, it is important to implement pagination.
  final int? from;

  /// Useful for showing the correct results for an incorrect search parameter by taking the fuzziness into account.
  ///
  /// For example, with a substitution of one character, `fox` can become `box`.
  /// Read more about it in the Elasticsearch documentation: https://www.elastic.co/guide/en/elasticsearch/guide/current/fuzziness.html.
  final dynamic fuzziness;

  /// It allows to define fields to be included in search results.

  final List<String>? includeFields;

  /// It allows to define fields to be excluded in search results.
  final List<String>? excludeFields;

  /// Sorts the results by either [SortType.asc], [SortType.desc] or [SortType.count] order.
  ///
  /// Please note that the [SortType.count] is only applicable for [QueryType.term] type of search widgets.
  final SortType? sortBy;

  /// Here, we are specifying that the results should update whenever one of the blacklist items is not present and simultaneously any one of the city or topics matches.
  final Map<String, dynamic>? react;

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
/// For instance, you can use this class to access the previous and the next(latest) state of your app widget tree.
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
