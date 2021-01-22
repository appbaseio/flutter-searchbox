import 'types.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// [Base] class is the abstract class for [SearchBase] and [SearchController] classes.
class Base {
  // RS API properties

  /// Refers to an index of the Elasticsearch cluster.
  ///
  /// `Note:` Multiple indexes can be connected to Elasticsearch by specifying comma-separated index names.
  String index;

  /// URL for the Elasticsearch cluster.
  String url;

  /// Basic Auth credentials if required for authentication purposes.
  ///
  /// It should be a string of the format `username:password`. If you are using an appbase.io cluster, you will find credentials under the `Security > API credentials` section of the appbase.io dashboard.
  /// If you are not using an appbase.io cluster, credentials may not be necessary - although having open access to your Elasticsearch cluster is not recommended.
  String credentials;

  /// Set custom headers to be sent with each server request as key/value pairs.
  Map<String, String> headers;

  /// It allows you to customize the analytics experience when appbase.io is used as a backend.
  AppbaseSettings appbaseConfig;

  /* ---- callbacks to create the side effects while querying ----- */

  /// Enables transformation of network request before execution.
  ///
  /// This function will give you the request object as the param and expect an updated request in return, for execution.
  /// For example, we will add the `credentials` property in the request using `transformRequest`.
  ///
  /// ```dart
  /// Future (Map request) =>
  ///      Future.value({
  ///          ...request,
  ///          'credentials': 'include',
  ///      })
  ///  }
  /// ```
  TransformRequest transformRequest;

  /// Enables transformation of search network response before rendering them.
  ///
  /// It is an asynchronous function which will accept an Elasticsearch response object as param and is expected to return an updated response as the return value.
  /// For example:
  /// ```dart
  /// Future (Map elasticsearchResponse) async {
  ///	 final ids = elasticsearchResponse['hits']['hits'].map(item => item._id);
  ///	 final extraInformation = await getExtraInformation(ids);
  ///	 final hits = elasticsearchResponse['hits']['hits'].map(item => {
  ///		final extraInformationItem = extraInformation.find(
  ///			otherItem => otherItem._id === item._id,
  ///		);
  ///		return Future.value({
  ///			...item,
  ///			...extraInformationItem,
  ///		};
  ///	}));
  ///
  ///	return Future.value({
  ///		...elasticsearchResponse,
  ///		'hits': {
  ///			...elasticsearchResponse.hits,
  ///			hits,
  ///		},
  ///	});
  ///}
  /// ```
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

  /// To to set the custom headers
  void setHeaders(Map<String, String> headers) {
    this.headers = {...this.headers, ...headers};
  }

  /// To set the query ID
  void setQueryID(String queryID) {
    this._queryId = queryID;
  }

  /// To get the query ID
  String get queryId {
    return this._queryId;
  }

  /// use this methods to record a search click event
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

  /// use this methods to record a search conversion
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
