import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base.dart';
import 'searchbase.dart';
import 'constants.dart';
import 'observable.dart';
import 'results.dart';
import 'aggregations.dart';
import 'types.dart';
import 'utils.dart';

const suggestionQueryID = 'DataSearch__suggestions';

/**
 * SearchComponent class is responsible for the following things:
 * - It provides the methods to trigger the query
 * - It maintains the request state for e.g loading, error etc.
 * - It handles the 'custom' and 'default' queries
 * - Basically the SearchComponent class provides all the utilities to build any ReactiveSearch component
 */
class SearchComponent extends Base {
  // RS API properties
  String id;

  QueryType type;

  Map<String, dynamic> react;

  String queryFormat;

  dynamic dataField;

  String categoryField;

  String categoryValue;

  String nestedField;

  int from;

  int size;

  SortType sortBy;

  dynamic value;

  String aggregationField;

  Map after;

  bool includeNullValues;

  List<String> includeFields;

  List<String> excludeFields;

  dynamic fuzziness;

  bool searchOperators;

  bool highlight;

  dynamic highlightField;

  Map customHighlight;

  int interval;

  List<String> aggregations;

  String missingLabel;

  bool showMissing;

  Map Function(SearchComponent component) defaultQuery;

  Map Function(SearchComponent component) customQuery;

  bool execute;

  bool enableSynonyms;

  String selectAllLabel;

  bool pagination;

  bool queryString;

  /* ------ Private properties only for the internal use ----------- */
  SearchBase _parent;

  // Counterpart of the query
  List<Map> _query;

  // mic status
  MicStatusField _micStatus;

  // mic instance
  dynamic _micInstance;

  // query search ID
  String _queryId;

  // other properties

  // To enable the popular suggestions
  bool enablePopularSuggestions;

  // size of the popular suggestions
  int maxPopularSuggestions;

  // To show the distinct suggestions
  bool showDistinctSuggestions;

  // preserve the data for infinite loading
  bool preserveResults;

  // query error
  dynamic error;

  // state changes subject
  Observable stateChanges;

  // request status
  RequestStatus requestStatus;

  // results
  Results results;

  // aggregations
  Aggregations aggregationData;

  // recent searches
  List<Suggestion> recentSearches;

  /* ---- callbacks to create the side effects while querying ----- */

  Future Function(String value) beforeValueChange;

  /* ------------- change events -------------------------------- */

  // called when value changes
  void Function(String next, {String prev}) onValueChange;

  // called when results change
  void Function(List<Map> next, {List<Map> prev}) onResults;

  // called when composite aggregationData change
  void Function(List<Map> next, {List<Map> prev}) onAggregationData;
  // called when there is an error while fetching results
  void Function(Error error) onError;

  // called when request status changes
  void Function(String next, {String prev}) onRequestStatusChange;

  // called when query changes
  void Function(Map next, {Map prev}) onQueryChange;

  // called when mic status changes
  void Function(MicStatusField next, {MicStatusField prev}) onMicStatusChange;

  SearchComponent(
    String index,
    String url,
    String credentials,
    String this.id, {
    AppbaseSettings appbaseConfig,
    TransformRequest transformRequest,
    TransformResponse transformResponse,
    Map<String, String> headers,
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
    this.execute,
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
    this.onMicStatusChange,
    this.enablePopularSuggestions,
    this.maxPopularSuggestions,
    this.showDistinctSuggestions,
    this.preserveResults,
    this.value,
    List<Map> results,
  }) : super(index, url, credentials,
            appbaseConfig: appbaseConfig,
            transformRequest: transformRequest,
            transformResponse: transformResponse,
            headers: headers) {
    if (id == "") {
      throw (ErrorMessages[InvalidComponentId]);
    }
    // dataField is required for components other then search
    if (type != null && type != QueryType.search) {
      if (dataField == null) {
        throw (ErrorMessages[InvalidDataField]);
      } else if (dataField is List<String>) {
        throw (ErrorMessages[DataFieldAsArray]);
      }
    }
    // Initialize the state changes observable
    this.stateChanges = new Observable();

    this.results = new Results(results != null ? results : []);

    this.aggregationData = new Aggregations(data: []);

    if (value != null) {
      this.setValue(value, options: new Options());
    } else {
      this.value = value;
    }
  }

  // getters
  MicStatusField get micStatus {
    return this._micStatus;
  }

  dynamic get micInstance {
    return this._micInstance;
  }

  bool get micActive {
    return this._micStatus == MicStatusField.ACTIVE;
  }

  bool get micInactive {
    return this._micStatus == MicStatusField.INACTIVE;
  }

  bool get micDenied {
    return this._micStatus == MicStatusField.DENIED;
  }

  List<Map> get query {
    return this._query;
  }

  bool get requestPending {
    return this.requestStatus == RequestStatus.PENDING;
  }

  AppbaseSettings get appbaseSettings {
    return this.appbaseConfig;
  }

  // To get the parsed suggestions from the results
  List<Suggestion> get suggestions {
    if (this.type != null && this.type != QueryType.search) {
      return [];
    }
    List<String> fields = getNormalizedField(this.dataField);
    if (fields.length == 0 &&
        this.results.data != null &&
        this.results.data.length > 0 &&
        this.results.data[0] != null &&
        this.results.data[0]['_source'] is Map &&
        this.results.data[0]['_source'] != null) {
      // Extract fields from _source
      fields = this.results.data[0]['_source'].keys;
    }
    if (this.enablePopularSuggestions == true) {
      // extract suggestions from popular suggestion fields too
      fields = [...fields, ...popularSuggestionFields];
    }
    return getSuggestions(
        fields, this.results.data, this.value, this.showDistinctSuggestions);
  }

  // Method to get the raw query based on the current state
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
      'categoryField': categoryField,
      'missingLabel': missingLabel,
      'showMissing': showMissing,
      'nestedField': nestedField,
      'interval': interval,
      'customHighlight': customHighlight,
      'customQuery': customQuery != null ? customQuery(this) : null,
      'defaultQuery': defaultQuery != null ? defaultQuery(this) : null,
      'value': value,
      'categoryValue': categoryValue,
      'after': after,
      'aggregations': aggregations,
      'enableSynonyms': enableSynonyms,
      'selectAllLabel': selectAllLabel,
      'pagination': pagination,
      'queryString': queryString
    };
    query.removeWhere((key, value) => key == null || value == null);
    return query;
  }

  String get queryId {
    // Get query ID from parent(searchbase) if exist
    if (this._parent != null && this._parent.queryId != "") {
      return this._parent.queryId;
    }
    // For single components just return the queryId from the component
    if (this._queryId != "") {
      return this._queryId;
    }
    return '';
  }

  /* -------- Public methods -------- */

  // mic click handler
  // onMicClick = (
  //   micOptions: Object = {},
  //   options: Options = {
  //     triggerDefaultQuery: false,
  //     triggerCustomQuery: false,
  //     stateChanges: true
  //   }
  // ) => {
  //   const prevStatus = this._micStatus;
  //   if (typeof window !== 'undefined') {
  //     window.SpeechRecognition =
  //       window.webkitSpeechRecognition || window.SpeechRecognition || null;
  //   }
  //   if (
  //     window &&
  //     window.SpeechRecognition &&
  //     prevStatus !== MIC_STATUS.denied
  //   ) {
  //     if (prevStatus === MIC_STATUS.active) {
  //       this._setMicStatus(MIC_STATUS.inactive, options);
  //     }
  //     const { SpeechRecognition } = window;
  //     if (this._micInstance) {
  //       this._stopMic();
  //       return;
  //     }
  //     this._micInstance = new SpeechRecognition();
  //     this._micInstance.continuous = true;
  //     this._micInstance.interimResults = true;
  //     Object.assign(this._micInstance, micOptions);
  //     this._micInstance.start();
  //     this._micInstance.onstart = () => {
  //       this._setMicStatus(MIC_STATUS.active, options);
  //     };
  //     this._micInstance.onresult = ({ results }) => {
  //       if (results && results[0] && results[0].isFinal) {
  //         this._stopMic();
  //       }
  //       this._handleVoiceResults({ results }, options);
  //     };
  //     this._micInstance.onerror = e => {
  //       if (e.error === 'no-speech' || e.error === 'audio-capture') {
  //         this._setMicStatus(MIC_STATUS.inactive, options);
  //       } else if (e.error === 'not-allowed') {
  //         this._setMicStatus(MIC_STATUS.denied, options);
  //       }
  //       console.error(e);
  //     };
  //   }

  // Method to set the dataField option
  void setDataField(dynamic dataField, {Options options}) {
    final prev = this.dataField;
    this.dataField = dataField;
    this._applyOptions(options, 'dataField', prev, dataField);
  }

  // Method to set the value
  void setValue(dynamic value, {Options options}) async {
    void performUpdate() {
      final prev = this.value;
      this.value = value;
      this._applyOptions(options, 'value', prev, this.value);
    }

    if (this.beforeValueChange != null) {
      try {
        await beforeValueChange(value);
        performUpdate();
      } catch (e) {
        print(e);
      }
    } else {
      performUpdate();
    }
  }

  // Method to set the size option
  void setSize(int size, {Options options}) {
    final prev = this.size;
    this.size = size;
    this._applyOptions(options, 'size', prev, this.size);
  }

  // Method to set the from option
  void setFrom(int from, {Options options}) {
    final prev = this.from;
    this.from = from;
    this._applyOptions(options, 'from', prev, this.from);
  }

  // Method to set the fuzziness option
  void setFuzziness(dynamic fuzziness, {Options options}) {
    final prev = this.fuzziness;
    this.fuzziness = fuzziness;
    this._applyOptions(options, 'fuzziness', prev, this.fuzziness);
  }

  // Method to set the includeFields option
  void setIncludeFields(List<String> includeFields, {Options options}) {
    final prev = this.includeFields;
    this.includeFields = includeFields;
    this._applyOptions(options, 'includeFields', prev, includeFields);
  }

  // Method to set the excludeFields option
  void setExcludeFields(List<String> excludeFields, {Options options}) {
    final prev = this.excludeFields;
    this.excludeFields = excludeFields;
    this._applyOptions(options, 'excludeFields', prev, excludeFields);
  }

  // Method to set the sortBy option
  void setSortBy(SortType sortBy, {Options options}) {
    final prev = this.sortBy;
    this.sortBy = sortBy;
    this._applyOptions(options, 'sortBy', prev, sortBy);
  }

  // Method to set the sortBy option
  void setReact(Map<String, dynamic> react, {Options options}) {
    final prev = this.react;
    this.react = react;
    this._applyOptions(options, 'react', prev, react);
  }

  // Method to set the default query
  void setDefaultQuery(
      Map<dynamic, dynamic> Function(SearchComponent) defaultQuery,
      {Options options}) {
    final prev = this.defaultQuery;
    this.defaultQuery = defaultQuery;
    this._applyOptions(options, 'defaultQuery', prev, defaultQuery);
  }

  // Method to set the custom query
  void setCustomQuery(
      Map<dynamic, dynamic> Function(SearchComponent) customQuery,
      {Options options}) {
    final prev = this.customQuery;
    this.customQuery = customQuery;
    this._applyOptions(options, 'customQuery', prev, customQuery);
  }

  // Method to set the after key for composite aggs pagination
  void setAfter(Map after, {Options options}) {
    final prev = this.after;
    this.after = after;
    this._applyOptions(options, 'after', prev, after);
  }

  Future recordClick(Map<String, int> objects,
      {bool isSuggestionClick = false}) async {
    return this.click(objects, queryId: this.queryId);
  }

  Future recordConversions(List<String> objects) async {
    return this.conversion(objects, queryId: this.queryId);
  }

  Future handleError(dynamic err, {Option options}) {
    this._setError(err,
        options: new Options(stateChanges: options?.stateChanges));
    print(err);
    return Future.error(err);
  }

  // Method to execute the component's own query i.e default query
  Future triggerDefaultQuery({Option options}) async {
    // To prevent duplicate queries
    if (isEqual(this._query, this.componentQuery)) {
      return Future<bool>.value(true);
    }
    try {
      this._updateQuery();
      this._setRequestStatus(RequestStatus.PENDING);
      final results = await this._fetchRequest({
        'query': this.query is List ? this.query : [this.query],
        'settings': this.appbaseSettings?.toJSON()
      }, false);
      final prev = this.results;
      final Map rawResults =
          results != null && results[this.id] is Map ? results[this.id] : {};
      void afterResponse() {
        if (rawResults['aggregations'] != null) {
          this._handleAggregationResponse(rawResults['aggregations'],
              options: new Options(stateChanges: options?.stateChanges));
        }
        this._setRequestStatus(RequestStatus.INACTIVE);
        this._applyOptions(new Options(stateChanges: options?.stateChanges),
            'results', prev, this.results);
      }

      if ((this.type == null || this.type == QueryType.search) &&
          this.enablePopularSuggestions == true) {
        final rawPopularSuggestions =
            await this._fetchRequest(this.getSuggestionsQuery(), true);
        if (rawPopularSuggestions != null) {
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
        }
      } else {
        this._appendResults(rawResults);
        afterResponse();
      }
      return Future.value(rawResults);
    } catch (err) {
      return handleError(err);
    }
  }

  // Method to execute the query for watcher components
  Future triggerCustomQuery({Option options}) async {
    // Generate query again after resetting changes
    final generatedQuery = this._generateQuery();
    if (generatedQuery.requestBody.length != 0) {
      if (isEqual(this._query, generatedQuery.requestBody)) {
        return Future.value(true);
      }
      // set the request loading to true for all the requests
      generatedQuery.orderOfQueries.forEach((id) {
        final componentInstance = this._parent.getComponent(id);
        if (componentInstance != null) {
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
          componentInstance._setRequestStatus(RequestStatus.PENDING);
          // Update the query
          componentInstance._updateQuery();
        }
      });
      try {
        // Re-generate query after changes
        final finalGeneratedQuery = this._generateQuery();
        final results = await this._fetchRequest({
          'query': finalGeneratedQuery.requestBody,
          'settings': this.appbaseSettings?.toJSON()
        }, false);
        // Update the state for components
        finalGeneratedQuery.orderOfQueries.forEach((id) {
          final componentInstance = this._parent.getComponent(id);
          if (componentInstance != null) {
            componentInstance._setRequestStatus(RequestStatus.INACTIVE);
            // Reset value for dependent components
            componentInstance.setValue(null,
                options: new Options(
                    triggerDefaultQuery: false,
                    triggerCustomQuery: false,
                    stateChanges: true));
            // Update the results
            final prev = componentInstance.results;
            // Collect results from the response for a particular component
            Map rawResults =
                results != null && results[id] != null ? results[id] : {};
            // Set results
            if (rawResults['hits'] != null) {
              componentInstance.results.setRaw(rawResults);
              componentInstance._applyOptions(
                  new Options(stateChanges: options?.stateChanges),
                  'results',
                  prev,
                  componentInstance.results);
            }

            if (rawResults['aggregations'] != null) {
              componentInstance._handleAggregationResponse(
                  rawResults['aggregations'],
                  options: new Options(stateChanges: options?.stateChanges));
            }
          }
        });
        return Future.value(results);
      } catch (e) {
        return handleError(e);
      }
    }
    return Future.value(true);
  }

  Map getSuggestionsQuery() {
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

  // Method to subscribe the state changes
  subscribeToStateChanges(
      SubscriptionFunction fn, List<String> propertiesToSubscribe) {
    this.stateChanges.subscribe(fn, propertiesToSubscribe);
  }

  // Method to unsubscribe the state changes
  unsubscribeToStateChanges(SubscriptionFunction fn) {
    this.stateChanges.unsubscribe(fn);
  }

  // Method to clear results
  void clearResults({options: Options}) {
    final prev = this.results;
    this.results.setRaw({
      'hits': {'hits': []}
    });
    this._applyOptions(new Options(stateChanges: options?.stateChanges),
        'results', prev, this.results);
  }

  // To set the parent (SearchBase) instance for the component
  void setParent(SearchBase parent) {
    this._parent = parent;
  }

  /* -------- Private methods only for the internal use -------- */
  _appendResults(Map rawResults) {
    if (this.preserveResults != null &&
        rawResults != null &&
        rawResults['hits'] != null &&
        rawResults['hits']['hits'] is List &&
        this.results.rawData != null &&
        this.results.rawData['hits'] != null &&
        this.results.rawData['hits']['hits'] is List) {
      this.results.setRaw({
        ...rawResults,
        'hits': {
          ...rawResults['hits'],
          'hits': [
            ...this.results.rawData['hits']['hits'],
            ...rawResults['hits']['hits']
          ]
        }
      });
    } else {
      this.results.setRaw(rawResults);
    }
  }

  // Method to apply the changed based on set options
  void _applyOptions(Options options, String key, prevValue, nextValue) {
    // // Trigger mic events
    if (key == 'micStatus' && this.onMicStatusChange != null) {
      this.onMicStatusChange(nextValue, prev: prevValue);
    }
    // Trigger events
    if (key == 'query' && this.onQueryChange != null) {
      this.onQueryChange(nextValue, prev: prevValue);
    }
    if (key == 'value' && this.onValueChange != null) {
      this.onValueChange(nextValue, prev: prevValue);
    }
    if (key == 'error' && this.onError != null) {
      this.onError(nextValue);
    }
    if (key == 'results' && this.onResults != null) {
      this.onResults(nextValue, prev: prevValue);
    }
    if (key == 'aggregationData' && this.onAggregationData != null) {
      this.onAggregationData(nextValue, prev: prevValue);
    }
    if (key == 'requestStatus' && this.onRequestStatusChange != null) {
      this.onRequestStatusChange(nextValue, prev: prevValue);
    }
    if (options?.triggerDefaultQuery == true) {
      this.triggerDefaultQuery();
    }
    if (options?.triggerCustomQuery == true) {
      this.triggerCustomQuery();
    }
    if (options == null || options.stateChanges) {
      this.stateChanges.next({key: new Changes(prevValue, nextValue)}, key);
    }
  }

  Future<List<Suggestion>> getRecentSearches(
      {RecentSearchOptions queryOptions, Options options}) async {
    String queryString = '';
    if (queryOptions == null) {
      queryOptions = RecentSearchOptions();
    }
    void addParam(String key, String value) {
      if (queryString != "") {
        queryString += "&${key}=${value}";
      } else {
        queryString += "${key}=${value}";
      }
    }

    if (this.appbaseSettings != null && this.appbaseSettings.userId != null) {
      addParam('user_id', this.appbaseSettings.userId);
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
      queryOptions.customEvents.keys.forEach((key) {
        addParam(key, queryOptions.customEvents[key]);
      });
    }
    final String url =
        "${this.url}/_analytics/${this.index}/recent-searches?${queryString}";
    try {
      final res = await http.get(url, headers: this.headers);
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
          Suggestion(searchObject['key'], searchObject['key']))).toList();
      this._applyOptions(new Options(stateChanges: options?.stateChanges),
          'recentSearches', prev, this.recentSearches);
      return Future.value(this.recentSearches);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Map> _fetchRequest(
      Map requestBody, bool isPopularSuggestionsAPI) async {
    // remove undefined properties from request body
    final requestOptions = {
      'body': jsonEncode(requestBody),
      'headers': {...this.headers}
    };

    try {
      final finalRequestOptions =
          await this._handleTransformRequest(requestOptions);
      // set timestamp in request
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String suffix = '_reactivesearch.v3';
      final String index =
          isPopularSuggestionsAPI ? '.suggestions' : this.index;
      final String url = "${this.url}/$index/$suffix";
      final http.Response res = await http.post(
        url,
        headers: finalRequestOptions['headers'],
        body: finalRequestOptions['body'],
      );
      final responseHeaders = res.headers;
      // check if search component is present
      if (responseHeaders != null) {
        final queryID = responseHeaders['x-search-id'];
        if (queryID != null && queryID != '') {
          // if parent exists then set the queryID to parent
          if (this._parent != null) {
            this._parent.setQueryID(queryID);
          } else {
            this.setQueryID(queryID);
          }
        }
      }
      if (res.statusCode >= 500) {
        return Future.error(res);
      }
      if (res.statusCode >= 400) {
        return Future.error(res);
      }
      final data = jsonDecode(res.body);
      final transformedData = await this._handleTransformResponse(data);
      if (transformedData != null && transformedData.containsKey('error')) {
        return Future.error(transformedData);
      }
      return Future.value({
        ...transformedData,
        '_timestamp': timestamp,
        '_headers': responseHeaders
      });
    } catch (e) {
      print(e);
      return Future.error(e);
    }
  }

  // Method to generate the final query based on the component's value changes
  GenerateQueryResponse _generateQuery() {
    /**
     * This method performs the following tasks to generate the query
     * 1. Get all the watcher components for a particular component ID
     * 2. Make the request payload
     * 3. Execute the final query
     * 4. Update results and trigger events => Call 'setResults' or 'setAggregations' based on the results
     */
    if (this._parent != null) {
      final components = this._parent.getComponents();
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
        final component = this._parent.getComponent(watcherId);
        if (component != null) {
          requestQuery[watcherId] = component.componentQuery;
          // collect queries for all components defined in the `react` property
          // that have some value defined
          final flattenReact = flatReactProp(component.react, component.id);
          flattenReact.forEach((id) {
            // only add if not present
            if (requestQuery[id] == null) {
              final dependentComponent = this._parent.getComponent(id);
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

  Future<Map> _handleTransformResponse(Map res) {
    if (this.transformResponse != null) {
      return this.transformResponse(res);
    }
    return Future.value(res);
  }

  Future<Map> _handleTransformRequest(Map requestOptions) {
    if (this.transformRequest != null) {
      return this.transformRequest(requestOptions);
    }
    return Future<Map>.value(requestOptions);
  }

  _handleAggregationResponse(Map aggsResponse, {Options options}) {
    aggregationField = this.aggregationField;
    if ((aggregationField == null || aggregationField == "") &&
        this.dataField is String) {
      aggregationField = this.dataField;
    }
    final prev = this.aggregationData;
    if (aggsResponse[aggregationField] != null) {
      this.aggregationData.setRaw(aggsResponse[aggregationField]);
      if (aggsResponse[aggregationField] != null &&
          aggsResponse[aggregationField]['buckets'] is List) {
        final mapped = (aggsResponse[aggregationField]['buckets'] as List)
            .map((model) => Map.from(model));
        final data = mapped.toList();
        this.aggregationData.setData(aggregationField, data);
      }
      this._applyOptions(new Options(stateChanges: options?.stateChanges),
          'aggregationData', prev, this.aggregationData);
    }
  }

  _setError(dynamic error, {Options options}) {
    this._setRequestStatus(RequestStatus.ERROR);
    final prev = this.error;
    this.error = error;
    this._applyOptions(options, 'error', prev, this.error);
  }

  _setRequestStatus(RequestStatus requestStatus) {
    final prev = this.requestStatus;
    this.requestStatus = requestStatus;
    this._applyOptions(new Options(stateChanges: true), 'requestStatus', prev,
        this.requestStatus);
  }

  // Method to set the default query value
  void _updateQuery({List<Map> query}) {
    List<Map> prevQuery;
    prevQuery = this._query != null ? [...this._query] : this._query;
    final finalQuery = [this.componentQuery];
    final flattenReact = flatReactProp(this.react, this.id);
    flattenReact.forEach((id) {
      // only add if not present
      final watcherComponent = this._parent.getComponent(id);
      if (watcherComponent != null && watcherComponent.value != null) {
        // Set the execute to `false` for watcher components
        final watcherQuery = watcherComponent.componentQuery;
        watcherQuery['execute'] = false;
        // Add the query to request payload
        finalQuery.add(watcherQuery);
      }
    });
    this._query = query != null ? query : finalQuery;
    this._applyOptions(
        new Options(stateChanges: false), 'query', prevQuery, this._query);
  }

  // mic
  void _handleVoiceResults(Map payload, {Options options}) {
    if (payload != null &&
        payload["results"] != null &&
        payload["results"][0] != null &&
        payload["results"][0].isFinal is bool &&
        payload["results"][0].isFinal &&
        payload["results"][0][0] != null &&
        payload["results"][0][0].transcript is String &&
        payload["results"][0][0].transcript.trim()) {
      this.setValue(payload["results"][0][0].transcript.trim(),
          options: Options(
              triggerDefaultQuery: true,
              triggerCustomQuery: true,
              stateChanges: options?.stateChanges));
    }
  }

  void _stopMic() {
    if (this._micInstance) {
      this._micInstance.stop();
      this._micInstance = null;
      this._setMicStatus(MicStatusField.INACTIVE);
    }
  }

  void _setMicStatus(MicStatusField status, {Options options}) {
    final prevStatus = this._micStatus;
    this._micStatus = status;
    this._applyOptions(options, 'micStatus', prevStatus, this._micStatus);
  }
}
