import 'types.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/**
 * Base class is the abstract class for SearchBase and SearchWidget classes.
 */
class Base {
  // to enable the recording of analytics
  AppbaseSettings appbaseConfig;

  // auth credentials if any
  String credentials;

  // custom headers object
  Map<String, String> headers;

  // es index name
  String index;

  // es url
  String url;

  /* ---- callbacks to create the side effects while querying ----- */

  TransformRequest transformRequest;

  TransformResponse transformResponse;

  /* ------ Private properties only for the internal use ----------- */

  // query search ID
  String _queryId;

  Base(String index, String url, String credentials,
      {AppbaseSettings this.appbaseConfig,
      TransformRequest this.transformRequest,
      TransformResponse this.transformResponse,
      Map<String, String> headers}) {
    if (index == null || index == "") {
      throw (ErrorMessages[InvalidIndex]);
    }
    if (url == null || url == "") {
      throw (ErrorMessages[InvalidURL]);
    }
    if (credentials == null || credentials == "") {
      throw (ErrorMessages[InvalidCredentials]);
    }
    this.index = index;
    this.url = url;
    this.credentials = credentials;
    var bytes = utf8.encode(credentials);
    var base64Str = base64.encode(bytes);
    // Initialize headers
    this.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Basic ${base64Str}'
    };
    if (headers != null) {
      this.setHeaders(headers);
    }
  }

  // To to set the custom headers
  void setHeaders(Map<String, String> headers) {
    this.headers = {...this.headers, ...headers};
  }

  // To set the query ID
  void setQueryID(String queryID) {
    this._queryId = queryID;
  }

  // To get the query ID
  String get queryId {
    return this._queryId;
  }

  // use this methods to record a search click event
  Future click(Map<String, int> objects,
      {bool isSuggestionClick = false, String queryId}) async {
    String queryID = queryId;
    if (queryId == null || queryId == "") {
      queryID = this.queryId;
    }
    if (this.appbaseConfig != null &&
        this.appbaseConfig.recordAnalytics == true &&
        queryID != null &&
        queryID != "") {
      try {
        final Map requestBody = {
          'click_on': objects,
          'click_type': isSuggestionClick ? 'suggestion' : 'result',
          'query_id': queryID,
        };
        final String url = "${this.url}/${this..index}/_analytics/click";
        final res = await http.put(
          url,
          headers: this.headers,
          body: jsonEncode(requestBody),
        );
        return Future.value(res);
      } catch (e) {
        return Future.error(e);
      }
    }
    return Future.error("Query ID not found. Make sure analytics is enabled");
  }

  // use this methods to record a search conversion
  Future conversion(List<String> objects, {String queryId}) async {
    String queryID = queryId;
    if (queryId == null || queryId == "") {
      queryID = this.queryId;
    }
    if (this.appbaseConfig != null &&
        this.appbaseConfig.recordAnalytics == true &&
        queryID != null &&
        queryID != "") {
      try {
        final Map requestBody = {
          'conversion_on': objects,
          'query_id': queryID,
        };
        final String url = "${this.url}/${this..index}/_analytics/conversion";
        final res = await http.put(
          url,
          headers: this.headers,
          body: jsonEncode(requestBody),
        );
        return Future.value(res);
      } catch (e) {
        return Future.error(e);
      }
    }
    return Future.error("Query ID not found. Make sure analytics is enabled");
  }
}
