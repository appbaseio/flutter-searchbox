typedef TransformRequest = Future<Object> Function(Map requestOptions);
typedef TransformResponse = Future Function(dynamic response);
typedef SubscriptionFunction = Function(Map<String, Changes> change);

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
  Options(
      {this.triggerDefaultQuery,
      bool? triggerCustomQuery,
      bool? stateChanges}) {
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
  Results,
  AggregationData,
  RequestStatus,
  Error,
  Value,
  Query,
  DataField,
  Size,
  From,
  Fuzziness,
  IncludeFields,
  ExcludeFields,
  SortBy,
  React,
  DefaultQuery,
  CustomQuery,
  RequestPending,
  RecentSearches
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
      case KeysToSubscribe.CustomQuery:
        return 'customQuery';    
      case KeysToSubscribe.RequestPending:
        return 'requestPending';    
      case KeysToSubscribe.RecentSearches:
        return 'recentSearches';                                                                                                           
      default:
        return "";
    }
  }
}