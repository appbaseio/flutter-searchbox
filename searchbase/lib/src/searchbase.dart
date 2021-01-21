import 'package:searchbase/src/base.dart';
import 'types.dart';
import 'searchwidget.dart';
import 'constants.dart';

/// The [SearchBase] class holds the state for all the active [SearchWidget](s) and can be used to provide the global configuration to the registered [SearchWidget](s).
///
/// It serves the following tasks:
/// -   To `register` a [SearchWidget] by unique `id`
/// -   To `unregister` a [SearchWidget] by `id`
/// -   To retrieve the instance of the [SearchWidget] class by `id`
/// -   To provide an ability to watch registered widget reactively with the help of the `react` property.
///
/// Note:
///
/// 1. The `id` property is a unique identifier to each search widget.
/// 2. The [SearchBase] class is useful when you're using multiple search widgets that depend on each other.
/// For example, a filter widget (to display the category options) depends on the search query (search widget).
/// If you're only using a single widget then [SearchWidget] class should work well.
class SearchBase extends Base {
  /* ------ Private properties only for the internal use ----------- */
  // active widgets
  Map<String, SearchWidget> _searchWidgets;

  SearchBase(String index, String url, String credentials,
      {AppbaseSettings appbaseConfig,
      TransformRequest transformRequest,
      TransformResponse transformResponse,
      Map<String, String> headers})
      : super(index, url, credentials,
            appbaseConfig: appbaseConfig,
            transformRequest: transformRequest,
            transformResponse: transformResponse,
            headers: headers) {
    this._searchWidgets = {};
  }

  // methods

  /// This method can be used to register a search widget with a unique `id`.
  ///
  /// It returns the instance of the [SearchWidget] class.
  /// The following example registers a widget with the second param as a Map.
  /// ```dart
  /// final searchBase = SearchBase(
  ///   'gitxplore-app',
  ///   'https://@arc-cluster-appbase-demo-6pjy6z.searchbase.io',
  ///   'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61'
  /// );
  ///
  /// searchBase.register('search-widget', {
  ///   dataField: ['title', 'description'],
  ///   value: ''
  /// });
  /// ```
  ///
  /// The following example registers a [SearchWidget] with second param as an instance of [SearchWidget] class.
  ///
  /// ```dart
  /// final searchBase = SearchBase(
  ///   'gitxplore-app',
  ///   'https://@arc-cluster-appbase-demo-6pjy6z.searchbase.io',
  ///   'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61'
  /// );
  ///
  /// final searchWidget = SearchWidget(
  ///   'gitxplore-app',
  ///   'https://@arc-cluster-appbase-demo-6pjy6z.searchbase.io',
  ///   'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61',
  ///   'search-widget',
  ///   dataField: ['title', 'description'],
  ///   value: ''
  /// );
  ///
  /// searchBase.register('search-widget', searchWidget);
  ///
  /// ```
  ///
  /// Additionally, you can override the global configurations by defining it for a particular widget. For example, to register a widget with a different `index` name.
  ///
  SearchWidget register(String widgetId, dynamic searchWidget) {
    if (widgetId == "") {
      throw (ErrorMessages[InvalidIndex]);
    }
    if (this._searchWidgets.containsKey(widgetId)) {
      // return existing instance
      return this._searchWidgets[widgetId];
    }
    SearchWidget componentInstance;
    if (searchWidget != null && searchWidget is Map) {
      // create instance from object with all the options
      componentInstance = SearchWidget(
        searchWidget["index"] != null ? searchWidget["index"] : this.index,
        searchWidget["url"] != null ? searchWidget["url"] : this.url,
        searchWidget["credentials"] != null
            ? searchWidget["credentials"]
            : this.credentials,
        widgetId,
        headers: searchWidget["headers"] is Map<String, String>
            ? searchWidget["headers"]
            : this.headers,
        transformRequest: searchWidget["transformRequest"] is TransformRequest
            ? searchWidget["transformRequest"]
            : this.transformRequest,
        transformResponse:
            searchWidget["transformResponse"] is TransformResponse
                ? searchWidget["transformResponse"]
                : this.transformResponse,
        appbaseConfig: searchWidget["appbaseConfig"] is AppbaseSettings
            ? searchWidget["appbaseConfig"]
            : this.appbaseConfig,
        type: searchWidget["type"],
        dataField: searchWidget["dataField"],
        react: searchWidget["react"],
        queryFormat: searchWidget[" queryFormat"],
        categoryField: searchWidget["categoryField"],
        categoryValue: searchWidget["categoryValue"],
        nestedField: searchWidget["nestedField"],
        from: searchWidget["from"],
        size: searchWidget["size"],
        sortBy: searchWidget["sortBy"],
        aggregationField: searchWidget["aggregationField"],
        after: searchWidget["after"],
        includeNullValues: searchWidget["includeNullValues"],
        includeFields: searchWidget["includeFields"],
        excludeFields: searchWidget["excludeFields"],
        results: searchWidget["results"],
        fuzziness: searchWidget["fuzziness"],
        searchOperators: searchWidget["searchOperators"],
        highlight: searchWidget["highlight"],
        highlightField: searchWidget["highlightField"],
        customHighlight: searchWidget["customHighlight"],
        interval: searchWidget["interval"],
        aggregations: searchWidget["aggregations"],
        missingLabel: searchWidget["missingLabel"],
        showMissing: searchWidget["showMissing"],
        enableSynonyms: searchWidget["enableSynonyms"],
        selectAllLabel: searchWidget["selectAllLabel"],
        pagination: searchWidget["pagination"],
        queryString: searchWidget["queryString"],
        defaultQuery: searchWidget["defaultQuery"],
        customQuery: searchWidget["customQuery"],
        beforeValueChange: searchWidget["beforeValueChange"],
        onValueChange: searchWidget["onValueChange"],
        onResults: searchWidget["onResults"],
        onAggregationData: searchWidget["onAggregationData"],
        onError: searchWidget["onError"],
        onRequestStatusChange: searchWidget["onRequestStatusChange"],
        onQueryChange: searchWidget["onQueryChange"],
        enablePopularSuggestions: searchWidget["enablePopularSuggestions"],
        maxPopularSuggestions: searchWidget["maxPopularSuggestions"],
        showDistinctSuggestions: searchWidget["showDistinctSuggestions"],
        preserveResults: searchWidget["preserveResults"],
        value: searchWidget["value"],
      );
    } else if (searchWidget is SearchWidget) {
      componentInstance = searchWidget;
      // set the id property on instance
      componentInstance.id = widgetId;
    }
    // register component
    this._searchWidgets[widgetId] = componentInstance;
    // set the search base instance as parent
    componentInstance.setParent(this);
    return componentInstance;
  }

  /// This method is useful to unregister a [SearchWidget] by `id`.
  ///
  /// It is a good practice to unregister (remove) an unmounted/unused widget to avoid any side-effects.
  void unregister(String widgetId) {
    if (widgetId != '') {
      this._searchWidgets.remove(widgetId);
    }
  }

  /// This method can be used to retrieve the instance of the [SearchWidget] class for a particular widget by `id`.
  SearchWidget getSearchWidget(String widgetId) {
    return this._searchWidgets[widgetId];
  }

  /// This method returns all the active widgets registered on the `SearchBase` instance.
  ///
  /// The widgets state can be used for various purposes, for example, to display the selected filters in the UI.
  Map<String, SearchWidget> getActiveWidgets() {
    return this._searchWidgets;
  }
}
