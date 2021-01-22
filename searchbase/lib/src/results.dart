import 'utils.dart';

/// Represents the response for [QueryType.search], [QueryType.geo] and [QueryType.range] type of [SearchController](s).
class Results {
  /// An array of results obtained from the applied query.
  List<Map<String, dynamic>> data;

  /// Raw response returned by ES query
  Map raw;

  /// To parse the results.
  List<Map<String, dynamic>> Function(List<Map> results, [List<Map> sourceData])
      parseResults;

  Results(this.data) {}

  /// Total number of results found.
  int get numberOfResults {
    // calculate from raw response
    if (this.raw != null && this.raw.containsKey('hits')) {
      if (this.raw != null &&
          this.raw['hits'] != null &&
          this.raw['hits']['total'] != null) {
        if (this.raw['hits']['total'] is Map) {
          return this.raw['hits']['total']['value'];
        }
        if (this.raw['hits']['total'] is int) {
          return this.raw['hits']['total'];
        }
      }
    }
    return 0;
  }

  /// Total time taken by request (in ms).
  int get time {
    // calculate from raw response
    if (this.raw != null) {
      return this.raw['took'];
    }
    return 0;
  }

  /// Number of hidden results found.
  int get hidden {
    if (this.raw != null &&
        this.raw['hits'] != null &&
        this.raw['hits']['hidden'] is int) {
      return this.raw['hits']['hidden'];
    }
    return 0;
  }

  /// An array of promoted results obtained from the applied query.
  List<Map> get promotedData {
    if (this.raw != null && this.raw['promoted'] is List<Map>) {
      return this.raw['promoted'];
    }
    return [];
  }

  /// Number of promoted results found.
  int get promoted {
    return this.promotedData.length;
  }

  // An object of raw response as-is from elasticsearch query.
  Map get rawData {
    return this.raw;
  }

  // An object of custom data applied through Appbase query rules.
  Map get customData {
    if (this.raw != null && this.raw['customData'] == Map) {
      return this.raw['customData'];
    }
    return {};
  }

  /// Method to set the raw response form Elasticsearch
  void setRaw(Map rawResponse) {
    // set response
    if (rawResponse != null) {
      this.raw = rawResponse;
      if (this.raw['hits'] != null && this.raw['hits']['hits'] is List) {
        final mapped = (this.raw['hits']['hits'] as List)
            .map((model) => Map<String, dynamic>.from(model));
        data = mapped.toList();
        this.setData(data);
      }
    }
  }

  // Method to set data explicitly.
  void setData(List<Map<String, dynamic>> data) {
    // parse hits
    List<Map<String, dynamic>> filteredResults = parseHits(data);
    // filter results & remove duplicates if any
    if (this.promotedData.length != 0) {
      final List<String> ids = this.promotedData.map((item) => item["_id"]);
      if (ids.length != 0) {
        filteredResults.where((item) {
          // remove duplicate results
          if (item["_id"] != null && ids.indexOf(item["_id"]) != -1) {
            return false;
          }
          return true;
        });
      }

      filteredResults = [
        ...this
            .promotedData
            .map((dataItem) => ({...dataItem, "_promoted": true})),
        ...filteredResults
      ];
    }

    // set data
    if (this.parseResults != null) {
      this.data = this.parseResults(filteredResults, data);
    } else {
      this.data = filteredResults;
    }
    // Add click ids in data
    this.data = withClickIds(this.data);
  }
}
