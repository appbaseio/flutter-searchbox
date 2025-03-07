import 'results.dart';
import 'aggregations.dart';
import 'constants.dart';
import 'searchcontroller.dart';
import 'dart:async';

typedef TransformRequest = Future<Object> Function(Map requestOptions);
typedef TransformResponse = Future Function(dynamic response);
typedef SubscriptionFunction = Function(ChangesController change);

// controller class for state changes
class ChangesController {
  ResultsChanges? Results;
  AggregationDataChanges? AggregationData;
  RequestStatusChanges? RequestStatus;
  Changes? Error;
  Changes? Value;
  Changes? Query;
  Changes? DataField;
  IntegerChanges? Size;
  IntegerChanges? From;
  Changes? Fuzziness;
  StringListChanges? IncludeFields;
  StringListChanges? ExcludeFields;
  SortTypeChanges? SortBy;
  ReactTypeChanges? React;
  DefaultQueryTypeChanges? DefaultQuery;
  DefaultQueryTypeChanges? CustomQuery;
  BooleanTypeChanges? RequestPending;
  RecentSearchesChanges? RecentSearches;
  DynamicMapTypeChanges? After;

  ChangesController(KeysToSubscribe key, dynamic prev, dynamic next) {
    switch (key) {
      case KeysToSubscribe.Results:
        this.Results = ResultsChanges(prev, next);
        break;
      case KeysToSubscribe.AggregationData:
        this.AggregationData = AggregationDataChanges(prev, next);
        break;
      case KeysToSubscribe.RequestStatus:
        this.RequestStatus = RequestStatusChanges(prev, next);
        break;
      case KeysToSubscribe.Error:
        this.Error = Changes(prev, next);
        break;
      case KeysToSubscribe.Value:
        this.Value = Changes(prev, next);
        break;
      case KeysToSubscribe.Query:
        this.Query = Changes(prev, next);
        break;
      case KeysToSubscribe.DataField:
        this.DataField = Changes(prev, next);
        break;
      case KeysToSubscribe.Size:
        this.Size = IntegerChanges(prev, next);
        break;
      case KeysToSubscribe.From:
        this.From = IntegerChanges(prev, next);
        break;
      case KeysToSubscribe.Fuzziness:
        this.Fuzziness = Changes(prev, next);
        break;
      case KeysToSubscribe.IncludeFields:
        this.IncludeFields = StringListChanges(prev, next);
        break;
      case KeysToSubscribe.ExcludeFields:
        this.ExcludeFields = StringListChanges(prev, next);
        break;
      case KeysToSubscribe.SortBy:
        this.SortBy = SortTypeChanges(prev, next);
        break;
      case KeysToSubscribe.React:
        this.React = ReactTypeChanges(prev, next);
        break;
      case KeysToSubscribe.DefaultQuery:
        this.DefaultQuery = DefaultQueryTypeChanges(prev, next);
        break;
      case KeysToSubscribe.CustomQuery:
        this.CustomQuery = DefaultQueryTypeChanges(prev, next);
        break;
      case KeysToSubscribe.RequestPending:
        this.RequestPending = BooleanTypeChanges(prev, next);
        break;
      case KeysToSubscribe.RecentSearches:
        this.RecentSearches = RecentSearchesChanges(prev, next);
        break;
      case KeysToSubscribe.After:
        this.After = DynamicMapTypeChanges(prev, next);
        break;
    }
  }
}

/// Represents the Map<dynamic> type change object with `prev` and `next` values.
class DynamicMapTypeChanges {
  Map? prev;
  Map? next;
  DynamicMapTypeChanges(this.prev, this.next);
}

/// Represents the RecentSeaches change object with `prev` and `next` values.
class RecentSearchesChanges {
  bool? prev;
  bool? next;
  RecentSearchesChanges(this.prev, this.next);
}

/// Represents the bool type change object with `prev` and `next` values.
class BooleanTypeChanges {
  bool? prev;
  bool? next;
  BooleanTypeChanges(this.prev, this.next);
}

/// Represents the DefaultQuery type change object with `prev` and `next` values.
class DefaultQueryTypeChanges {
  Map Function(SearchController searchController)? prev;
  Map Function(SearchController searchController)? next;
  DefaultQueryTypeChanges(this.prev, this.next);
}

/// Represents the React type change object with `prev` and `next` values.
class ReactTypeChanges {
  Map<String, dynamic>? prev;
  Map<String, dynamic>? next;
  ReactTypeChanges(this.prev, this.next);
}

/// Represents the SortType type change object with `prev` and `next` values.
class SortTypeChanges {
  SortType? prev;
  SortType? next;
  SortTypeChanges(this.prev, this.next);
}

/// Represents the List<String> type change object with `prev` and `next` values.
class StringListChanges {
  List<String>? prev;
  List<String>? next;
  StringListChanges(this.prev, this.next);
}

/// Represents the Integer type change object with `prev` and `next` values.
class IntegerChanges {
  int? prev;
  int? next;
  IntegerChanges(this.prev, this.next);
}

/// Represents the RequestStatus change object with `prev` and `next` values.
class RequestStatusChanges {
  RequestStatus? prev;
  RequestStatus? next;
  RequestStatusChanges(this.prev, this.next);
}

/// Represents the AggregationData change object with `prev` and `next` values.
class AggregationDataChanges {
  Aggregations? prev;
  Aggregations? next;
  AggregationDataChanges(this.prev, this.next);
}

/// Represents the Results change object with `prev` and `next` values.
class ResultsChanges {
  Results? prev;
  Results? next;
  ResultsChanges(this.prev, this.next);
}

/// Represents the change object with `prev` and `next` values.
class Changes {
  final dynamic prev;
  final dynamic next;
  Changes(this.prev, this.next);
}

/// AppbaseSettings allows you to customize the analytics experience when appbase.io is used as a backend.
class AppbaseSettings {
  /// It allows recording search analytics (and click analytics) when set to `true` and appbase.io is used as a backend.
  ///
  /// Defaults to `false`.
  bool? recordAnalytics;

  /// If `false`, then appbase.io will not apply the query rules on the search requests.
  ///
  /// Defaults to `true`.
  bool? enableQueryRules;

  /// It allows you to define the user id to be used to record the appbase.io analytics.
  ///
  /// Defaults to the client's IP address.
  String? userId;

  /// It allows you to set the custom events which can be used to build your own analytics on top of appbase.io analytics.
  ///
  /// Further, these events can be used to filter the analytics stats from the appbase.io dashboard.
  Map<String, String>? customEvents;

  AppbaseSettings({
    bool? this.recordAnalytics,
    bool? this.enableQueryRules,
    String? this.userId,
    Map<String, String>? this.customEvents,
  }) {}

  Map<String, dynamic> toJSON() {
    final Map<String, dynamic> settings = {};
    if (this.recordAnalytics != null) {
      settings['recordAnalytics'] = this.recordAnalytics;
    }
    if (this.enableQueryRules != null) {
      settings['enableQueryRules'] = this.enableQueryRules;
    }
    if (this.userId != null) {
      settings['userId'] = this.userId;
    }
    if (this.customEvents != null) {
      settings['customEvents'] = this.customEvents;
    }
    return settings;
  }
}

/// Options to configure the recent searches request.
class RecentSearchOptions {
  int? size;
  int? minChars;
  String? from;
  String? to;
  Map<String, String>? customEvents;
  RecentSearchOptions(
      {this.size = 5,
      this.minChars = 3,
      this.from,
      this.to,
      this.customEvents});
}

/// Allows to configure the effects of an update in a particular property.
class Options {
  bool? triggerDefaultQuery;
  bool? triggerCustomQuery;
  bool? stateChanges;
  Completer<void>? completer;

  Options({
    this.triggerDefaultQuery,
    bool? triggerCustomQuery,
    bool? stateChanges,
    this.completer,
  }) {
    this.triggerDefaultQuery =
        triggerDefaultQuery != null ? triggerDefaultQuery : false;
    this.triggerCustomQuery =
        triggerCustomQuery != null ? triggerCustomQuery : false;
    this.stateChanges = stateChanges != null ? stateChanges : true;
  }
}

/// Allows to configure the effects after executing a query.
class Option {
  bool? stateChanges;
  Option({stateChanges}) {
    this.stateChanges = stateChanges != null ? stateChanges : true;
  }
}

/// Represents a suggestion object.
class Suggestion {
  /// Suggestion label to display in UI.
  final String label;

  /// Suggestion value to perform query.
  final String value;

  /// Represents that if a suggestion is a type of recent search.
  final bool isRecentSearch;

  /// Represents that if a suggestion is a type of popular suggestion.
  bool isPopularSuggestion;

  /// The source object from Elasticsearch response.
  final Map? source;

  /// Represents the click position, useful to record click analytics.
  final int? clickId;

  Suggestion(this.label, this.value,
      {this.isRecentSearch = false,
      this.source,
      this.clickId,
      this.isPopularSuggestion = false}) {
    this.isPopularSuggestion =
        this.source != null && this.source!['_popular_suggestion'] == true;
  }
}

enum KeysToSubscribe {
  /// It is an object that represents the elasticsearch query response.
  Results,

  /// An object that contains the aggregations data for [QueryType.term] queries.
  AggregationData,

  /// Represents the current status of the elasticsearch request, whether PENDING, INACTIVE, ERROR
  RequestStatus,

  /// Represents the error response returned by elasticsearch.
  Error,

  /// Represents the value for a particular [QueryType].
  ///
  /// Depending on the query type, the value format would differ.
  /// You can refer to the different value formats over [here](https://docs.appbase.io/docs/search/reactivesearch-api/reference#value).
  Value,

  /// returns the last query executed by the widget
  Query,

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
  DataField,

  /// Number of suggestions and results to fetch per request.
  Size,

  /// To define from which page to start the results, it is important to implement pagination.
  From,

  /// Useful for showing the correct results for an incorrect search parameter by taking the fuzziness into account.
  ///
  /// For example, with a substitution of one character, `fox` can become `box`.
  /// Read more about it in the elastic search https://www.elastic.co/guide/en/elasticsearch/guide/current/fuzziness.html.
  Fuzziness,

  /// It allows to define fields to be included in search results.
  IncludeFields,

  /// It allows to define fields to be excluded in search results.
  ExcludeFields,

  /// Sorts the results by either [SortType.asc], [SortType.desc] or [SortType.count] order.
  ///
  /// Please note that the [SortType.count] is only applicable for [QueryType.term] type of search widgets.
  SortBy,

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
  React,

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
  DefaultQuery,

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
  CustomQuery,

  /// Useful for getting the status of the API, whether it has been executed or not
  RequestPending,

  /// A list of recent searches as suggestions.
  RecentSearches,

  /// This property can be used to implement the pagination for `aggregations`.
  ///
  /// We use the [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) of `Elasticsearch` to execute the aggregations' query,
  /// the response of composite aggregations includes a key named `after_key` which can be used to fetch the next set of aggregations for the same query.
  /// You can read more about the pagination for composite aggregations at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html#_pagination).
  After
}

extension KeysToSubscribeExtension on KeysToSubscribe {
  String get name {
    switch (this) {
      case KeysToSubscribe.Results:
        return 'results';
      case KeysToSubscribe.AggregationData:
        return 'aggregationData';
      case KeysToSubscribe.RequestStatus:
        return 'requestStatus';
      case KeysToSubscribe.Error:
        return 'error';
      case KeysToSubscribe.Value:
        return 'value';
      case KeysToSubscribe.Query:
        return 'query';
      case KeysToSubscribe.DataField:
        return 'dataField';
      case KeysToSubscribe.Size:
        return 'size';
      case KeysToSubscribe.From:
        return 'from';
      case KeysToSubscribe.Fuzziness:
        return 'fuzziness';
      case KeysToSubscribe.IncludeFields:
        return 'includeFields';
      case KeysToSubscribe.ExcludeFields:
        return 'excludeFields';
      case KeysToSubscribe.SortBy:
        return 'sortBy';
      case KeysToSubscribe.React:
        return 'react';
      case KeysToSubscribe.DefaultQuery:
        return 'defaultQuery';
      case KeysToSubscribe.CustomQuery:
        return 'customQuery';
      case KeysToSubscribe.RequestPending:
        return 'requestPending';
      case KeysToSubscribe.RecentSearches:
        return 'recentSearches';
      case KeysToSubscribe.After:
        return 'after';
    }
  }
}

/// Exception class representing the absence of an internet connection.
class NoInternet implements Exception {
  final String message;

  /// Creates a [NoInternet] exception with an optional [message].
  NoInternet([this.message = 'No internet connection']);

  @override
  String toString() {
    return 'NoInternet: $message';
  }
}

/// Exception class representing an HTTP request timeout.
class HttpTimeout implements Exception {
  final String message;

  /// Creates an [HttpTimeout] exception with an optional [message].
  HttpTimeout([this.message = 'HTTP request timed out']);

  @override
  String toString() {
    return 'HttpTimeout: $message';
  }
}

/// Exception class representing an HTTP error with an associated status code and an optional message.
class HttpError implements Exception {
  final int statusCode;
  final String? message;

  /// Creates an [HttpError] exception with the given [statusCode] and an optional [message].
  HttpError(this.statusCode, [this.message]);

  @override
  String toString() {
    return 'HttpError: $statusCode${message != null ? " ($message)" : ""}';
  }
}
