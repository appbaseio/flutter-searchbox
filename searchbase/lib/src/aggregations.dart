import 'utils.dart';

/// Represents the elasticsearch aggregations response for [QueryType.term] type of [SearchController](s).
class Aggregations {
  /// An array of composite aggregations obtained from the applied aggs in options.
  List<Map>? data;

  /// If the number of composite buckets is too high (or unknown) to be returned in a single response use the `afterKey` parameter to retrieve the next results.
  ///
  /// This property will only be present for `composite` aggregations.
  Map? afterKey;

  /// Raw aggregations returned by ES query.
  Map? raw;

  Aggregations({this.data});

  /// An object of raw response as-is from elasticsearch query.
  Map? get rawData {
    return this.raw;
  }

  /// To set the raw response from elasticsearch.
  void setRaw(Map? rawResponse) {
    // set response
    this.raw = rawResponse;
    if (rawResponse != null &&
        rawResponse['after_key'] != null &&
        rawResponse['after_key'] is Map) {
      this.setAfterKey(rawResponse['after_key']);
    }
  }

  /// To set the after value to implement pagination for composite aggregations.
  void setAfterKey(Map? key) {
    this.afterKey = key;
  }

  /// Method to set data explicitly.
  void setData(String? aggField, List<Map> data, {bool append = false}) {
    // parse aggregation buckets
    List<Map> parsedData = parseCompAggToHits(aggField, data);
    if (append == true) {
      this.data?.addAll(parsedData);
    } else {
      this.data = parsedData;
    }
  }
}
