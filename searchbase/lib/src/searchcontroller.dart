import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'base.dart';
import 'searchbase.dart';
import 'constants.dart';
import 'observable.dart';
import 'results.dart';
import 'aggregations.dart';
import 'types.dart';
import 'utils.dart';

// Represents the format of query response
class GenerateQueryResponse {
  List<Map> requestBody;
  List<String> orderOfQueries;
  GenerateQueryResponse(this.requestBody, this.orderOfQueries) {}
}

const suggestionQueryID = 'DataSearch__suggestions';

/// The [SearchController] class can be used to bind to different kinds of search UI widgets.
///
/// For example,
/// -   a category filter widget,
/// -   a search bar widget,
/// -   a price range widget,
/// -   a location filter widget,
/// -   a widget to render the search results.
class SearchController extends Base {
  http.Client? _httpClient = null;

  http.Client get httpClient {
    _httpClient ??= http.Client();
    return _httpClient!;
  }

  // RS API properties

  /// A unique identifier of the component, can be referenced in other widgets' `react` prop to reactively update data.
  String id;

  /// This property represents the type of the query which is defaults to [QueryType.search], valid values are [QueryType.search], [QueryType.term], [QueryType.range] & [QueryType.geo].
  ///
  /// You can read more [here](https://docs.appbase.io/docs/search/reactivesearch-api/implement#type-of-queries).
  QueryType? type;

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
  Map<String, dynamic>? react;

  /// Sets the query format, can be **or** or **and**.
  ///
  /// Defaults to **or**.
  ///
  /// -   **or** returns all the results matching **any** of the search query text's parameters. For example, searching for "bat man" with **or** will return all the results matching either "bat" or "man".
  /// -   On the other hand with **and**, only results matching both "bat" and "man" will be returned. It returns the results matching **all** of the search query text's parameters.
  String? queryFormat;

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
  dynamic dataField;

  /// Index field mapped to the category value.
  String? categoryField;

  /// This is the selected category value. It is used for informing the search result.
  String? categoryValue;

  /// Sets the `nested` field path that allows an array of objects to be indexed in a way that can be queried independently of each other.
  ///
  /// Applicable only when dataField's mapping is of `nested` type.
  String? nestedField;

  /// To define from which page to start the results, it is important to implement pagination.
  int? from;

  /// Number of suggestions and results to fetch per request.
  int? size;

  /// Sorts the results by either [SortType.asc], [SortType.desc] or [SortType.count] order.
  ///
  /// Please note that the [SortType.count] is only applicable for [QueryType.term] type of search widgets.
  SortType? sortBy;

  /// Represents the value for a particular [QueryType].
  ///
  /// Depending on the query type, the value format would differ.
  /// You can refer to the different value formats over [here](https://docs.appbase.io/docs/search/reactivesearch-api/reference#value).
  dynamic value;

  /// It enables you to get `DISTINCT` results (useful when you are dealing with sessions, events, and logs type data).
  ///
  /// It utilizes [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) which are newly introduced in ES v6 and offer vast performance benefits over a traditional terms aggregation.
  String? aggregationField;

  /// To set the number of buckets to be returned by aggregations.
  ///
  /// > Note: This is a new feature and only available for appbase versions >= 7.41.0.
  int? aggregationSize;

  /// This property can be used to implement the pagination for `aggregations`.
  ///
  /// We use the [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) of `Elasticsearch` to execute the aggregations' query,
  /// the response of composite aggregations includes a key named `after_key` which can be used to fetch the next set of aggregations for the same query.
  /// You can read more about the pagination for composite aggregations at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html#_pagination).
  Map? after;

  /// If you have sparse data or documents or items not having the value in the specified field or mapping, then this prop enables you to show that data.
  bool? includeNullValues;

  // It allows to define fields to be included in search results.
  List<String>? includeFields;

  // It allows to define fields to be excluded in search results.
  List<String>? excludeFields;

  /// Useful for showing the correct results for an incorrect search parameter by taking the fuzziness into account.
  ///
  /// For example, with a substitution of one character, `fox` can become `box`.
  /// Read more about it in the elastic search https://www.elastic.co/guide/en/elasticsearch/guide/current/fuzziness.html.
  dynamic fuzziness;

  /// If set to `true`, then you can use special characters in the search query to enable the advanced search.
  ///
  /// Defaults to `false`.
  /// You can read more about this property at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-simple-query-string-query.html).
  bool? searchOperators;

  /// To define whether highlighting should be enabled in the returned results.
  ///
  /// Defaults to `false`.
  bool? highlight;

  /// If highlighting is enabled, this property allows specifying the fields which should be returned with the matching highlights.
  ///
  /// When not specified, it defaults to applying highlights on the field(s) specified in the **dataField** property.
  /// It can be of type `String` or `List<String>`.
  dynamic highlightField;

  /// It can be used to set the custom highlight settings.
  ///
  /// You can read the `Elasticsearch` docs for the highlight options at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-highlighting.html).
  Map? customHighlight;

  /// To set the histogram bar interval for [QueryType.range] type of widgets, applicable when [aggregations](/docs/search/reactivesearch-api/reference/#aggregations) value is set to `["histogram"]`.
  ///
  /// Defaults to `Math.ceil((range.end - range.start) / 100) || 1`.
  int? interval;

  /// It helps you to utilize the built-in aggregations for [QueryType.range] type of widgets directly, valid values are:
  /// -   `max`: to retrieve the maximum value for a `dataField`,
  /// -   `min`: to retrieve the minimum value for a `dataField`,
  /// -   `histogram`: to retrieve the histogram aggregations for a particular `interval`
  List<String>? aggregations;

  /// When set to `true` then it also retrieves the aggregations for missing fields.
  ///
  /// Defaults to `false`.
  bool? showMissing;

  /// It allows you to specify a custom label to show when [showMissing](/docs/search/reactivesearch-api/reference/#showmissing) is set to `true`.
  ///
  /// Defaults to `N/A`.
  String? missingLabel;

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
  Map Function(SearchController searchController)? defaultQuery;

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
  Map Function(SearchController searchController)? customQuery;

  /// This property can be used to control (enable/disable) the synonyms behavior for a particular query.
  ///
  /// Defaults to `true`, if set to `false` then fields having `.synonyms` suffix will not affect the query.
  bool? enableSynonyms;

  /// This property allows you to add a new property in the list with a particular value in such a way that
  /// when selected i.e `value` is similar/contains to that label(`selectAllLabel`) then [QueryType.term] query will make sure that
  /// the `field` exists in the `results`.
  String? selectAllLabel;

  /// This property allows you to implement the `pagination` for [QueryType.term] type of queries.
  ///
  /// If `pagination` is set to `true` then appbase will use the [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) of Elasticsearch
  /// instead of [terms aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html).
  bool? pagination;

  /// If set to `true` than it allows you to create a complex search that includes wildcard characters, searches across multiple fields, and more.
  ///
  /// Defaults to `false`.
  /// Read more about it [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html).
  bool? queryString;

  /// It can be useful to curate search suggestions based on actual search queries that your users are making.
  ///
  /// Defaults to `false`. You can read more about it over [here](https://docs.appbase.io/docs/analytics/popular-suggestions).
  bool? enablePopularSuggestions;

  /// It can be used to configure the size of popular suggestions.
  ///
  /// The default size is `5`.
  int? maxPopularSuggestions;

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
  bool? showDistinctSuggestions;

  /// It set to `true` then it preserves the previously loaded results data that can be used to persist pagination or implement infinite loading.
  bool? preserveResults;

  /// It is an object that represents the elasticsearch query response.
  late Results results;

  /// Represents the error response returned by elasticsearch.
  dynamic error;

  /// When set to `true`, the dependent controller's (which is set via react prop) value would get cleared whenever the query changes.
  ///
  /// The default value is `false`
  bool? clearOnQueryChange;

  /// A subject to track state changes and update listeners.
  late Observable stateChanges;

  /// It represents the current status of the request.
  RequestStatus? requestStatus;

  /// An object that contains the aggregations data for [QueryType.term] queries.
  late Aggregations aggregationData;

  /// A list of recent searches as suggestions.
  List<Suggestion>? recentSearches;

  /// This prop returns only the distinct value documents for the specified field.
  /// It is equivalent to the DISTINCT clause in SQL. It internally uses the collapse feature of Elasticsearch.
  /// You can read more about it over here - https://www.elastic.co/guide/en/elasticsearch/reference/current/collapse-search-results.html
  String? distinctField;

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
  Map? distinctFieldConfig;

  /// This prop is used to set the timeout value for HTTP requests.
  /// Defaults to 30 seconds.
  Duration httpRequestTimeout;

  /// Configure whether the DSL query is generated with the compound clause of [CompoundClauseType.must] or [CompoundClauseType.filter]. If nothing is passed the default is to use [CompoundClauseType.must].
  /// Setting the compound clause to filter allows search engine to cache and allows for higher throughput in cases where scoring isn’t relevant (e.g. term, geo or range type of queries that act as filters on the data)
  ///
  /// This property only has an effect when the search engine is either elasticsearch or opensearch.
  /// > Note: `compoundClause` is supported with v8.16.0 (server) as well as with serverless search.
  ///
  ///   ///
  /// For example,
  /// ```dart
  /// SearchBox(
  ///   ...
  ///   compoundClause:  CompoundClauseType.filter
  /// )
  /// ```
  CompoundClauseType? compoundClause;

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
  Future Function(dynamic value)? beforeValueChange;

  /* ------------- change events -------------------------------- */

  /// It is called every-time the widget's value changes.
  ///
  /// This property is handy in cases where you want to generate a side-effect on value selection.
  /// For example: You want to show a pop-up modal with the valid discount coupon code when a user searches for a product in a [SearchController].
  void Function(dynamic next, {dynamic prev})? onValueChange;

  /// It can be used to listen for the `results` changes.
  void Function(Results next, {Results prev})? onResults;

  /// It can be used to listen for the `aggregationData` property changes.
  void Function(Aggregations next, {Aggregations prev})? onAggregationData;

  /// It gets triggered in case of an error while fetching results.
  void Function(dynamic error)? onError;

  /// It can be used to listen for the request status changes.
  void Function(String? next, {String? prev})? onRequestStatusChange;

  /// It is a callback function which accepts widget's **nextQuery** and **prevQuery** as parameters.
  ///
  /// It is called everytime the widget's query changes.
  /// This property is handy in cases where you want to generate a side-effect whenever the widget's query would change.
  void Function(List<Map>? next, {List<Map>? prev})? onQueryChange;

  /* ------ Private properties only for the internal use ----------- */
  SearchBase? _parent;

  // Counterpart of the query
  List<Map>? _query;

  // query search ID
  String? _queryId;

  int? _lastUsedDefaultQueryTimeStamp;

  int? _lastUsedCustomQueryTimeStamp;

  SearchController(
    String index,
    String url,
    String credentials,
    String this.id, {
    AppbaseSettings? appbaseConfig,
    TransformRequest? transformRequest,
    TransformResponse? transformResponse,
    Map<String, String>? headers,
    this.type,
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
    // this.onMicStatusChange,
    this.enablePopularSuggestions,
    this.maxPopularSuggestions,
    this.showDistinctSuggestions,
    this.preserveResults,
    this.distinctField,
    this.distinctFieldConfig,
    this.value,
    this.clearOnQueryChange = false,
    this.httpRequestTimeout = const Duration(seconds: 30),
    this.compoundClause,
  }) : super(index, url, credentials,
            appbaseConfig: appbaseConfig,
            transformRequest: transformRequest,
            transformResponse: transformResponse,
            headers: headers) {
    if (id == "") {
      throw (ErrorMessages[InvalidComponentId]);
    }
    // dataField can't be an array for queries other than search
    if (type != null && type != QueryType.search && dataField is List<String>) {
      throw (ErrorMessages[DataFieldAsArray]);
    }
    // Initialize the state changes observable
    this.stateChanges = new Observable();

    this.results = new Results([]);

    this.aggregationData = new Aggregations(data: []);

    if (value != null) {
      this.setValue(value, options: new Options());
    } else {
      this.value = value;
    }
  }

  /// returns the last query executed by the widget
  List<Map>? get query {
    return this._query;
  }

  /// Useful for getting the status of the API, whether it has been executed or not
  bool get requestPending {
    return this.requestStatus == RequestStatus.PENDING;
  }

  /// represnts the current appbase settings
  AppbaseSettings? get appbaseSettings {
    return this.appbaseConfig;
  }

  /// can be used to get the parsed suggestions from the `results`.
  /// If `enablePopularSuggestions` property is set to `true` then the popular suggestions will get appended at the bottom with a property in `source` object named `_popular_suggestion` as `true`.
  List<Suggestion> get suggestions {
    if (this.type != null && this.type != QueryType.search) {
      return [];
    }
    List<String> fields = getNormalizedField(this.dataField);
    if (fields.length == 0 && this.results.data.length > 0) {
      // Extract fields from _source
      fields = this.results.data[0].keys.toList();
    }
    if (this.enablePopularSuggestions == true) {
      // extract suggestions from popular suggestion fields too
      fields = [...fields, ...popularSuggestionFields];
    }
    return getSuggestions(
        fields, this.results.data, this.value, this.showDistinctSuggestions);
  }

  /// to get the raw query based on the current state
  Map get componentQuery {
    Map query = {
      'id': id,
      'type': type.value,
      'dataField': getNormalizedField(dataField),
      'react': react,
      'highlight': highlight,
      'highlightField': getNormalizedField(highlightField),
      'fuzziness': fuzziness,
      'searchOperators': searchOperators,
      'includeFields': includeFields,
      'excludeFields': excludeFields,
      'size': size,
      'from': from,
      'queryFormat': queryFormat,
      'sortBy': sortBy.value,
      'fieldWeights': getNormalizedWeights(this.dataField),
      'includeNullValues': includeNullValues,
      'aggregationField': aggregationField,
      'aggregationSize': aggregationSize,
      'categoryField': categoryField,
      'missingLabel': missingLabel,
      'showMissing': showMissing,
      'nestedField': nestedField,
      'interval': interval,
      'customHighlight': customHighlight,
      'customQuery': customQuery != null ? customQuery!(this) : null,
      'defaultQuery': defaultQuery != null ? defaultQuery!(this) : null,
      'value': value,
      'categoryValue': categoryValue,
      'after': after,
      'aggregations': aggregations,
      'enableSynonyms': enableSynonyms,
      'selectAllLabel': selectAllLabel,
      'pagination': pagination,
      'queryString': queryString,
      'index': this.index,
      'distinctField': distinctField,
      'distinctFieldConfig': distinctFieldConfig,
      'compoundClause': compoundClause,
    };
    query.removeWhere((key, value) => key == null || value == null);
    return query;
  }

  /// represents the query id to track Appbase analytics
  String get queryId {
    // Get query ID from parent(searchbase) if exist
    if (this._parent != null && this._parent!.queryId != "") {
      return this._parent!.queryId!;
    }
    // For single components just return the queryId from the component
    if (this._queryId != "") {
      return this._queryId!;
    }
    return '';
  }

  /// to get the search index for the request url
  String _getSearchIndex(bool isPopularSuggestionsAPI) {
    var index = this.index;
    if (isPopularSuggestionsAPI) {
      index = '.suggestions';
    } else if (this._parent?.index != null) {
      index = this._parent!.index;
    }
    return index;
  }

  /* -------- Public methods -------- */

  /// can be used to set the `dataField` property
  void setDataField(dynamic dataField, {Options? options}) {
    final prev = this.dataField;
    this.dataField = dataField;
    this.applyOptions(options, KeysToSubscribe.DataField, prev, dataField);
  }

  /// can be used to set the `value` property
  void setValue(dynamic value, {Options? options}) async {
    try {
      if (this.beforeValueChange != null) {
        var val = await beforeValueChange!(value);
        this._performUpdate(val, options);
      } else {
        this._performUpdate(value, options);
      }

      // Check if options contain a completer and complete it if it exists
      options?.completer?.complete();
    } catch (e) {
      // If any error occurs, throw an exception for a failed operation
      throw Exception('Error in setValue: $e');
    }
  }

  void setValueSilent(dynamic value, {Options? options}) {
    this._performUpdate(value, options);
  }

  /// sets the `size` property
  void setSize(int size, {Options? options}) {
    final prev = this.size;
    this.size = size;
    this.applyOptions(options, KeysToSubscribe.Size, prev, this.size);
  }

  /// sets the `from` property that is helpful to implement pagination
  void setFrom(int from, {Options? options}) {
    final prev = this.from;
    this.from = from;
    this.applyOptions(options, KeysToSubscribe.From, prev, this.from);
  }

  /// sets the `fuzziness` property
  void setFuzziness(dynamic fuzziness, {Options? options}) {
    final prev = this.fuzziness;
    this.fuzziness = fuzziness;
    this.applyOptions(options, KeysToSubscribe.Fuzziness, prev, this.fuzziness);
  }

  /// can be used to set the `includeFields` property
  void setIncludeFields(List<String> includeFields, {Options? options}) {
    final prev = this.includeFields;
    this.includeFields = includeFields;
    this.applyOptions(
        options, KeysToSubscribe.IncludeFields, prev, includeFields);
  }

  /// can be used to set the `excludeFields` property
  void setExcludeFields(List<String> excludeFields, {Options? options}) {
    final prev = this.excludeFields;
    this.excludeFields = excludeFields;
    this.applyOptions(
        options, KeysToSubscribe.ExcludeFields, prev, excludeFields);
  }

  /// to set `soryBy` property
  void setSortBy(SortType sortBy, {Options? options}) {
    final prev = this.sortBy;
    this.sortBy = sortBy;
    this.applyOptions(options, KeysToSubscribe.SortBy, prev, sortBy);
  }

  /// to update `react` property
  void setReact(Map<String, dynamic> react, {Options? options}) {
    final prev = this.react;
    this.react = react;
    this.applyOptions(options, KeysToSubscribe.React, prev, react);
  }

  /// to update `defaultQuery` property
  void setDefaultQuery(
      Map<dynamic, dynamic> Function(SearchController) defaultQuery,
      {Options? options}) {
    final prev = this.defaultQuery;
    this.defaultQuery = defaultQuery;
    this.applyOptions(
        options, KeysToSubscribe.DefaultQuery, prev, defaultQuery);
  }

  /// sets the `customQuery` property
  void setCustomQuery(
      Map<dynamic, dynamic> Function(SearchController) customQuery,
      {Options? options}) {
    final prev = this.customQuery;
    this.customQuery = customQuery;
    this.applyOptions(options, KeysToSubscribe.CustomQuery, prev, customQuery);
  }

  /// can be used to set the `after` property, which is useful while implementing pagination with [QueryType.term] type of widgets
  void setAfter(Map? after, {Options? options}) {
    final prev = this.after;
    this.after = after;
    this.aggregationData.setAfterKey(after);
    this.applyOptions(options, KeysToSubscribe.After, prev, after);
  }

  /// to record click analytics of a search request.
  ///
  /// Set the `isSuggestionClick` to `true` to record suggestion click.
  /// For example,
  /// ```dart
  /// searchController.recordClick({
  ///   'cf827a07-60a6-43ef-ab93-e1f8e1e3e1a8': 2 // [_id]: click_position
  /// }, true);
  /// ```
  Future recordClick(Map<String, int> objects,
      {bool isSuggestionClick = false}) async {
    return this.click(objects, queryId: this.queryId);
  }

  /// to record a search conversion.
  ///
  /// For example,
  /// ```dart
  /// searchController.recordConversions(['cf827a07-60a6-43ef-ab93-e1f8e1e3e1a8']);
  /// ```
  Future recordConversions(List<String> objects) async {
    return this.conversion(objects, queryId: this.queryId);
  }

  /// can be used to execute the default query for a particular widget.
  /// For examples,
  /// - to display the `suggestions` or `results` for a [QueryType.search] type of widget,
  /// - to display the filter options(`aggregations`) for a [QueryType.term] type of widget
  Future triggerDefaultQuery({Option? options}) async {
    // To prevent duplicate queries
    if (isEqual(this._query, this.componentQuery)) {
      return Future<bool>.value(true);
    }
    var currentTimeStamp = DateTime.now().microsecondsSinceEpoch;
    try {
      this.updateQuery();
      var searchbaseInstance = this._parent;
      var shouldAddToWaitList = searchbaseInstance!.shouldAddRequestToWaitList(
        this.id,
        true,
        this.query,
      );
      if (!shouldAddToWaitList) {
        this._lastUsedDefaultQueryTimeStamp = currentTimeStamp;
        this.setRequestStatus(RequestStatus.PENDING, options: options);
        final results = await this._fetchRequest({
          'query': this.query is List ? this.query : [this.query],
          'settings': this.appbaseSettings?.toJSON()
        }, false);
        if (currentTimeStamp == this._lastUsedDefaultQueryTimeStamp) {
          final prev = this.results.clone();
          final Map? rawResults =
              results[this.id] is Map ? results[this.id] : {};
          void afterResponse() {
            if (rawResults!['aggregations'] != null) {
              this.handleAggregationResponse(rawResults['aggregations'],
                  options: new Options(stateChanges: options?.stateChanges));
            }
            this.setRequestStatus(RequestStatus.INACTIVE, options: options);
            this.applyOptions(new Options(stateChanges: options?.stateChanges),
                KeysToSubscribe.Results, prev, this.results);
          }

          if ((this.type == null || this.type == QueryType.search) &&
              this.enablePopularSuggestions == true) {
            final rawPopularSuggestions =
                await this._fetchRequest(this._getSuggestionsQuery(), true);
            final popularSuggestionsData =
                rawPopularSuggestions[suggestionQueryID];
            // Merge popular suggestions as the top suggestions
            if (popularSuggestionsData != null &&
                popularSuggestionsData['hits'] != null &&
                popularSuggestionsData['hits']['hits'] != null &&
                rawResults != null &&
                rawResults['hits'] != null &&
                rawResults['hits']['hits'] != null) {
              rawResults['hits']['hits'] = [
                ...rawResults['hits']['hits'],
                ...(popularSuggestionsData['hits']['hits'] as List)
                    .map((hit) => ({
                          ...hit,
                          // Set the popular suggestion tag for suggestion hits
                          '_popular_suggestion': true
                        }))
                    .toList(),
              ];
            }
            this._appendResults(rawResults);
            afterResponse();
          } else {
            this._appendResults(rawResults);
            afterResponse();
          }
          return Future.value(rawResults);
        }
      }
    } catch (err) {
      if (currentTimeStamp == this._lastUsedDefaultQueryTimeStamp) {
        return _handleError(err);
      }
    }
  }

  /// can be used to execute queries for the dependent/watcher components.
  Future triggerCustomQuery({Option? options}) async {
    var shouldAddToWaitList = this._parent!.shouldAddRequestToWaitList(
          this.id,
          true,
          this.query,
        );
    if (!shouldAddToWaitList) {
      var currentTimeStamp = DateTime.now().microsecondsSinceEpoch;
      this._lastUsedCustomQueryTimeStamp = currentTimeStamp;
      // Generate query again after resetting changes
      final generatedQuery = this.generateQuery();
      if (generatedQuery.requestBody.length != 0) {
        if (isEqual(this._query, generatedQuery.requestBody)) {
          return Future.value(true);
        }
        // set the request loading to true for all the requests
        generatedQuery.orderOfQueries.forEach((id) {
          final componentInstance = this._parent!.getSearchWidget(id);
          if (componentInstance != null) {
            componentInstance._lastUsedDefaultQueryTimeStamp = currentTimeStamp;
            // Reset `from` and `after` values
            componentInstance.setFrom(0,
                options: new Options(
                    triggerDefaultQuery: false,
                    triggerCustomQuery: false,
                    stateChanges: true));
            componentInstance.setAfter(null,
                options: new Options(
                    triggerDefaultQuery: false,
                    triggerCustomQuery: false,
                    stateChanges: true));
            componentInstance.setRequestStatus(RequestStatus.PENDING,
                options: options);
            // Update the query
            componentInstance.updateQuery();
          }
        });
        try {
          // Re-generate query after changes
          final finalGeneratedQuery = this.generateQuery();
          final results = await this._fetchRequest({
            'query': finalGeneratedQuery.requestBody,
            'settings': this.appbaseSettings?.toJSON()
          }, false);
          if (currentTimeStamp == this._lastUsedCustomQueryTimeStamp) {
            // Update the state for components
            finalGeneratedQuery.orderOfQueries.forEach((id) {
              final componentInstance = this._parent!.getSearchWidget(id);
              if (componentInstance != null &&
                  currentTimeStamp ==
                      componentInstance._lastUsedDefaultQueryTimeStamp) {
                componentInstance.setRequestStatus(RequestStatus.INACTIVE,
                    options: options);

                // Reset value for dependent components after fist query is made
                // We wait for first query to not clear filters applied by URL params
                if (this.clearOnQueryChange != null &&
                    this.clearOnQueryChange == true &&
                    this._query != null) {
                  componentInstance.setValue(null,
                      options: new Options(
                          triggerDefaultQuery: false,
                          triggerCustomQuery: false,
                          stateChanges: true));
                }

                // Update the results
                final prev = componentInstance.results.clone();
                // Collect results from the response for a particular component
                Map rawResults = results[id] != null ? results[id] : {};
                // Set results
                if (rawResults['hits'] != null) {
                  componentInstance.results.setRaw(rawResults);
                  componentInstance.applyOptions(
                      Options(stateChanges: options?.stateChanges),
                      KeysToSubscribe.Results,
                      prev,
                      componentInstance.results);
                }

                if (rawResults['aggregations'] != null) {
                  componentInstance.handleAggregationResponse(
                      rawResults['aggregations'],
                      options: new Options(stateChanges: options?.stateChanges),
                      append: false);
                }
              }
            });
          }

          return Future.value(results);
        } catch (e) {
          if (currentTimeStamp == this._lastUsedCustomQueryTimeStamp) {
            return _handleError(e);
          }
        }
      }
      return Future.value(true);
    }
  }

  /// to subscribe the state changes
  ///
  /// Although we have callbacks for change events that can be used to update the UI based on particular property changes,
  /// the `subscribeToStateChanges` method gives you more control over the UI rendering logic and is more efficient.
  ///
  /// ### How does it work?
  /// 1. This method is controlled by the `stateChanges` property which can be defined in the setter methods while updating a particular property.
  /// If `stateChanges` is set to `true`, then only the subscribed functions will be called, unlike events callback which gets called every time when a property changes its value.
  /// So basically, `subscribeToStateChanges` provides more control over the event's callback in a way that you can define whether to update the UI or not while setting a particular property's value.
  /// 2. You can define the properties for which you want to update the UI.
  /// 3. It allows you to register multiple callback functions for search state updates.
  ///
  /// ### Usage
  /// This method can be used to subscribe to the state changes of the properties.
  /// A common use-case is to subscribe to a component or DOM element to a particular property or a set of properties & update the UI according to the changes.
  /// The callback function accepts an object in the following shape:
  /// ```dart
  /// {
  ///   [propertyName]: [Changes]
  /// }
  /// ```
  /// These are the properties that can be subscribed for the changes:
  ///
  /// -   `results`
  /// -   `aggregationData`
  /// -   `requestStatus`
  /// -   `error`
  /// -   `value`
  /// -   `query`
  /// -   `dataField`
  /// -   `size`
  /// -   `from`
  /// -   `fuzziness`
  /// -   `includeFields`
  /// -   `excludeFields`
  /// -   `sortBy`
  /// -   `react`
  /// -   `defaultQuery`
  /// -   `customQuery`
  ///
  subscribeToStateChanges(
      SubscriptionFunction fn, List<KeysToSubscribe>? propertiesToSubscribe) {
    this.stateChanges.subscribe(fn, propertiesToSubscribe);
  }

  /// It is recommended to unsubscribe the callback functions after the component has been unmounted.
  unsubscribeToStateChanges(SubscriptionFunction fn) {
    this.stateChanges.unsubscribe(fn);
  }

  /// to empty results
  void clearResults({Options? options}) {
    final prev = this.results;
    this.results.setRaw({
      'hits': {'hits': []}
    });
    this.applyOptions(Options(stateChanges: options?.stateChanges),
        KeysToSubscribe.Results, prev, this.results);
  }

  /// to get recent searches
  Future<List<Suggestion>> getRecentSearches(
      {RecentSearchOptions? queryOptions, Options? options}) async {
    String queryString = '';
    if (queryOptions == null) {
      queryOptions = RecentSearchOptions();
    }
    void addParam(String key, String? value) {
      if (queryString != "") {
        queryString += "&${key}=${value}";
      } else {
        queryString += "${key}=${value}";
      }
    }

    if (this.appbaseSettings != null && this.appbaseSettings!.userId != null) {
      addParam('user_id', this.appbaseSettings!.userId);
    }
    if (queryOptions.size != null) {
      addParam('size', queryOptions.size.toString());
    }
    if (queryOptions.minChars != null) {
      addParam('min_chars', queryOptions.minChars.toString());
    }
    if (queryOptions.from != null) {
      addParam('from', queryOptions.from);
    }
    if (queryOptions.to != null) {
      addParam('to', queryOptions.to);
    }
    if (queryOptions.customEvents != null) {
      queryOptions.customEvents!.keys.forEach((key) {
        addParam(key, queryOptions!.customEvents![key]);
      });
    }
    final String url =
        "${this.url}/_analytics/${this._getSearchIndex(false)}/recent-searches?${queryString}";
    try {
      final res = await httpClient.get(Uri.parse(url), headers: this.headers);
      if (res.statusCode >= 500) {
        return Future.error(res);
      }
      if (res.statusCode >= 400) {
        return Future.error(res);
      }
      final recentSearches = jsonDecode(res.body);
      final prev = this.recentSearches;
      // Populate the recent searches
      this.recentSearches = ((recentSearches as List).map((searchObject) =>
          Suggestion(searchObject['key'], searchObject['key'],
              isRecentSearch: true))).toList();
      this.applyOptions(new Options(stateChanges: options?.stateChanges),
          KeysToSubscribe.RecentSearches, prev, this.recentSearches);
      return Future.value(this.recentSearches);
    } catch (e) {
      return Future.error(e);
    }
  }

  // To set the parent (SearchBase) instance for the component
  void setParent(SearchBase parent) {
    this._parent = parent;
  }

  /* -------- Private methods only for the internal use -------- */
  _appendResults(Map? rawResults) {
    if (this.preserveResults != null &&
        rawResults != null &&
        rawResults['hits'] != null &&
        rawResults['hits']['hits'] is List &&
        this.results.rawData != null &&
        this.results.rawData!['hits'] != null &&
        this.results.rawData!['hits']['hits'] is List) {
      this.results.setRaw({
        ...rawResults,
        'hits': {
          ...rawResults['hits'],
          'hits': [
            ...this.results.rawData!['hits']['hits'],
            ...rawResults['hits']['hits']
          ]
        }
      });
    } else {
      this.results.setRaw(rawResults);
    }
  }

  void _performUpdate(dynamic value, Options? options) {
    dynamic prev = this.value;
    this.value = value;
    this.applyOptions(options, KeysToSubscribe.Value, prev, this.value);
  }

  Future _handleError(dynamic err, {Option? options}) {
    this.setError(err,
        options: new Options(stateChanges: options?.stateChanges));
    print(err);
    return Future.error(err);
  }

  Map _getSuggestionsQuery() {
    return {
      'query': [
        {
          'id': suggestionQueryID,
          'dataField': popularSuggestionFields,
          'size': this.maxPopularSuggestions != null
              ? this.maxPopularSuggestions
              : 5,
          'value': this.value,
          'defaultQuery': {
            'query': {
              'bool': {
                'minimum_should_match': 1,
                'should': [
                  {
                    'function_score': {
                      'field_value_factor': {
                        'field': 'count',
                        'modifier': 'sqrt',
                        'missing': 1
                      }
                    }
                  },
                  {
                    'multi_match': {
                      'fields': [
                        'key^9',
                        'key.autosuggest^1',
                        'key.keyword^10'
                      ],
                      'fuzziness': 0,
                      'operator': 'or',
                      'query': this.value,
                      'type': 'best_fields'
                    }
                  },
                  {
                    'multi_match': {
                      'fields': [
                        'key^9',
                        'key.autosuggest^1',
                        'key.keyword^10'
                      ],
                      'operator': 'or',
                      'query': this.value,
                      'type': 'phrase'
                    }
                  },
                  {
                    'multi_match': {
                      'fields': ['key^9'],
                      'operator': 'or',
                      'query': this.value,
                      'type': 'phrase_prefix'
                    }
                  }
                ]
              }
            }
          }
        }
      ]
    };
  }

  void updateConfig(Map searchController) {
    // Update the componentConfig with the provided values if they are not null
    this.index = searchController["index"] ?? this.index;
    this.url = searchController["url"] ?? this.url;
    this.credentials = searchController["credentials"] ?? this.credentials;
    this.headers =
        searchController["headers"] as Map<String, String>? ?? this.headers;
    this.transformRequest =
        searchController["transformRequest"] as TransformRequest? ??
            this.transformRequest;
    this.transformResponse =
        searchController["transformResponse"] as TransformResponse? ??
            this.transformResponse;
    this.appbaseConfig =
        searchController["appbaseConfig"] as AppbaseSettings? ??
            this.appbaseConfig;
    this.type = searchController["type"] ?? this.type;
    this.dataField = searchController["dataField"] ?? this.dataField;
    this.react = searchController["react"] ?? this.react;
    this.queryFormat = searchController["queryFormat"] ?? this.queryFormat;
    this.categoryField =
        searchController["categoryField"] ?? this.categoryField;
    this.categoryValue =
        searchController["categoryValue"] ?? this.categoryValue;
    this.nestedField = searchController["nestedField"] ?? this.nestedField;
    this.from = searchController["from"] ?? this.from;
    this.size = searchController["size"] ?? this.size;
    this.sortBy = searchController["sortBy"] ?? this.sortBy;
    this.aggregationField =
        searchController["aggregationField"] ?? this.aggregationField;
    this.aggregationSize =
        searchController["aggregationSize"] ?? this.aggregationSize;
    this.after = searchController["after"] ?? this.after;
    this.includeNullValues =
        searchController["includeNullValues"] ?? this.includeNullValues;
    this.includeFields =
        searchController["includeFields"] ?? this.includeFields;
    this.excludeFields =
        searchController["excludeFields"] ?? this.excludeFields;
    this.fuzziness = searchController["fuzziness"] ?? this.fuzziness;
    this.searchOperators =
        searchController["searchOperators"] ?? this.searchOperators;
    this.highlight = searchController["highlight"] ?? this.highlight;
    this.highlightField =
        searchController["highlightField"] ?? this.highlightField;
    this.customHighlight =
        searchController["customHighlight"] ?? this.customHighlight;
    this.interval = searchController["interval"] ?? this.interval;
    this.aggregations = searchController["aggregations"] ?? this.aggregations;
    this.missingLabel = searchController["missingLabel"] ?? this.missingLabel;
    this.showMissing = searchController["showMissing"] ?? this.showMissing;
    this.enableSynonyms =
        searchController["enableSynonyms"] ?? this.enableSynonyms;
    this.selectAllLabel =
        searchController["selectAllLabel"] ?? this.selectAllLabel;
    this.pagination = searchController["pagination"] ?? this.pagination;
    this.queryString = searchController["queryString"] ?? this.queryString;
    this.defaultQuery = searchController["defaultQuery"] ?? this.defaultQuery;
    this.customQuery = searchController["customQuery"] ?? this.customQuery;
    this.beforeValueChange =
        searchController["beforeValueChange"] ?? this.beforeValueChange;
    this.onValueChange =
        searchController["onValueChange"] ?? this.onValueChange;
    this.onResults = searchController["onResults"] ?? this.onResults;
    this.onAggregationData =
        searchController["onAggregationData"] ?? this.onAggregationData;
    this.onError = searchController["onError"] ?? this.onError;
    this.onRequestStatusChange =
        searchController["onRequestStatusChange"] ?? this.onRequestStatusChange;
    this.onQueryChange =
        searchController["onQueryChange"] ?? this.onQueryChange;
    this.enablePopularSuggestions =
        searchController["enablePopularSuggestions"] ??
            this.enablePopularSuggestions;
    this.maxPopularSuggestions =
        searchController["maxPopularSuggestions"] ?? this.maxPopularSuggestions;
    this.showDistinctSuggestions =
        searchController["showDistinctSuggestions"] ??
            this.showDistinctSuggestions;
    this.preserveResults =
        searchController["preserveResults"] ?? this.preserveResults;
    this.clearOnQueryChange =
        searchController["clearOnQueryChange"] ?? this.clearOnQueryChange;
    this.value = searchController["value"] ?? this.value;
    this.distinctField =
        searchController["distinctField"] ?? this.distinctField;
    this.distinctFieldConfig =
        searchController["distinctFieldConfig"] ?? this.distinctFieldConfig;
    this.compoundClause =
        searchController["compoundClause"] ?? this.compoundClause;
    this.httpRequestTimeout =
        searchController['httpRequestTimeout'] ?? this.httpRequestTimeout;
  }

  // Method to apply the changes based on set options
  void applyOptions(
      Options? options, KeysToSubscribe key, prevValue, nextValue) {
    // Trigger events
    if (key == KeysToSubscribe.Query && this.onQueryChange != null) {
      this.onQueryChange!(nextValue, prev: prevValue);
    }
    if (key == KeysToSubscribe.Value && this.onValueChange != null) {
      this.onValueChange!(nextValue, prev: prevValue);
    }
    if (key == KeysToSubscribe.Error && this.onError != null) {
      this.onError!(nextValue);
    }
    if (key == KeysToSubscribe.Results && this.onResults != null) {
      this.onResults!(nextValue, prev: prevValue);
    }
    if (key == KeysToSubscribe.AggregationData &&
        this.onAggregationData != null) {
      this.onAggregationData!(nextValue, prev: prevValue);
    }
    if (key == KeysToSubscribe.RequestStatus &&
        this.onRequestStatusChange != null) {
      this.onRequestStatusChange!(nextValue, prev: prevValue);
    }
    if (options?.triggerDefaultQuery == true) {
      this.triggerDefaultQuery();
    }
    if (options?.triggerCustomQuery == true) {
      this.triggerCustomQuery();
    }
    if (options == null || options.stateChanges!) {
      this.stateChanges.next(ChangesController(key, prevValue, nextValue), key);
    }
  }

  Future<Map> _fetchRequest(
    Map requestBody,
    bool isPopularSuggestionsAPI,
  ) async {
    // remove undefined properties from request body
    String suffix = '_reactivesearch';
    final String url =
        "${this.url}/${this._getSearchIndex(isPopularSuggestionsAPI)}/$suffix";
    final requestOptions = {
      'url': url,
      'body': jsonEncode(requestBody),
      'headers': {...?this.headers},
    };

    try {
      final finalRequestOptions =
          await this._handleTransformRequest(requestOptions);
      // set timestamp in request
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final timeoutDuration = httpRequestTimeout;

      final http.Response res = await httpClient
          .post(
        Uri.parse(finalRequestOptions['url']),
        headers: finalRequestOptions['headers'],
        body: finalRequestOptions['body'],
      )
          .timeout(timeoutDuration, onTimeout: () {
        throw TimeoutException('Request took too long to complete');
      });

      final responseHeaders = res.headers;
      // check if search component is present
      final queryID = responseHeaders['x-search-id'];
      if (queryID != null && queryID != '') {
        // if parent exists then set the queryID to parent
        if (this._parent != null) {
          this._parent!.setQueryID(queryID);
        } else {
          this.setQueryID(queryID);
        }
      }
      if (res.statusCode >= 500) {
        throw HttpError(res.statusCode, 'Internal Server Error');
      }
      if (res.statusCode >= 400) {
        final errorResponse = jsonDecode(res.body);
        final errorStatusCode = res.statusCode;
        final errorMessage = errorResponse['message'] ?? 'Unknown Error';
        throw HttpError(errorStatusCode, errorMessage);
      }
      final data = jsonDecode(res.body);
      final transformedData = await this._handleTransformResponse(data);
      if (transformedData.containsKey('error')) {
        throw transformedData; // Throw transformed error response
      }
      return {
        ...transformedData,
        '_timestamp': timestamp,
        '_headers': responseHeaders,
      };
    } on TimeoutException {
      // Return a Future.error with an instance of HttpTimeout
      return Future.error(HttpTimeout());
    } on SocketException {
      // Return a Future.error with an instance of NoInternet
      return Future.error(NoInternet());
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  // Method to generate the final query based on the component's value changes
  GenerateQueryResponse generateQuery() {
    /**
     * This method performs the following tasks to generate the query
     * 1. Get all the watcher components for a particular component ID
     * 2. Make the request payload
     * 3. Execute the final query
     * 4. Update results and trigger events => Call 'setResults' or 'setAggregations' based on the results
     */
    if (this._parent != null) {
      final components = this._parent!.getActiveWidgets();
      final List<String> watcherComponents = [];
      // Find all the  watcher components
      components.keys.forEach((id) {
        final componentInstance = components[id];
        if (componentInstance != null && componentInstance.react != null) {
          final flattenReact = flatReactProp(componentInstance.react, id);
          if (flattenReact.indexOf(this.id) > -1) {
            watcherComponents.add(id);
          }
        }
      });
      final Map<String, Map> requestQuery = {};
      // Generate the request body for watchers
      watcherComponents.forEach((watcherId) {
        final component = this._parent!.getSearchWidget(watcherId);
        if (component != null) {
          requestQuery[watcherId] = component.componentQuery;
          // collect queries for all components defined in the `react` property
          // that have some value defined
          final flattenReact = flatReactProp(component.react, component.id);
          flattenReact.forEach((id) {
            // only add if not present
            if (requestQuery[id] == null) {
              final dependentComponent = this._parent!.getSearchWidget(id);
              if (dependentComponent != null &&
                  dependentComponent.value != null) {
                // Set the execute to `false` for dependent components
                final query = dependentComponent.componentQuery;
                query['execute'] = false;
                // Add the query to request payload
                requestQuery[id] = query;
              }
            }
          });
        }
      });
      final queries = requestQuery.values.toList();
      return GenerateQueryResponse(queries, watcherComponents);
    }
    return GenerateQueryResponse([], []);
  }

  Future<Map> _handleTransformResponse(Map? res) {
    if (this.transformResponse != null) {
      return this.transformResponse!(res) as Future<Map<dynamic, dynamic>>;
    }
    return Future.value(res);
  }

  Future<Map> _handleTransformRequest(Map requestOptions) {
    if (this.transformRequest != null) {
      return this.transformRequest!(requestOptions)
          as Future<Map<dynamic, dynamic>>;
    }
    return Future<Map>.value(requestOptions);
  }

  handleAggregationResponse(Map aggsResponse,
      {Options? options, bool append = true}) {
    String? aggregationField = this.aggregationField;
    if ((aggregationField == null || aggregationField == "") &&
        this.dataField is String) {
      aggregationField = this.dataField;
    }
    final prev = this.aggregationData.clone();
    if (aggsResponse[aggregationField] != null) {
      this.aggregationData.setRaw(aggsResponse[aggregationField]);
      if (aggsResponse[aggregationField] != null &&
          aggsResponse[aggregationField]['buckets'] is List) {
        final mapped = (aggsResponse[aggregationField]['buckets'] as List)
            .map((model) => Map.from(model));
        final data = mapped.toList();
        this.aggregationData.setData(aggregationField, data,
            append: this.preserveResults == true && append);
      }
      this.applyOptions(new Options(stateChanges: options?.stateChanges),
          KeysToSubscribe.AggregationData, prev, this.aggregationData);
    }
  }

  setError(dynamic error, {Options? options}) {
    this.setRequestStatus(RequestStatus.ERROR,
        options: Option(stateChanges: options?.stateChanges));
    final prev = this.error;
    this.error = error;
    this.applyOptions(options, KeysToSubscribe.Error, prev, this.error);
  }

  setRequestStatus(RequestStatus requestStatus, {Option? options}) {
    final prev = this.requestStatus;
    this.requestStatus = requestStatus;
    this.applyOptions(Options(stateChanges: options?.stateChanges),
        KeysToSubscribe.RequestStatus, prev, this.requestStatus);
  }

  // Method to set the default query value
  void updateQuery({List<Map>? query}) {
    List<Map>? prevQuery;
    prevQuery = this._query != null ? [...this._query!] : this._query;
    final finalQuery = [this.componentQuery];
    final flattenReact = flatReactProp(this.react, this.id);
    flattenReact.forEach((id) {
      // only add if not present
      final watcherComponent = this._parent!.getSearchWidget(id);
      if (watcherComponent != null && watcherComponent.value != null) {
        // Set the execute to `false` for watcher components
        final watcherQuery = watcherComponent.componentQuery;
        watcherQuery['execute'] = false;
        // Add the query to request payload
        finalQuery.add(watcherQuery);
      }
    });
    this._query = query != null ? query : finalQuery;
    this.applyOptions(new Options(stateChanges: false), KeysToSubscribe.Query,
        prevQuery, this._query);
  }
}
