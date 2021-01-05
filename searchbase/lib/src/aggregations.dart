import 'utils.dart';

class Aggregations {
  // An array of composite aggregations obtained from the applied aggs in options.
  List<Map> data;

  // useful when loading data of greater size
  Map afterKey;

  // Raw aggregations returned by ES query
  Map raw;

  Aggregations({this.data}) {}

  // An object of raw response as-is from elasticsearch query
  Map get rawData {
    return this.raw;
  }

  void setRaw(Map rawResponse) {
    // set response
    this.raw = rawResponse;
    if (rawResponse != null &&
        rawResponse['after_key'] != null &&
        rawResponse['after_key'] is Map) {
      this.setAfterKey(rawResponse['after_key']);
    }
  }

  void setAfterKey(Map key) {
    this.afterKey = key;
  }

  // Method to set data explicitly
  void setData(String aggField, List<Map> data) {
    // parse aggregation buckets
    this.data = parseCompAggToHits(aggField, data);
  }
}
