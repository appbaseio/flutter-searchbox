import 'types.dart';
import 'searchcontroller.dart';
import 'constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base.dart';

/// The [SearchBase] class holds the state for all the active [SearchController](s) and can be used to provide the global configuration to the registered [SearchController](s).
///
/// It serves the following tasks:
/// -   To `register` a [SearchController] by unique `id`
/// -   To `unregister` a [SearchController] by `id`
/// -   To retrieve the instance of the [SearchController] class by `id`
/// -   To provide an ability to watch registered widget reactively with the help of the `react` property.
///
/// Note:
///
/// 1. The `id` property is a unique identifier to each search widget.
/// 2. The [SearchBase] class is useful when you're using multiple search widgets that depend on each other.
/// For example, a filter widget (to display the category options) depends on the search query (search widget).
/// If you're only using a single widget then [SearchController] class should work well.
class SearchBase extends Base {
  /* ------ Private properties only for the internal use ----------- */
  // active widgets
  late Map<String, SearchController> _searchWidgets;

  late int _initialTimeStamp;

  /// To define the initial query sync wait time in milliseconds.
  ///
  /// We wait for `initialQueriesSyncTime` time to combine the individual widget queries to a single network request at initial load.
  /// This prop is helpful to optimize the performance when you have a lot of filters on the search page, using a wait time of 100-200 milliseconds would merge the multiple requests into a single request.
  late int initialQueriesSyncTime;

  late bool _lock = false;

  List<Map> _requestStack = [];

  SearchBase(String index, String url, String credentials,
      {AppbaseSettings? appbaseConfig,
      TransformRequest? transformRequest,
      TransformResponse? transformResponse,
      int? initialQueriesSyncTime,
      Map<String, String>? headers})
      : super(index, url, credentials,
            appbaseConfig: appbaseConfig,
            transformRequest: transformRequest,
            transformResponse: transformResponse,
            headers: headers) {
    this._searchWidgets = {};
    if (initialQueriesSyncTime != null) {
      this.initialQueriesSyncTime = initialQueriesSyncTime;
    } else {
      this.initialQueriesSyncTime = 100;
    }
    this._initialTimeStamp = DateTime.now().millisecondsSinceEpoch;
  }

  // methods

  /// This method can be used to register a search widget with a unique `id`.
  ///
  /// It returns the instance of the [SearchController] class.
  /// The following example registers a widget with the second param as a Map.
  /// ```dart
  /// final searchBase = SearchBase(
  ///   'gitxplore-app',
  ///   'https://@appbase-demo-ansible-abxiydt-arc.searchbase.io',
  ///   'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61'
  /// );
  ///
  /// searchBase.register('search-widget', {
  ///   dataField: ['title', 'description'],
  ///   value: ''
  /// });
  /// ```
  ///
  /// The following example registers a [SearchController] with second param as an instance of [SearchController] class.
  ///
  /// ```dart
  /// final searchBase = SearchBase(
  ///   'gitxplore-app',
  ///   'https://@appbase-demo-ansible-abxiydt-arc.searchbase.io',
  ///   'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61'
  /// );
  ///
  /// final searchController = SearchController(
  ///   'gitxplore-app',
  ///   'https://@appbase-demo-ansible-abxiydt-arc.searchbase.io',
  ///   'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61',
  ///   'search-widget',
  ///   dataField: ['title', 'description'],
  ///   value: ''
  /// );
  ///
  /// searchBase.register('search-widget', searchController);
  ///
  /// ```
  ///
  /// Additionally, you can override the global configurations by defining it for a particular widget. For example, to register a widget with a different `index` name.
  ///
  SearchController register(String widgetId, dynamic searchController) {
    if (widgetId.isEmpty) {
      throw (ErrorMessages[InvalidIndex]);
    }
    if (this._searchWidgets.containsKey(widgetId)) {
      // return existing instance

      // If the widget is already registered and the componentConfig is a map, update the existing instance with the new configuration
      if (searchController is Map) {
        this._searchWidgets[widgetId]!.updateConfig(searchController);
      }

      return this._searchWidgets[widgetId]!;
    }
    SearchController? componentInstance;
    if (searchController != null && searchController is Map) {
      // create instance from object with all the options
      componentInstance = SearchController(
        searchController["index"] ?? this.index,
        searchController["url"] ?? this.url,
        searchController["credentials"] ?? this.credentials,
        widgetId,
        headers:
            searchController["headers"] as Map<String, String>? ?? this.headers,
        transformRequest:
            searchController["transformRequest"] as TransformRequest? ??
                this.transformRequest,
        transformResponse:
            searchController["transformResponse"] as TransformResponse? ??
                this.transformResponse,
        appbaseConfig: searchController["appbaseConfig"] as AppbaseSettings? ??
            this.appbaseConfig,
        type: searchController["type"],
        dataField: searchController["dataField"],
        react: searchController["react"],
        queryFormat: searchController[" queryFormat"],
        categoryField: searchController["categoryField"],
        categoryValue: searchController["categoryValue"],
        nestedField: searchController["nestedField"],
        from: searchController["from"],
        size: searchController["size"],
        sortBy: searchController["sortBy"],
        aggregationField: searchController["aggregationField"],
        aggregationSize: searchController["aggregationSize"],
        after: searchController["after"],
        includeNullValues: searchController["includeNullValues"],
        includeFields: searchController["includeFields"],
        excludeFields: searchController["excludeFields"],
        fuzziness: searchController["fuzziness"],
        searchOperators: searchController["searchOperators"],
        highlight: searchController["highlight"],
        highlightField: searchController["highlightField"],
        customHighlight: searchController["customHighlight"],
        interval: searchController["interval"],
        aggregations: searchController["aggregations"],
        missingLabel: searchController["missingLabel"],
        showMissing: searchController["showMissing"],
        enableSynonyms: searchController["enableSynonyms"],
        selectAllLabel: searchController["selectAllLabel"],
        pagination: searchController["pagination"],
        queryString: searchController["queryString"],
        defaultQuery: searchController["defaultQuery"],
        customQuery: searchController["customQuery"],
        beforeValueChange: searchController["beforeValueChange"],
        onValueChange: searchController["onValueChange"],
        onResults: searchController["onResults"],
        onAggregationData: searchController["onAggregationData"],
        onError: searchController["onError"],
        onRequestStatusChange: searchController["onRequestStatusChange"],
        onQueryChange: searchController["onQueryChange"],
        enablePopularSuggestions: searchController["enablePopularSuggestions"],
        maxPopularSuggestions: searchController["maxPopularSuggestions"],
        showDistinctSuggestions: searchController["showDistinctSuggestions"],
        preserveResults: searchController["preserveResults"],
        clearOnQueryChange: searchController["clearOnQueryChange"],
        value: searchController["value"],
        distinctField: searchController["distinctField"],
        distinctFieldConfig: searchController["distinctFieldConfig"],
        httpRequestTimeout: searchController["httpRequestTimeout"],
        compoundClause: searchController["compoundClause"],
      );
    } else if (searchController is SearchController) {
      componentInstance = searchController;
      // set the id property on instance
      componentInstance.id = widgetId;
    }
    // register component
    this._searchWidgets[widgetId] = componentInstance!;
    // set the search base instance as parent
    componentInstance.setParent(this);
    return componentInstance;
  }

  /// This method is useful to unregister a [SearchController] by `id`.
  ///
  /// It is a good practice to unregister (remove) an unmounted/unused widget to avoid any side-effects.
  void unregister(String widgetId) {
    if (widgetId != '') {
      this._searchWidgets.remove(widgetId);
    }
  }

  /// This method can be used to retrieve the instance of the [SearchController] class for a particular widget by `id`.
  SearchController? getSearchWidget(String widgetId) {
    return this._searchWidgets[widgetId];
  }

  /// This method returns all the active widgets registered on the `SearchBase` instance.
  ///
  /// The widgets state can be used for various purposes, for example, to display the selected filters in the UI.
  Map<String, SearchController> getActiveWidgets() {
    return this._searchWidgets;
  }

  void lock() {
    _lock = true;
  }

  void unlock() {
    _lock = false;
  }

  bool shouldAddRequestToWaitList(
    String controllerId,
    bool addToStack,
    List<Map>? query,
  ) {
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var shouldWait =
        currentTime - this._initialTimeStamp < this.initialQueriesSyncTime;
    if (addToStack && shouldWait) {
      // Add future delay to execute request stack
      if (!this.isLocked()) {
        List<String> executableControllers = [];
        Future.delayed(Duration(milliseconds: this.initialQueriesSyncTime), () {
          Map<String, Map<String, dynamic>> requestsToIdMap = {};
          this._requestStack.forEach((request) {
            var controllerId = request["id"] as String;
            if (requestsToIdMap[controllerId] != null) {
              requestsToIdMap[controllerId] = Map<String, dynamic>.from(request);
            } else {
              var shouldExecute = request["execute"] != null
                  ? request["execute"] as bool
                  : false;
              // check if `execute` was set to `true` in older requests
              if (shouldExecute) {
                request["execute"] = true;
              }
              requestsToIdMap[controllerId] = Map<String, dynamic>.from(request);
            }
          });
          requestsToIdMap.values.forEach((request) {
            var controllerId = request["id"] as String;
            var shouldExecute =
                request["execute"] != null ? request["execute"] as bool : null;
            // check if `execute` was set to `true` in older requests
            if (shouldExecute != null) {
              if (shouldExecute) {
                executableControllers.add(controllerId);
              }
            } else {
              executableControllers.add(controllerId);
            }
          });
          executableControllers.forEach((id) {
            final componentInstance = this.getSearchWidget(id);
            if (componentInstance != null) {
              // set request status to pending
              componentInstance.setRequestStatus(RequestStatus.PENDING,
                  options: Option());
              // Update the query
              componentInstance.updateQuery();
            }
          });
          List<Map<String, dynamic>> query = [];
          requestsToIdMap.values.forEach((element) {
            query.add(element);
          });
          // Execute combined queries in a single request
          this._fetchRequest({
            'query': query,
            'settings': this.appbaseConfig?.toJSON()
          }).then((results) {
            requestsToIdMap.keys.forEach((id) {
              final componentInstance = this.getSearchWidget(id);
              if (componentInstance != null) {
                componentInstance.setRequestStatus(RequestStatus.INACTIVE,
                    options: Option());

                // Update the results
                final prev = componentInstance.results.clone();
                // Collect results from the response for a particular component
                Map<String, dynamic> rawResults =
                    results[id] != null ? results[id] : {};
                // Set results
                if (rawResults['hits'] != null) {
                  componentInstance.results.setRaw(rawResults);
                  componentInstance.applyOptions(Options(),
                      KeysToSubscribe.Results, prev, componentInstance.results);
                }

                if (rawResults['aggregations'] != null) {
                  componentInstance.handleAggregationResponse(
                      rawResults['aggregations'],
                      options: Options(),
                      append: false);
                }
              }
            });
          }).catchError((error) {
            executableControllers.forEach((id) {
              final componentInstance = this.getSearchWidget(id);
              if (componentInstance != null) {
                componentInstance.setRequestStatus(RequestStatus.INACTIVE,
                    options: Option());

                componentInstance.setError(error);
              }
            });
          });
          this._requestStack.clear();
          this.unlock();
        });
      }
      // Lock request execution
      this.lock();
      // Add component Id to request stack
      query?.forEach((q) {
        this._requestStack.add(q);
      });
    }
    return shouldWait;
  }

  bool isLocked() {
    return _lock;
  }

  Future<Map<String, dynamic>> _handleTransformResponse(
      Map<String, dynamic>? res) {
    if (this.transformResponse != null) {
      return this.transformResponse!(res) as Future<Map<String, dynamic>>;
    }
    return Future.value(res);
  }

  Future<Map> _handleTransformRequest(Map requestOptions) async {
    if (this.transformRequest != null) {
      return await this.transformRequest!(requestOptions)
          as Future<Map<dynamic, dynamic>>;
    }
    return Future<Map>.value(requestOptions);
  }

  Future<Map> _fetchRequest(Map requestBody) async {
    // remove undefined properties from request body
    final requestOptions = {
      'body': jsonEncode(requestBody),
      'headers': {...?this.headers}
    };
    try {
      final finalRequestOptions =
          await this._handleTransformRequest(requestOptions);
      // set timestamp in request
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String suffix = '_reactivesearch';
      final String url = "${this.url}/${this.index}/$suffix";
      final http.Response res = await http.post(
        Uri.parse(url),
        headers: finalRequestOptions['headers'],
        body: finalRequestOptions['body'],
      );
      final responseHeaders = res.headers;
      // check if search component is present
      final queryID = responseHeaders['x-search-id'];
      if (queryID != null && queryID != '') {
        this.setQueryID(queryID);
      }
      if (res.statusCode >= 500) {
        return Future.error(res);
      }
      if (res.statusCode >= 400) {
        final data = jsonDecode(res.body);
        return Future.error(data);
      }
      final data = jsonDecode(res.body);
      final transformedData = await this._handleTransformResponse(data);
      if (transformedData.containsKey('error')) {
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

  // To set values for controllers and trigger a final query, it accepts a map of controller Id to controller value
  void setSearchState(Map<String, dynamic> value) {
    value.keys.forEach((id) {
      SearchController? controller = getSearchWidget(id);
      dynamic valueToBeSet = value[id];

      if (controller != null) {
        if (valueToBeSet is List && valueToBeSet.isNotEmpty) {
          Type elementType = valueToBeSet[0].runtimeType;

          switch (elementType) {
            case bool:
              valueToBeSet = valueToBeSet.map((v) => v as bool).toList();
              break;
            case int:
              valueToBeSet = valueToBeSet.map((v) => v as int).toList();
              break;
            case double:
              valueToBeSet = valueToBeSet.map((v) => v as double).toList();
              break;
            case num:
              valueToBeSet = valueToBeSet.map((v) => v as num).toList();
              break;
            case String:
              valueToBeSet = valueToBeSet.map((v) => v as String).toList();
              break;
            default:
              valueToBeSet = valueToBeSet.map((v) => v as dynamic).toList();
          }
          // First set the value for all the controllers
          controller.setValueSilent(
            valueToBeSet,
            options: Options(
              stateChanges: true,
              triggerCustomQuery: false,
              triggerDefaultQuery: false,
            ),
          );
        } else {
          // First set the value for all the controllers
          controller.setValueSilent(
            valueToBeSet,
            options: Options(
              stateChanges: true,
              triggerCustomQuery: false,
              triggerDefaultQuery: false,
            ),
          );
        }
      } else {
        // Handle the case when controller is null for a particular id
        // For example, you can log an error or take appropriate action
        print('Warning: SearchController is null for id $id');
      }
    });

    // Trigger custom queries for all the affected components
    value.keys.forEach((id) {
      SearchController? controller = getSearchWidget(id);
      // Add component Id to request stack
      final generatedQuery = controller?.generateQuery();
      if (generatedQuery?.requestBody.isNotEmpty == true) {
        generatedQuery?.orderOfQueries.forEach((id) {
          final componentInstance = this.getSearchWidget(id);
          if (componentInstance != null) {
            // Reset `from` and `after` values
            componentInstance.setFrom(
              0,
              options: Options(
                triggerDefaultQuery: false,
                triggerCustomQuery: false,
                stateChanges: true,
              ),
            );
            componentInstance.setAfter(
              null,
              options: Options(
                triggerDefaultQuery: false,
                triggerCustomQuery: false,
                stateChanges: true,
              ),
            );
            // Update the query
            componentInstance.updateQuery();
          }
        });
        final finalGeneratedQuery = controller?.generateQuery();
        finalGeneratedQuery?.requestBody.forEach((q) {
          this._requestStack.add(q);
        });
      }
    });

    // execute request
    List<String> executableControllers = [];
    Map<String, Map<String, dynamic>> requestsToIdMap = {};
    this._requestStack.forEach((request) {
      var controllerId = request["id"] as String;
      if (requestsToIdMap[controllerId] != null) {
        requestsToIdMap[controllerId] = Map<String, dynamic>.from(request);
      } else {
        var shouldExecute =
            request["execute"] != null ? request["execute"] as bool : false;
        // check if `execute` was set to `true` in older requests
        if (shouldExecute) {
          request["execute"] = true;
        }
        requestsToIdMap[controllerId] = Map<String, dynamic>.from(request);
      }
    });
    requestsToIdMap.values.forEach((request) {
      var controllerId = request["id"] as String;
      var shouldExecute =
          request["execute"] != null ? request["execute"] as bool : null;
      // check if `execute` was set to `true` in older requests
      if (shouldExecute != null) {
        if (shouldExecute) {
          executableControllers.add(controllerId);
        }
      } else {
        executableControllers.add(controllerId);
      }
    });
    executableControllers.forEach((id) {
      final componentInstance = this.getSearchWidget(id);
      if (componentInstance != null) {
        // set request status to pending
        componentInstance.setRequestStatus(
          RequestStatus.PENDING,
          options: Option(),
        );
        // Update the query
        componentInstance.updateQuery();
      }
    });
    List<Map<String, dynamic>> query = [];
    requestsToIdMap.values.forEach((element) {
      query.add(element);
    });
    // Execute combined queries in a single request
    this._fetchRequest({
      'query': query,
      'settings': this.appbaseConfig?.toJSON(),
    }).then((results) {
      requestsToIdMap.keys.forEach((id) {
        final componentInstance = this.getSearchWidget(id);
        if (componentInstance != null) {
          componentInstance.setRequestStatus(
            RequestStatus.INACTIVE,
            options: Option(),
          );

          // Update the results
          final prev = componentInstance.results.clone();
          // Collect results from the response for a particular component
          Map<String, dynamic> rawResults =
              results[id] != null ? results[id] as Map<String, dynamic> : {};
          // Set results
          if (rawResults['hits'] != null) {
            componentInstance.results.setRaw(rawResults);
            componentInstance.applyOptions(
              Options(),
              KeysToSubscribe.Results,
              prev,
              componentInstance.results,
            );
          }

          if (rawResults['aggregations'] != null) {
            componentInstance.handleAggregationResponse(
              rawResults['aggregations'],
              options: Options(),
              append: false,
            );
          }
        }
      });
    }).catchError((error) {
      executableControllers.forEach((id) {
        final componentInstance = this.getSearchWidget(id);
        if (componentInstance != null) {
          componentInstance.setRequestStatus(
            RequestStatus.INACTIVE,
            options: Option(),
          );

          componentInstance.setError(error);
        }
      });
    });
    this._requestStack.clear();
    this.unlock();
  }
}
