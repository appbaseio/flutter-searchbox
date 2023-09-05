const String InvalidIndex = 'invalidIndex';
const String InvalidURL = 'invalidURL';
const String InvalidComponentId = 'invalidComponentId';
const String InvalidDataField = 'invalidDataField';
const String DataFieldAsArray = 'dataFieldAsArray';
const String InvalidCredentials = 'invalidCredentials';

const Map ErrorMessages = {
  InvalidIndex: 'SearchBase: Please provide a valid index.',
  InvalidURL: 'SearchBase: Please provide a valid url.',
  InvalidCredentials: 'SearchBase: Please provide valid credentials.',
  InvalidComponentId: 'SearchBase: Please provide component id.',
  InvalidDataField: 'SearchBase: Please provide data field.',
  DataFieldAsArray:
      'SearchBase: Only components with `search` type supports the multiple data fields. Please define `dataField` as a string.'
};

/// Represents the current status of the elasticsearch request
enum RequestStatus {
  INACTIVE,
  PENDING,
  ERROR,
}

/// Represents the type of the query which is defaults to [QueryType.search], valid values are `search`, `term`, `range` & `geo`. You can read more [here](https://docs.appbase.io/docs/search/reactivesearch-api/implement#type-of-queries).
enum QueryType { search, term, geo, range }

extension QueryTypeExtension on QueryType? {
  String? get value {
    switch (this) {
      case QueryType.search:
        return 'search';
      case QueryType.term:
        return 'term';
      case QueryType.geo:
        return 'geo';
      case QueryType.range:
        return 'range';
      default:
        return null;
    }
  }
}

enum SortType {
  asc,
  desc,
  count,
}

extension SortTypeExtension on SortType? {
  String? get value {
    switch (this) {
      case SortType.asc:
        return 'asc';
      case SortType.desc:
        return 'desc';
      case SortType.count:
        return 'count';
      default:
        return null;
    }
  }
}

enum CompoundClauseType { filter, must }
