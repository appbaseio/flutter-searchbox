typedef TransformRequest = Future<Object> Function(Map requestOptions);
typedef TransformResponse = Future Function(dynamic response);
typedef SubscriptionFunction = Function(Map<String, Changes> change);

class Changes {
  final dynamic prev;
  final dynamic next;
  Changes(this.prev, this.next);
}

class AppbaseSettings {
  bool recordAnalytics;
  bool enableQueryRules;
  String userId;
  Map<String, String> customEvents;

  AppbaseSettings({
    bool this.recordAnalytics,
    bool this.enableQueryRules,
    String this.userId,
    Map<String, String> this.customEvents,
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

class RecentSearchOptions {
  int size;
  int minChars;
  String from;
  String to;
  Map<String, String> customEvents;
  RecentSearchOptions(
      {this.size = 5,
      this.minChars = 3,
      this.from,
      this.to,
      this.customEvents});
}

class Options {
  bool triggerDefaultQuery;
  bool triggerCustomQuery;
  bool stateChanges;
  Options(
      {this.triggerDefaultQuery, bool triggerCustomQuery, bool stateChanges}) {
    this.triggerDefaultQuery =
        triggerDefaultQuery != null ? triggerDefaultQuery : false;
    this.triggerCustomQuery =
        triggerCustomQuery != null ? triggerCustomQuery : false;
    this.stateChanges = stateChanges != null ? stateChanges : true;
  }
}

class Option {
  bool stateChanges;
  Option({stateChanges}) {
    this.stateChanges = stateChanges != null ? stateChanges : true;
  }
}

class GenerateQueryResponse {
  List<Map> requestBody;
  List<String> orderOfQueries;
  GenerateQueryResponse(this.requestBody, this.orderOfQueries) {}
}

class Suggestion {
  String label;
  String value;
  Map source;
  int clickId;
  Suggestion(this.label, this.value, {this.source, this.clickId}) {}
}
