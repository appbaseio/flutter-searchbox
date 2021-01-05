import 'package:searchbase/src/base.dart';
import 'types.dart';
import 'searchcomponent.dart';
import 'constants.dart';

/**
 * SearchBase class acts like the ReactiveBase component.
 * It works as a centralized store that will have the info about active/registered components.
 */
class SearchBase extends Base {
  /* ------ Private properties only for the internal use ----------- */
  // active components
  Map<String, SearchComponent> _components;

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
    this._components = {};
  }

  // methods
  // To register a component
  SearchComponent register(String componentId, dynamic component) {
    if (componentId == "") {
      throw (ErrorMessages[InvalidIndex]);
    }
    if (this._components.containsKey(componentId)) {
      // return existing instance
      return this._components[componentId];
    }
    SearchComponent componentInstance;
    if (component != null && component is Map) {
      // create instance from object with all the options
      componentInstance = new SearchComponent(
        component["index"] != null ? component["index"] : this.index,
        component["url"] != null ? component["url"] : this.url,
        component["credentials"] != null
            ? component["credentials"]
            : this.credentials,
        componentId,
        headers: component["headers"] is Map<String, String>
            ? component["headers"]
            : this.headers,
        transformRequest: component["transformRequest"] is TransformRequest
            ? component["transformRequest"]
            : this.transformRequest,
        transformResponse: component["transformResponse"] is TransformResponse
            ? component["transformResponse"]
            : this.transformResponse,
        appbaseConfig: component["appbaseConfig"] is AppbaseSettings
            ? component["appbaseConfig"]
            : this.appbaseConfig,
        type: component["type"],
        dataField: component["dataField"],
        react: component["react"],
        queryFormat: component[" queryFormat"],
        categoryField: component["categoryField"],
        categoryValue: component["categoryValue"],
        nestedField: component["nestedField"],
        from: component["from"],
        size: component["size"],
        sortBy: component["sortBy"],
        aggregationField: component["aggregationField"],
        after: component["after"],
        includeNullValues: component["includeNullValues"],
        includeFields: component["includeFields"],
        excludeFields: component["excludeFields"],
        fuzziness: component["fuzziness"],
        searchOperators: component["searchOperators"],
        highlight: component["highlight"],
        highlightField: component["highlightField"],
        customHighlight: component["customHighlight"],
        interval: component["interval"],
        aggregations: component["aggregations"],
        missingLabel: component["missingLabel"],
        showMissing: component["showMissing"],
        execute: component["execute"],
        enableSynonyms: component["enableSynonyms"],
        selectAllLabel: component["selectAllLabel"],
        pagination: component["pagination"],
        queryString: component["queryString"],
        defaultQuery: component["defaultQuery"],
        customQuery: component["customQuery"],
        beforeValueChange: component["beforeValueChange"],
        onValueChange: component["onValueChange"],
        onResults: component["onResults"],
        onAggregationData: component["onAggregationData"],
        onError: component["onError"],
        onRequestStatusChange: component["onRequestStatusChange"],
        onQueryChange: component["onQueryChange"],
        onMicStatusChange: component["onMicStatusChange"],
        enablePopularSuggestions: component["enablePopularSuggestions"],
        maxPopularSuggestions: component["maxPopularSuggestions"],
        showDistinctSuggestions: component["showDistinctSuggestions"],
        preserveResults: component["preserveResults"],
        value: component["value"],
      );
    } else if (component is SearchComponent) {
      componentInstance = component;
      // set the id property on instance
      componentInstance.id = componentId;
    }
    // register component
    this._components[componentId] = componentInstance;
    // set the search base instance as parent
    componentInstance.setParent(this);
    return componentInstance;
  }

  // To un-register a component
  void unregister(String componentId) {
    if (componentId == '') {
      this._components.remove(componentId);
    }
  }

  // To get component instance
  SearchComponent getComponent(String componentId) {
    return this._components[componentId];
  }

  // To get the list of registered components
  Map<String, SearchComponent> getComponents() {
    return this._components;
  }
}
