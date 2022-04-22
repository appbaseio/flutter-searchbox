import 'package:flutter/material.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import '../utils.dart';
import 'package:searchbase/searchbase.dart';

class RangeType {
  final dynamic start;
  final dynamic end;
  const RangeType({this.start, this.end});
}

class DefaultValue {
  final dynamic start;
  final dynamic end;
  const DefaultValue({this.start, this.end});
}

class RangeLabelsType {
  final String Function(dynamic number) start;
  final String Function(dynamic number) end;

  RangeLabelsType({required this.start, required this.end});
}

/// It creates a range input selector, to perform [QueryType.range] query.
///
/// Examples Uses:
///   - filtering products from a price range in an e-commerce shopping experience.
///   - filtering flights from a range of departure and arrival times.
class RangeInput extends StatefulWidget {
  /// This property allows to define a list of properties of [SearchController] class which can trigger the re-build when any changes happen.
  ///
  /// For example, if `subscribeTo` is defined as `[KeysToSubscribe.Results]` then it'll only update the UI when results property would change.
  final List<KeysToSubscribe>? subscribeTo;

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

  /// Defaults to `true`. It can be used to prevent the default query execution.
  final bool? triggerQueryOnInit;

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
  final Future Function(dynamic value)? beforeValueChange;

  /* ------------- change events -------------------------------- */

  /// It is called every-time the widget's value changes.
  ///
  /// This property is handy in cases where you want to generate a side-effect on value selection.
  /// For example: You want to show a pop-up modal with the valid discount coupon code when a user searches for a product in a [SearchBox].
  final void Function(dynamic next, {dynamic prev})? onValueChange;

  /// It can be used to listen for the `results` changes.
  final void Function(Results next, {Results prev})? onResults;

  /// It can be used to listen for the `aggregationData` property changes.
  final void Function(Aggregations next, {Aggregations prev})?
      onAggregationData;

  /// It gets triggered in case of an error occurs while fetching results.
  final void Function(dynamic error)? onError;

  /// It can be used to listen for the request status changes.
  final void Function(String next, {String prev})? onRequestStatusChange;

  /// It is a callback function which accepts widget's **nextQuery** and **prevQuery** as parameters.
  ///
  /// It is called everytime the widget's query changes.
  /// This property is handy in cases where you want to generate a side-effect whenever the widget's query would change.
  final void Function(List<Map>? next, {List<Map>? prev})? onQueryChange;

  // Render a custom title widget.
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   buildTitle: () {
  ///     return const Text(
  ///       "Custom Title Widget",
  ///        style: TextStyle(
  ///          fontWeight: FontWeight.bold,
  ///          fontSize: 16.0,
  ///          color: Colors.amber,
  ///        ),
  ///      );
  ///    },
  /// )

  final Widget Function()? buildTitle;

  // Render a custom widget to display Label between range values.
  // like: '-', 'until', 'to', etc.
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   buildRangeLabel: () {
  ///     return const Text(
  ///       "Custom Title Widget",
  ///        style: TextStyle(
  ///          fontWeight: FontWeight.bold,
  ///          fontSize: 16.0,
  ///          color: Colors.blue,
  ///        ),
  ///      );
  ///    },
  /// )
  /// ```
  final Widget Function()? buildRangeLabel;

  // The range values to choose for minimum/ maximum selection
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   range: const RangeType(
  ///     start: 1990,
  ///     end: 2012,
  ///    ),
  /// )
  /// ```
  ///
  /// It is possible to pass range values(start/ end) as a `number` or an `List/ array` of numbers.
  /// Passing range as a `number` renders an input box, else a dropdown is displayed incase of `List/ array` of numbers.
  ///
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   range: const RangeType(
  ///     start: 1980,
  ///     end:   [1990, 2000, 2010],
  ///    ),
  /// )
  /// ```
  ///
  /// Moreover, you can pass the first element of the `List/ array` as `other`,
  /// which when selected from the dropdown, opens up an input field to enter custom values.
  ///
  /// Passing the last element of the `List/ array` as 'no_limit' sets an unbounded upper limit.
  ///
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   range: const RangeType(
  ///     start: 1990,
  ///     end:   ['other', 1990, 2000, 2010, 'no_limit'],
  ///    ),
  /// )
  /// ```
  final RangeType range;

  // Used for default range selection.
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   defaultValue: DefaultValue(start: 1980, end: 2000),
  /// )
  /// ```
  final DefaultValue? defaultValue;

  // To render custom labels
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   rangeLabels: RangeLabelsType(
  ///      start: (value) {
  ///        return 'year $value ';
  ///      },
  ///      end: (value) {
  ///        return 'year $value ';
  ///      },
  ///    ),
  /// )
  /// ```
  final RangeLabelsType? rangeLabels;

  // To custom validate the range values.
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   validateRange: (start, end) {
  ///      if (start < end) {
  ///        return true;
  ///      }
  ///        return false;
  ///    },
  /// )
  /// ```
  final bool Function(dynamic start, dynamic end)? validateRange;

  // To render a custom widget to display the error message.
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   buildErrorMessage: (start, end) {
  ///     return const Text(
  ///       'Custom error $start > $end',
  ///        style: TextStyle(
  ///          color: Colors.yellowAccent,
  ///          fontSize: 20.0,
  ///        ),
  ///      );
  ///    },
  /// )
  /// ```
  final Widget Function(dynamic start, dynamic end)? buildErrorMessage;

  // To custom style the input field
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   inputStyle: TextStyle(
  ///          color: Colors.deepPurple,
  ///          fontSize: 18,
  ///          height: 1,
  ///        ),
  /// )
  /// ```
  final TextStyle? inputStyle;

  /// [TextField] keyboardType property
  final TextInputType? keyboardType;

  /// [TextField] textInputAction property
  final TextInputAction? textInputAction;
  // To custom style the Dropdown
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   dropdownStyle: TextStyle(
  ///          color: Colors.deepPurple,
  ///          fontSize: 18,
  ///          height: 1,
  ///        ),
  /// )
  /// ```
  final TextStyle? dropdownStyle;

  // To custom render the Container.
  //
  //  Container is wrapper around TextField/ Dropdown, that helps to customize height, border, etc.
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   customContainer: (showError, childWidget) {
  ///     return Container(
  ///       padding: const EdgeInsets.all(8.0),
  ///       height: 50,
  ///       decoration: BoxDecoration(
  ///         border: Border.all(
  ///           color: showError ? Colors.red : Colors.grey,
  ///           width: 1.5,
  ///         ),
  ///         borderRadius: BorderRadius.circular(3),
  ///       ),
  ///       child: childWidget,
  ///      );
  ///     },
  /// ```
  final Container Function(bool showError, Widget childWidget)? customContainer;

  // To custom render the textfield closeIcon.
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   closeIcon: () {
  ///     return const Text(
  ///       "X",
  ///       style: TextStyle(
  ///         fontWeight: FontWeight.bold,
  ///         fontSize: 16.0,
  ///         color: Colors.red,
  ///       ),
  ///      );
  ///     },
  /// ```
  final Widget Function()? closeIcon;

  // To custom render the Dropdown icon.
  //
  /// For example,
  /// ```dart
  /// RangeInput(
  ///   ...
  ///   id="range-input",
  ///   closeIcon: (showError) {
  ///     return Icon(
  ///       Icons.arrow_drop_down,
  ///       color: showError ? Colors.red : Colors.black,
  ///     );
  ///    },
  /// ```
  final Widget Function(bool showError)? dropdownIcon;

  const RangeInput({
    Key? key,
    required this.id,
    this.subscribeTo,
    this.shouldListenForChanges,
    this.destroyOnDispose,
    this.triggerQueryOnInit,
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
    this.buildTitle,
    this.buildRangeLabel,
    required this.range,
    this.defaultValue,
    this.rangeLabels,
    this.validateRange,
    this.buildErrorMessage,
    this.inputStyle,
    this.keyboardType,
    this.textInputAction,
    this.dropdownStyle,
    this.customContainer,
    this.closeIcon,
    this.dropdownIcon,
  }) : super(key: key);

  @override
  _RangeInputState createState() => _RangeInputState();
}

class _RangeInputState extends State<RangeInput> {
  @override
  initState() {
    super.initState();

    // validating the range input
    if (!isNumeric(widget.range.start) && !isNumeric(widget.range.end)) {
      throw Exception(
          "Range values, start/ end should be in numeric or parsable numeric string format!, eg: 23 or \"23\" or [23,\"23\"]");
    }
  }

  buildTitleWidget() {
    if (widget.buildTitle != null) {
      return widget.buildTitle!();
    } else {
      return const Text(
        "Range Input",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
      );
    }
  }

  buildRangeLabelWidget() {
    if (widget.buildRangeLabel != null) {
      return widget.buildRangeLabel!();
    } else {
      return const Text(
        "-",
        style: TextStyle(
          fontSize: 22,
          color: Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SearchWidgetConnector(
      id: widget.id,
      builder: (context, searchController) {
        return RangeInputInner(
          searchController: searchController,
          title: buildTitleWidget(),
          rangeLabel: buildRangeLabelWidget(),
          range: widget.range,
          defaultValue:
              widget.defaultValue is DefaultValue ? widget.defaultValue : null,
          rangeLabels:
              widget.rangeLabels is RangeLabelsType ? widget.rangeLabels : null,
          validateRange:
              widget.validateRange is Function ? widget.validateRange : null,
          buildErrorMessage: widget.buildErrorMessage,
          inputStyle: widget.inputStyle,
          textInputAction: widget.textInputAction,
          keyboardType: widget.keyboardType,
          dropdownStyle: widget.dropdownStyle,
          customContainer: widget.customContainer,
          closeIcon: widget.closeIcon,
          dropdownIcon: widget.dropdownIcon,
        );
      },
      subscribeTo: widget.subscribeTo,
      triggerQueryOnInit: widget.triggerQueryOnInit,
      shouldListenForChanges: widget.shouldListenForChanges,
      destroyOnDispose: widget.destroyOnDispose,
      index: widget.index,
      url: widget.url,
      credentials: widget.credentials,
      headers: widget.headers,
      appbaseConfig: widget.appbaseConfig,
      type: QueryType.range,
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

class RangeInputInner extends StatefulWidget {
  final Widget title;
  final Widget rangeLabel;
  final RangeType range;
  final DefaultValue? defaultValue;
  final bool Function(num start, num end)? validateRange;
  final Widget Function(dynamic start, dynamic end)? buildErrorMessage;
  final RangeLabelsType? rangeLabels;
  final TextStyle? inputStyle;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextStyle? dropdownStyle;
  final Container Function(bool showError, Widget childWidget)? customContainer;
  final Widget Function()? closeIcon;
  final Widget Function(bool showError)? dropdownIcon;
  final SearchController searchController;
  const RangeInputInner(
      {Key? key,
      required this.searchController,
      required this.title,
      required this.rangeLabel,
      required this.range,
      required this.defaultValue,
      this.rangeLabels,
      this.validateRange,
      this.buildErrorMessage,
      this.inputStyle,
      this.textInputAction,
      this.dropdownStyle,
      this.customContainer,
      this.closeIcon,
      this.dropdownIcon,
      this.keyboardType})
      : super(key: key);

  @override
  _RangeInputInnerState createState() => _RangeInputInnerState();
}

class _RangeInputInnerState extends State<RangeInputInner> {
  Map<String, dynamic> dropdownValues = {
    "startValue": "",
    "endValue": "",
    "defaultStartValue": "",
    "defaultEndValue": "",
  };
  bool showError = false;
  Widget buildErrorMessage() {
    if (widget.buildErrorMessage != null) {
      return widget.buildErrorMessage!(
        dropdownValues['startValue'],
        dropdownValues['endValue'],
      );
    }
    return const Text(
      'Choose a lower minimum or higher maximum value',
      style: TextStyle(fontSize: 20.0, color: Colors.red),
    );
  }

  _RangeInputInnerState();

  @override
  void initState() {
    super.initState();
    try {
      setState(() {
        if (widget.searchController.value != null) {
          dropdownValues['startValue'] = widget
                  .searchController.value['start'] ??
              (widget.range.start[widget.range.start.length - 1] == 'no_limit'
                  ? widget.range.start[widget.range.start.length - 1]
                  : "");
          dropdownValues['endValue'] = widget.searchController.value['end'] ??
              (widget.range.end[widget.range.end.length - 1] == 'no_limit'
                  ? widget.range.end[widget.range.end.length - 1]
                  : "");
        } else {
          dropdownValues['startValue'] = (widget.defaultValue != null &&
                  isNumeric(widget.defaultValue?.start)
              ? widget.defaultValue?.start
              : (widget.range.start is List
                  ? (widget.range.start[widget.range.start.length - 1] ==
                          'no_limit'
                      ? widget.range.start[widget.range.start.length - 1]
                      : widget.range.start[0] == 'other'
                          ? widget.range.start[1]
                          : widget.range.start[0])
                  : widget.range.start));
          dropdownValues['endValue'] = (widget.defaultValue != null &&
                  isNumeric(widget.defaultValue?.end)
              ? widget.defaultValue?.end
              : (widget.range.end is List
                  ? (widget.range.end[widget.range.end.length - 1] == 'no_limit'
                      ? widget.range.end[widget.range.end.length - 1]
                      : widget.range.end[0] == 'other'
                          ? widget.range.end[1]
                          : widget.range.end[0])
                  : widget.range.end));
        }
        dropdownValues['defaultStartValue'] = dropdownValues['startValue'];
        dropdownValues['defaultEndValue'] = dropdownValues['endValue'];
      });
      Map<String, dynamic> valueObj = {};
      if (dropdownValues['startValue'] != null &&
          isNumeric(dropdownValues['startValue'])) {
        valueObj["start"] = dropdownValues['startValue'];
      }
      if (dropdownValues['endValue'] != null &&
          isNumeric(dropdownValues['endValue'])) {
        valueObj["end"] = dropdownValues['endValue'];
      }

      WidgetsBinding.instance!.addPostFrameCallback((_) => widget
          .searchController
          .setValue(valueObj, options: Options(triggerCustomQuery: true)));
    } catch (e, stack) {
      print('$e $stack');
    }
  }

  @override
  void didUpdateWidget(RangeInputInner oldWidget) {
    super.didUpdateWidget(oldWidget);
    var updatedValue = widget.searchController.value;
    if (!isEqual(updatedValue, {
      "start": dropdownValues['startValue'],
      "end": dropdownValues['endValue']
    })) {
      if (updatedValue == null ||
          (updatedValue is Map && updatedValue.isEmpty)) {
        dropdownValues['startValue'] = (widget.range.start is List
            ? (widget.range.start[widget.range.start.length - 1] == 'no_limit'
                ? widget.range.start[widget.range.start.length - 1]
                : widget.range.start[0] == 'other'
                    ? widget.range.start[1]
                    : widget.range.start[0])
            : "");
        dropdownValues['endValue'] = (widget.range.end is List
            ? (widget.range.end[widget.range.end.length - 1] == 'no_limit'
                ? widget.range.end[widget.range.end.length - 1]
                : widget.range.end[0] == 'other'
                    ? widget.range.end[1]
                    : widget.range.end[0])
            : "");
      } else {
        dropdownValues['startValue'] = updatedValue['start'] ??
            (widget.range.start is List &&
                    widget.range.start[widget.range.start.length - 1] ==
                        'no_limit'
                ? widget.range.start[widget.range.start.length - 1]
                : "");
        dropdownValues['endValue'] = updatedValue['end'] ??
            (widget.range.end is List &&
                    widget.range.end[widget.range.end.length - 1] == 'no_limit'
                ? widget.range.end[widget.range.end.length - 1]
                : "");
      }
      setState(() {
        dropdownValues['defaultStartValue'] = dropdownValues['startValue'];
        dropdownValues['defaultEndValue'] = dropdownValues['endValue'];
      });
    }
  }

  validateRange() {
    try {
      bool isValid;
      dynamic startValue =
          num.tryParse(dropdownValues['startValue'].toString());
      dynamic endValue = num.tryParse(dropdownValues['endValue'].toString());

      if (isNumeric(startValue) && isNumeric(endValue)) {
        if (widget.validateRange != null) {
          isValid = widget.validateRange!(startValue, endValue);
        } else if (startValue > endValue) {
          isValid = false;
        } else {
          isValid = true;
        }
      } else if (!(dropdownValues['startValue'].toString() == "" &&
          dropdownValues['endValue'].toString() == "")) {
        isValid = true;
      } else {
        isValid = false;
      }

      setState(() {
        showError = !isValid;
        Map<String, dynamic> valueObj = {};
        if (startValue != null && startValue != "no_limit") {
          valueObj["start"] = startValue;
        }
        if (endValue != null && endValue != "no_limit") {
          valueObj["end"] = endValue;
        }
        if (isValid) {
          widget.searchController
              .setValue(valueObj, options: Options(triggerCustomQuery: true));
        }
      });
    } catch (e, stacktrace) {
      // print('$e');
    }
  }

  handleValueChange(stateMemberName, value) {
    dropdownValues[stateMemberName] = value;
    validateRange();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                padding: const EdgeInsets.only(left: 8.0), child: widget.title),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Dropdown(
                    rangeItem: widget.range.start,
                    value: dropdownValues['startValue'],
                    defaultValue: dropdownValues['defaultStartValue'],
                    onChangeHandler: (value) =>
                        handleValueChange('startValue', value),
                    hintLabel: "Min. Value",
                    showError: showError,
                    renderLabel: (widget.rangeLabels != null &&
                            widget.rangeLabels is RangeLabelsType)
                        ? widget.rangeLabels!.start
                        : null,
                    inputStyle: widget.inputStyle,
                    textInputAction: widget.textInputAction,
                    keyboardType: widget.keyboardType,
                    dropdownStyle: widget.dropdownStyle,
                    customContainer: widget.customContainer,
                    closeIcon: widget.closeIcon,
                    dropdownIcon: widget.dropdownIcon,
                  ),
                  Container(
                    child: widget.rangeLabel,
                    margin: const EdgeInsets.fromLTRB(6.0, 0, 6.0, 0),
                  ),
                  Dropdown(
                    rangeItem: widget.range.end,
                    value: dropdownValues['endValue'],
                    defaultValue: dropdownValues['defaultEndValue'],
                    onChangeHandler: (value) =>
                        handleValueChange('endValue', value),
                    hintLabel: "Max. Value",
                    showError: showError,
                    renderLabel: (widget.rangeLabels != null &&
                            widget.rangeLabels is RangeLabelsType)
                        ? widget.rangeLabels!.end
                        : null,
                    inputStyle: widget.inputStyle,
                    textInputAction: widget.textInputAction,
                    keyboardType: widget.keyboardType,
                    dropdownStyle: widget.dropdownStyle,
                    customContainer: widget.customContainer,
                    closeIcon: widget.closeIcon,
                    dropdownIcon: widget.dropdownIcon,
                  ),
                ],
              ),
            ),
            Offstage(
              offstage: !showError,
              child: Container(
                padding: const EdgeInsets.only(left: 8.0),
                child: buildErrorMessage(),
              ),
            )
          ],
        ));
  }
}

class Dropdown extends StatefulWidget {
  final dynamic defaultValue;
  final dynamic value;
  final dynamic rangeItem;
  final Function onChangeHandler;
  final String hintLabel;
  final bool showError;
  final dynamic renderLabel;
  final TextStyle? inputStyle;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextStyle? dropdownStyle;
  final Container Function(bool showError, Widget childWidget)? customContainer;
  final Widget Function()? closeIcon;
  final Widget Function(bool showError)? dropdownIcon;

  const Dropdown(
      {Key? key,
      required this.rangeItem,
      required this.value,
      required this.onChangeHandler,
      required this.hintLabel,
      required this.showError,
      required this.renderLabel,
      required this.defaultValue,
      this.inputStyle,
      this.textInputAction,
      this.dropdownStyle,
      this.customContainer,
      this.closeIcon,
      this.dropdownIcon,
      this.keyboardType})
      : super(key: key);

  @override
  _DropdownState createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  dynamic _value;
  bool _showTextField = false;
  bool _isRangeItemList = false;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  renderLabel(dynamic value) {
    if (widget.renderLabel != null && value != "") {
      return widget.renderLabel(value);
    }
    return value.toString();
  }

  initDropdownValue() {
    try {
      if (_isRangeItemList) {
        if (!widget.rangeItem.contains(widget.defaultValue)) {
          return isNumeric(widget.rangeItem[0])
              ? widget.rangeItem[0]
              : widget.rangeItem[1];
        }
        return widget.defaultValue;
      } else {
        _controller.text = widget.defaultValue.toString();
        _value = _controller.text;
        return _controller.text;
      }
    } catch (error, stack) {
      // print('$error $stack');
    }
  }

  @override
  void initState() {
    try {
      super.initState();
      if (widget.rangeItem is List) {
        _isRangeItemList = true;
      } else {
        _showTextField = true;
      }
      setState(() {
        if ((!isNumeric(widget.defaultValue) && !_isRangeItemList) ||
            (_isRangeItemList &&
                !widget.rangeItem.contains(widget.defaultValue))) {
          _showTextField = true;
          _value =
              widget.defaultValue != null ? widget.defaultValue.toString() : "";
        } else {
          _value = initDropdownValue();
        }
        _controller.text = isNumeric(_value) ? renderLabel(_value) : "";
      });

      _focusNode.addListener(() {
        if (!_focusNode.hasFocus && _showTextField) {
          if (_controller.text.isEmpty && _isRangeItemList) {
            if (widget.rangeItem.contains('no_limit')) {
              _value = 'no_limit';
            } else {
              _value = isNumeric(widget.rangeItem[0])
                  ? widget.rangeItem[0]
                  : widget.rangeItem[1];
            }
            handleValueChange(_value);
            _showTextField = false;
            return;
          }
          widget.onChangeHandler(_controller.text);
          _controller.text = renderLabel(_value);
        } else {
          _controller.text =
              _isRangeItemList && !_showTextField ? "" : _value.toString();
        }
      });

      _controller.addListener(() {
        if (_focusNode.hasFocus) {
          _value = _controller.text;
        }
      });
    } catch (e, stack) {
      // print('$e $stack');
    }
  }

  @override
  void didUpdateWidget(Dropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_value != widget.value) {
      var valueToSet = widget.value ?? "";
      if (widget.rangeItem is List) {
        _isRangeItemList = true;
      } else {
        _showTextField = true;
      }
      setState(() {
        if ((!isNumeric(valueToSet) && !_isRangeItemList) ||
            (_isRangeItemList && !widget.rangeItem.contains(valueToSet))) {
          _showTextField = true;
        }
        _value = valueToSet;
        _controller.text = renderLabel(valueToSet);
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  handleValueChange(value) {
    if (value == 'other') {
      setState(() {
        _value = "";
        _showTextField = true;
      });

      _focusNode.requestFocus();
    } else {
      setState(() {
        _value = value;
        _showTextField = false;
      });
      widget.onChangeHandler(_value);
    }
  }

  closeTextField() {
    _controller.text = "";
    setState(() {
      if (_isRangeItemList == true) {
        if (widget.rangeItem.contains('no_limit')) {
          _value = 'no_limit';
        } else {
          _value = isNumeric(widget.rangeItem[0])
              ? widget.rangeItem[0]
              : widget.rangeItem[1];
        }
        handleValueChange(_value);
        _showTextField = false;
      } else {
        _showTextField = true;
        _value = "";
        _focusNode.requestFocus();
      }
    });
  }

  renderCloseIcon() {
    if (widget.closeIcon != null) {
      return widget.closeIcon!();
    }
    return const Icon(Icons.clear);
  }

  renderDropdownIcon() {
    if (widget.dropdownIcon != null) {
      return widget.dropdownIcon!(widget.showError);
    }
    return const Icon(Icons.arrow_drop_down);
  }

  renderWidget() {
    if (_showTextField || !_isRangeItemList) {
      return TextField(
        style: widget.inputStyle ??
            const TextStyle(
              fontSize: 22,
              height: 1,
            ),
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        focusNode: _focusNode,
        controller: _controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.zero,
          suffixIcon: _value != ""
              ? IconButton(
                  icon: renderCloseIcon(),
                  onPressed: closeTextField,
                )
              : null,
        ),
      );
    } else {
      return DropdownButton(
        hint: Text(widget.hintLabel),
        dropdownColor: Colors.white,
        icon: renderDropdownIcon(),
        iconSize: 36,
        isExpanded: true,
        underline: const SizedBox(),
        style: widget.dropdownStyle ??
            const TextStyle(
              color: Colors.black,
              fontSize: 22,
              height: 1,
            ),
        items: widget.rangeItem.map<DropdownMenuItem<Object>>((value) {
          return DropdownMenuItem(
            value: value,
            child: Text(renderLabel(value)),
          );
        }).toList(),
        onChanged: (value) => handleValueChange(value),
        value: _value,
      );
    }
  }

  renderContainer() {
    if (widget.customContainer != null) {
      return widget.customContainer!(widget.showError, renderWidget());
    }
    return Container(
      padding: const EdgeInsets.only(left: 6.0, right: 1.0),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: !!widget.showError ? Colors.red : Colors.grey,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
      child: renderWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: renderContainer(),
    );
  }
}
