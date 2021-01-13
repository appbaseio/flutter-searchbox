library flutter_searchbox;

import 'package:searchbase/searchbase.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// If the SearchBaseProvider.of method fails, this error will be thrown.
///
/// Often, when the `of` method fails, it is difficult to understand why since
/// there can be multiple causes. This error explains those causes so the user
/// can understand and fix the issue.
class SearchBaseProviderError<S> extends Error {
  /// Creates a SearchBaseProviderError
  SearchBaseProviderError();

  @override
  String toString() {
    return '''Error: No $S found. To fix, please try:
          
  * Wrapping your MaterialApp with the SearchBase, 
  rather than an individual Route
  * Providing full type information to your SearchBaseProvider, 
  SearchBase and SearchWidgetConnector
  * Ensure you are using consistent and complete imports. 
  E.g. always use `import 'package:my_app/app_state.dart';
  
If none of these solutions work, please file a bug at:
https://github.com/appbaseio/flutter-searchbox/issues/new
      ''';
  }
}

/// Provides a SearchBase instance to all descendants of this Widget. This should
/// generally be a root widget in your App. Connect a component by using [SearchWidget] or [SearchBox].
class SearchBaseProvider extends InheritedWidget {
  final SearchBase _searchbase;

  /// Create a [SearchBaseProvider] by passing in the required [searchbase] and [child]
  /// parameters.
  const SearchBaseProvider({
    Key key,
    @required SearchBase searchbase,
    @required Widget child,
  })  : assert(searchbase != null),
        assert(child != null),
        _searchbase = searchbase,
        super(key: key, child: child);

  static SearchBase of(BuildContext context, {bool listen = true}) {
    final provider = (listen
        ? context.dependOnInheritedWidgetOfExactType<SearchBaseProvider>()
        : context
            .getElementForInheritedWidgetOfExactType<SearchBaseProvider>()
            ?.widget) as SearchBaseProvider;

    if (provider == null) throw SearchBaseProviderError<SearchBaseProvider>();

    return provider._searchbase;
  }

  @override
  bool updateShouldNotify(SearchBaseProvider oldWidget) =>
      _searchbase != oldWidget._searchbase;
}

/// Build a Widget using the [BuildContext] and [ViewModel]. The [ViewModel] is
/// derived from the [SearchBase] using a [SearchBaseConverter].
typedef ViewModelBuilder<ViewModel> = Widget Function(
  BuildContext context,
  SearchWidget vm,
);

// Can be used to access the searchbase context
class SearchBaseConnector<S, ViewModel> extends StatelessWidget {
  final Widget Function(SearchBase searchbase) child;

  const SearchBaseConnector({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return child(SearchBaseProvider.of(context));
  }
}

class SearchWidgetListenerState<S, ViewModel>
    extends State<SearchWidgetListener<S, ViewModel>> {
  final ViewModelBuilder<ViewModel> builder;

  final SearchBase searchbase;

  final String id;

  final SearchWidget componentInstance;

  final List<String> subscribeTo;

  /// Defaults to `true`. It can be used to prevent the default query execution.
  final bool triggerQueryOnInit;

  /// Defaults to `true`. It can be used to prevent state updates.
  final bool shouldListenForChanges;

  /// Defaults to `true`. If set to `false` then component will not get removed from seachbase context i.e can participate in query generation.
  final bool destroyOnDispose;

  SearchWidgetListenerState({
    @required this.searchbase,
    @required this.builder,
    @required this.id,
    @required this.componentInstance,
    this.subscribeTo,
    this.triggerQueryOnInit,
    this.shouldListenForChanges,
    this.destroyOnDispose,
  })  : assert(searchbase != null),
        assert(builder != null),
        assert(id != null),
        assert(componentInstance != null);

  @override
  void initState() {
    // Subscribe to state changes
    if (this.shouldListenForChanges != false) {
      this
          .componentInstance
          .subscribeToStateChanges(subscribeToState, subscribeTo);
    }
    // Trigger the initial query
    if (triggerQueryOnInit != false) {
      componentInstance.triggerDefaultQuery();
    }
    super.initState();
  }

  @override
  void dispose() {
    // Remove subscriptions
    componentInstance.unsubscribeToStateChanges(subscribeToState);
    if (destroyOnDispose != false) {
      // Unregister component
      searchbase.unregister(id);
    }
    super.dispose();
  }

  void subscribeToState(Map<String, Changes> changes) {
    if (mounted) {
      // Trigger the rebuild on state changes
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      componentInstance,
    );
  }
}

class SearchWidgetListener<S, ViewModel> extends StatefulWidget {
  final ViewModelBuilder<ViewModel> builder;

  final SearchBase searchbase;

  final SearchWidget componentInstance;

  final List<String> subscribeTo;

  /// Defaults to `true`. It can be used to prevent the default query execution.
  final bool triggerQueryOnInit;

  /// Defaults to `true`. It can be used to prevent state updates.
  final bool shouldListenForChanges;

  /// Defaults to `true`. If set to `false` then component will not get removed from seachbase context i.e can participate in query generation.
  final bool destroyOnDispose;

  // Properties to configure search component
  final String id;

  final String index;
  final String url;
  final String credentials;
  final Map<String, String> headers;
  // to enable the recording of analytics
  final AppbaseSettings appbaseConfig;

  final QueryType type;

  final Map<String, dynamic> react;

  final String queryFormat;

  final dynamic dataField;

  final String categoryField;

  final String categoryValue;

  final String nestedField;

  final int from;

  final int size;

  final SortType sortBy;

  final dynamic value;

  final String aggregationField;

  final Map after;

  final bool includeNullValues;

  final List<String> includeFields;

  final List<String> excludeFields;

  final dynamic fuzziness;

  final bool searchOperators;

  final bool highlight;

  final dynamic highlightField;

  final Map customHighlight;

  final int interval;

  final List<String> aggregations;

  final String missingLabel;

  final bool showMissing;

  final Map Function(SearchWidget component) defaultQuery;

  final Map Function(SearchWidget component) customQuery;

  final bool execute;

  final bool enableSynonyms;

  final String selectAllLabel;

  final bool pagination;

  final bool queryString;

  // To enable the popular suggestions
  final bool enablePopularSuggestions;

  // size of the popular suggestions
  final int maxPopularSuggestions;

  // To show the distinct suggestions
  final bool showDistinctSuggestions;

  // preserve the data for infinite loading
  final bool preserveResults;
  // callbacks
  final TransformRequest transformRequest;

  final TransformResponse transformResponse;

  final List<Map> results;

  /* ---- callbacks to create the side effects while querying ----- */

  final Future Function(String value) beforeValueChange;

  /* ------------- change events -------------------------------- */

  // called when value changes
  final void Function(String next, {String prev}) onValueChange;

  // called when results change
  final void Function(List<Map> next, {List<Map> prev}) onResults;

  // called when composite aggregationData change
  final void Function(List<Map> next, {List<Map> prev}) onAggregationData;
  // called when there is an error while fetching results
  final void Function(Error error) onError;

  // called when request status changes
  final void Function(String next, {String prev}) onRequestStatusChange;

  // called when query changes
  final void Function(Map next, {Map prev}) onQueryChange;

  SearchWidgetListener({
    Key key,
    @required this.searchbase,
    @required this.builder,
    @required this.id,
    this.index,
    this.credentials,
    this.url,
    this.subscribeTo,
    this.triggerQueryOnInit,
    this.shouldListenForChanges,
    this.destroyOnDispose,
    // properties to configure search component class
    this.appbaseConfig,
    this.transformRequest,
    this.transformResponse,
    this.headers,
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
    this.enablePopularSuggestions,
    this.maxPopularSuggestions,
    this.showDistinctSuggestions,
    this.preserveResults,
    this.value,
    this.results,
  })  : assert(searchbase != null),
        assert(builder != null),
        assert(id != null),
        // Register component
        componentInstance = searchbase.register(id, {
          'index': index,
          'url': url,
          'credentials': credentials,
          'headers': headers,
          'transformRequest': transformRequest,
          'transformResponse': transformResponse,
          'appbaseConfig': appbaseConfig,
          'type': type,
          'dataField': dataField,
          'react': react,
          'queryFormat': queryFormat,
          'categoryField': categoryField,
          'categoryValue': categoryValue,
          'nestedField': nestedField,
          'from': from,
          'size': size,
          'sortBy': sortBy,
          'aggregationField': aggregationField,
          'after': after,
          'includeNullValues': includeNullValues,
          'includeFields': includeFields,
          'excludeFields': excludeFields,
          'results': results,
          'fuzziness': fuzziness,
          'searchOperators': searchOperators,
          'highlight': highlight,
          'highlightField': highlightField,
          'customHighlight': customHighlight,
          'interval': interval,
          'aggregations': aggregations,
          'missingLabel': missingLabel,
          'showMissing': showMissing,
          'execute': execute,
          'enableSynonyms': enableSynonyms,
          'selectAllLabel': selectAllLabel,
          'pagination': pagination,
          'queryString': queryString,
          'defaultQuery': defaultQuery,
          'customQuery': customQuery,
          'beforeValueChange': beforeValueChange,
          'onValueChange': onValueChange,
          'onResults': onResults,
          'onAggregationData': onAggregationData,
          'onError': onError,
          'onRequestStatusChange': onRequestStatusChange,
          'onQueryChange': onQueryChange,
          'enablePopularSuggestions': enablePopularSuggestions,
          'maxPopularSuggestions': maxPopularSuggestions,
          'showDistinctSuggestions': showDistinctSuggestions,
          'preserveResults': preserveResults,
          'value': value,
        }),
        super(key: key);

  @override
  SearchWidgetListenerState createState() =>
      SearchWidgetListenerState<S, ViewModel>(
        id: id,
        searchbase: searchbase,
        componentInstance: componentInstance,
        builder: builder,
        subscribeTo: subscribeTo,
        triggerQueryOnInit: triggerQueryOnInit,
        shouldListenForChanges: shouldListenForChanges,
        destroyOnDispose: destroyOnDispose,
      );
}

/// SearchWidgetConnector performs the following tasks
/// - Register a component with id
/// - unregister a component
/// - trigger rebuid based on state changes
class SearchWidgetConnector<S, ViewModel> extends StatelessWidget {
  /// Build a Widget using the [BuildContext] and [ViewModel]. The [ViewModel]
  /// is created by the [converter] function.
  final ViewModelBuilder<ViewModel> builder;

  final List<String> subscribeTo;

  /// Defaults to `true`. It can be used to prevent the default query execution.
  final bool triggerQueryOnInit;

  /// Defaults to `true`. It can be used to prevent state updates.
  final bool shouldListenForChanges;

  /// Defaults to `true`. If set to `false` then component will not get removed from seachbase context i.e can participate in query generation.
  final bool destroyOnDispose;

  // Properties to configure search component
  final String id;

  final String index;
  final String url;
  final String credentials;
  final Map<String, String> headers;
  // to enable the recording of analytics
  final AppbaseSettings appbaseConfig;

  final QueryType type;

  final Map<String, dynamic> react;

  final String queryFormat;

  final dynamic dataField;

  final String categoryField;

  final String categoryValue;

  final String nestedField;

  final int from;

  final int size;

  final SortType sortBy;

  final dynamic value;

  final String aggregationField;

  final Map after;

  final bool includeNullValues;

  final List<String> includeFields;

  final List<String> excludeFields;

  final dynamic fuzziness;

  final bool searchOperators;

  final bool highlight;

  final dynamic highlightField;

  final Map customHighlight;

  final int interval;

  final List<String> aggregations;

  final String missingLabel;

  final bool showMissing;

  final Map Function(SearchWidget component) defaultQuery;

  final Map Function(SearchWidget component) customQuery;

  final bool execute;

  final bool enableSynonyms;

  final String selectAllLabel;

  final bool pagination;

  final bool queryString;

  // To enable the popular suggestions
  final bool enablePopularSuggestions;

  // size of the popular suggestions
  final int maxPopularSuggestions;

  // To show the distinct suggestions
  final bool showDistinctSuggestions;

  // preserve the data for infinite loading
  final bool preserveResults;
  // callbacks
  final TransformRequest transformRequest;

  final TransformResponse transformResponse;

  final List<Map> results;

  /* ---- callbacks to create the side effects while querying ----- */

  final Future Function(String value) beforeValueChange;

  /* ------------- change events -------------------------------- */

  // called when value changes
  final void Function(String next, {String prev}) onValueChange;

  // called when results change
  final void Function(List<Map> next, {List<Map> prev}) onResults;

  // called when composite aggregationData change
  final void Function(List<Map> next, {List<Map> prev}) onAggregationData;
  // called when there is an error while fetching results
  final void Function(Error error) onError;

  // called when request status changes
  final void Function(String next, {String prev}) onRequestStatusChange;

  // called when query changes
  final void Function(Map next, {Map prev}) onQueryChange;

  SearchWidgetConnector({
    Key key,
    @required this.builder,
    @required this.id,
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
    this.enablePopularSuggestions,
    this.maxPopularSuggestions,
    this.showDistinctSuggestions,
    this.preserveResults,
    this.value,
    this.results,
  })  : assert(builder != null),
        assert(id != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SearchBaseConnector(
        child: (searchbase) => SearchWidgetListener(
            id: id,
            searchbase: searchbase,
            builder: builder,
            subscribeTo: subscribeTo,
            triggerQueryOnInit: triggerQueryOnInit,
            shouldListenForChanges: shouldListenForChanges,
            destroyOnDispose: destroyOnDispose,
            // properties to configure search component
            credentials: credentials,
            index: index,
            url: url,
            appbaseConfig: appbaseConfig,
            transformRequest: transformRequest,
            transformResponse: transformResponse,
            headers: headers,
            type: type,
            react: react,
            queryFormat: queryFormat,
            dataField: dataField,
            categoryField: categoryField,
            categoryValue: categoryValue,
            nestedField: nestedField,
            from: from,
            size: size,
            sortBy: sortBy,
            aggregationField: aggregationField,
            after: after,
            includeNullValues: includeNullValues,
            includeFields: includeFields,
            excludeFields: excludeFields,
            fuzziness: fuzziness,
            searchOperators: searchOperators,
            highlight: highlight,
            highlightField: highlightField,
            customHighlight: customHighlight,
            interval: interval,
            aggregations: aggregations,
            missingLabel: missingLabel,
            showMissing: showMissing,
            execute: execute,
            enableSynonyms: enableSynonyms,
            selectAllLabel: selectAllLabel,
            pagination: pagination,
            queryString: queryString,
            defaultQuery: defaultQuery,
            customQuery: customQuery,
            beforeValueChange: beforeValueChange,
            onValueChange: onValueChange,
            onResults: onResults,
            onAggregationData: onAggregationData,
            onError: onError,
            onRequestStatusChange: onRequestStatusChange,
            onQueryChange: onQueryChange,
            enablePopularSuggestions: enablePopularSuggestions,
            maxPopularSuggestions: maxPopularSuggestions,
            showDistinctSuggestions: showDistinctSuggestions,
            preserveResults: preserveResults,
            value: value,
            results: results));
  }
}

class SearchBox<S, ViewModel> extends SearchDelegate<String> {
  // Properties to configure search component
  final String id;

  final String index;
  final String url;
  final String credentials;
  final Map<String, String> headers;
  // to enable the recording of analytics
  final AppbaseSettings appbaseConfig;

  final QueryType type;

  final Map<String, dynamic> react;

  final String queryFormat;

  final dynamic dataField;

  final String categoryField;

  final String categoryValue;

  final String nestedField;

  final int from;

  final int size;

  final SortType sortBy;

  final dynamic value;

  final String aggregationField;

  final Map after;

  final bool includeNullValues;

  final List<String> includeFields;

  final List<String> excludeFields;

  final dynamic fuzziness;

  final bool searchOperators;

  final bool highlight;

  final dynamic highlightField;

  final Map customHighlight;

  final int interval;

  final List<String> aggregations;

  final String missingLabel;

  final bool showMissing;

  final Map Function(SearchWidget component) defaultQuery;

  final Map Function(SearchWidget component) customQuery;

  final bool execute;

  final bool enableSynonyms;

  final String selectAllLabel;

  final bool pagination;

  final bool queryString;

  // To enable the popular suggestions
  final bool enablePopularSuggestions;

  // size of the popular suggestions
  final int maxPopularSuggestions;

  // To show the distinct suggestions
  final bool showDistinctSuggestions;

  // preserve the data for infinite loading
  final bool preserveResults;
  // callbacks
  final TransformRequest transformRequest;

  final TransformResponse transformResponse;

  final List<Map> results;

  /* ---- callbacks to create the side effects while querying ----- */

  final Future Function(String value) beforeValueChange;

  /* ------------- change events -------------------------------- */

  // called when value changes
  final void Function(String next, {String prev}) onValueChange;

  // called when results change
  final void Function(List<Map> next, {List<Map> prev}) onResults;

  // called when composite aggregationData change
  final void Function(List<Map> next, {List<Map> prev}) onAggregationData;
  // called when there is an error while fetching results
  final void Function(Error error) onError;

  // called when request status changes
  final void Function(String next, {String prev}) onRequestStatusChange;

  // called when query changes
  final void Function(Map next, {Map prev}) onQueryChange;

  // SearchBox specific properties

  // To enable recent searches
  final bool enableRecentSearches;

  // To enable auto fill
  final bool showAutoFill;

  SearchBox({
    Key key,
    @required this.id,
    // properties to configure search component
    this.credentials,
    this.index,
    this.url,
    this.appbaseConfig,
    this.transformRequest,
    this.transformResponse,
    this.headers,
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
    this.enablePopularSuggestions,
    this.maxPopularSuggestions,
    this.showDistinctSuggestions = true,
    this.preserveResults,
    this.value,
    this.results,
    // searchbox specific properties
    this.enableRecentSearches = false,
    this.showAutoFill = false,
  }) : assert(id != null);

  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final ThemeData theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SearchWidget component = SearchBaseProvider.of(context).getComponent(id);
      if (component != null && query.isNotEmpty) {
        component.setValue(query, options: Options(triggerCustomQuery: true));
        close(context, null);
      }
    });
    return Container();
  }

  ListView getSuggestionList(
      BuildContext context, SearchWidget SearchWidget, List<Suggestion> list,
      {bool isRecentSearch = false}) {
    List<Widget> suggestionsList = list
        .map((suggestion) => Container(
            alignment: Alignment.topLeft,
            height: 50,
            child: Container(
                child: ListTile(
                  onTap: () {
                    // Perform actions on suggestions tap
                    SearchWidget.setValue(suggestion.value,
                        options: Options(triggerCustomQuery: true));
                    this.query = suggestion.value;

                    String objectId = suggestion.source != null
                        ? null
                        : suggestion.source['_id'];
                    if (objectId != null && suggestion.clickId != null) {
                      // Record click analytics
                      SearchWidget.recordClick({objectId: suggestion.clickId},
                          isSuggestionClick: true);
                    }

                    close(context, null);
                  },
                  leading: isRecentSearch
                      ? Icon(Icons.history)
                      : (suggestion.source != null &&
                              suggestion.source['_popular_suggestion'] == true)
                          ? Icon(Icons.trending_up)
                          : Icon(Icons.search),
                  title: Text(suggestion.label,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: showAutoFill == true
                      ? IconButton(
                          icon: Icon(FeatherIcons.arrowUpLeft),
                          onPressed: () => {this.query = suggestion.value})
                      : null,
                ),
                decoration: new BoxDecoration(
                    border: new Border(
                        bottom: new BorderSide(
                            color: Color(0xFFC8C8C8), width: 0.5))))))
        .toList();
    return ListView(
        padding: const EdgeInsets.all(8), children: suggestionsList);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SearchWidgetConnector(
        id: id,
        triggerQueryOnInit: false,
        destroyOnDispose: false,
        subscribeTo: [
          'error',
          'requestPending',
          'results',
          'value',
          'recentSearches'
        ],
        // properties to configure search component
        credentials: credentials,
        index: index,
        url: url,
        appbaseConfig: appbaseConfig,
        transformRequest: transformRequest,
        transformResponse: transformResponse,
        headers: headers,
        type: type,
        react: react,
        queryFormat: queryFormat,
        dataField: dataField,
        categoryField: categoryField,
        categoryValue: categoryValue,
        nestedField: nestedField,
        from: from,
        size: size,
        sortBy: sortBy,
        aggregationField: aggregationField,
        after: after,
        includeNullValues: includeNullValues,
        includeFields: includeFields,
        excludeFields: excludeFields,
        fuzziness: fuzziness,
        searchOperators: searchOperators,
        highlight: highlight,
        highlightField: highlightField,
        customHighlight: customHighlight,
        interval: interval,
        aggregations: aggregations,
        missingLabel: missingLabel,
        showMissing: showMissing,
        execute: execute,
        enableSynonyms: enableSynonyms,
        selectAllLabel: selectAllLabel,
        pagination: pagination,
        queryString: queryString,
        defaultQuery: defaultQuery,
        customQuery: customQuery,
        beforeValueChange: beforeValueChange,
        onValueChange: onValueChange,
        onResults: onResults,
        onAggregationData: onAggregationData,
        onError: onError,
        onRequestStatusChange: onRequestStatusChange,
        onQueryChange: onQueryChange,
        enablePopularSuggestions: enablePopularSuggestions,
        maxPopularSuggestions: maxPopularSuggestions,
        showDistinctSuggestions: showDistinctSuggestions,
        preserveResults: preserveResults,
        value: value,
        results: results,
        builder: (context, searchWidget) {
          if (query != searchWidget.value) {
            if (query.isEmpty) {
              if (enableRecentSearches == true) {
                // Fetch recent searches
                searchWidget.getRecentSearches();
              }
            }
            // To fetch the suggestions
            searchWidget.setValue(query,
                options: Options(triggerDefaultQuery: query.isNotEmpty));
          }
          if (query.isEmpty &&
              searchWidget.recentSearches?.isNotEmpty == true) {
            return getSuggestionList(
                context, searchWidget, searchWidget.recentSearches,
                isRecentSearch: true);
          }
          final List<Suggestion> popularSuggestions = searchWidget.suggestions
              .where((suggestion) =>
                  suggestion.source != null &&
                  suggestion.source['_popular_suggestion'] == true)
              .toList();
          List<Suggestion> filteredSuggestions = searchWidget.suggestions
              .where((suggestion) =>
                  suggestion.source != null &&
                  suggestion.source['_popular_suggestion'] != true)
              .toList();
          // Limit the suggestions by size
          if (filteredSuggestions.length > this.size) {
            filteredSuggestions.sublist(0, this.size);
          }
          // Append popular suggestions at bottom
          if (popularSuggestions.isNotEmpty) {
            filteredSuggestions = [
              ...filteredSuggestions,
              ...popularSuggestions
            ];
          }
          return (popularSuggestions.isEmpty && filteredSuggestions.isEmpty)
              ? ((query.isNotEmpty && searchWidget.requestPending == false)
                  ? Container(
                      child: Text('No items found'),
                    )
                  : Container())
              : getSuggestionList(context, searchWidget, filteredSuggestions);
        });
  }
}
