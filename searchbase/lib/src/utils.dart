import 'package:collection/collection.dart';
import 'package:searchbase/searchbase.dart';

const popularSuggestionFields = ['key', 'key.autosuggest'];

List<Map<String, dynamic>> withClickIds(List<Map<String, dynamic>> results) {
  int index = 0;
  return results.map((result) => {...result, "_click_id": ++index}).toList();
}

List<Suggestion> withSuggestionClickIds(List<Suggestion> suggestions) {
  int index = 0;
  return suggestions
      .map((suggestion) => Suggestion(suggestion.label, suggestion.value,
          source: suggestion.source, clickId: index++))
      .toList();
}

Map highlightResults(Map result) {
  final data = {...result};
  if (data["highlight"] is Map) {
    data["highlight"].forEach((highlightItem, value) {
      if (value is List) {
        final highlightValue = value[0];
        data["_source"] = {
          ...data["_source"],
          [highlightItem]: highlightValue
        };
      }
    });
  }
  return data;
}

List<Map<String, dynamic>> parseHits(List<Map<String, dynamic>> hits) {
  List<Map<String, dynamic>> results = [];
  results = [...hits].map((item) {
    final data = highlightResults(item);
    Map<String, dynamic> result = {};
    if (data['_source'] is Map<String, dynamic>) {
      result = {...data['_source']};
    }
    // Copy the other properties
    (Map.from(data)..removeWhere((k, v) => k == '_source'))
        .forEach((key, value) {
      result[key] = value;
    });
    return result;
  }).toList();
  return results;
}

// string | Array<string | DataField>
List<String> getNormalizedField(dynamic field) {
  if (field != null) {
    // if data field is string
    if (field is String) {
      return [field];
    }
    if (field.length != 0) {
      List<String> fields = [];
      field.forEach((dataField) {
        if (dataField is String) {
          fields.add(dataField);
        } else if (dataField is Map && dataField['field'] is String) {
          // if data field is an array of objects
          fields.add(dataField['field']);
        }
      });
      return fields;
    }
  }
  return [];
}

List<int> getNormalizedWeights(dynamic field) {
  if (field is List<Map>) {
    List<int> weights = [];
    field.forEach((dataField) {
      if (dataField['weight'] is int) {
        // if data field is an array of objects
        weights.add(dataField['weight']);
      } else {
        // Add default weight as 1 to maintain order
        weights.add(1);
      }
    });
    return weights;
  }
  return [];
}

List<String> flatReactProp(Map? reactProp, String componentID) {
  List<String> flattenReact = [];
  flatReact(Map? react) {
    if (react != null && react.values.length != 0) {
      react.values.forEach((reactValue) {
        if (reactValue is String) {
          flattenReact = [...flattenReact, reactValue];
        } else if (reactValue is List<String>) {
          flattenReact = [...flattenReact, ...reactValue];
        } else if (reactValue is Map) {
          flatReact(reactValue);
        }
      });
    }
  }

  flatReact(reactProp);
  // Remove cyclic dependencies i.e dependencies on it's own
  flattenReact = flattenReact.where((react) => react != componentID).toList();
  return flattenReact;
}

// flattens a nested array
List flatten(List arr) => arr.fold(
    [],
    (value, element) => [
          ...value,
          ...(element is List ? flatten(element) : [element])
        ]);

// helper function to extract suggestions
dynamic extractSuggestion(dynamic val) {
  if (val is Map) {
    return null;
  }
  if (val is List) {
    return flatten(val);
  }
  return val;
}

/**
 *
 * @param {array} fields DataFields passed on Search Components
 * @param {array} suggestions Raw Suggestions received from ES
 * @param {string} currentValue Search Term
 * @param {boolean} showDistinctSuggestions When set to true will only return 1 suggestion per document
 */
List<Suggestion> getSuggestions(
    List<String?> fields, List<Map> suggestions, String? value,
    [bool? showDistinctSuggestions = true]) {
  List<Suggestion> suggestionsList = [];
  List<String> labelsList = [];
  bool skipWordMatch =
      false; //  Use to skip the word match logic, important for synonym
  final String? currentValue = value;
  bool populateSuggestionsList(val, Map parsedSource, Map? source) {
    // check if the suggestion includes the current value
    // and not already included in other suggestions
    final bool isWordMatch = skipWordMatch
        ? skipWordMatch
        : val is String
            ? currentValue!
                .trim()
                .split(' ')
                .any((term) => val.toLowerCase().contains(term))
            : false;
    // promoted results should always include in suggestions even there is no match
    if (val is String &&
        ((isWordMatch && !labelsList.contains(val)) ||
            source!['_promoted'] == true)) {
      labelsList = [...labelsList, val];
      suggestionsList = [
        ...suggestionsList,
        Suggestion(val, val, source: source)
      ];
      if (showDistinctSuggestions == true) {
        return true;
      }
    }
    return false;
  }

  parseField(dynamic parsedSource, String? field, {Map? source}) {
    if (source == null) {
      source = parsedSource;
    }
    if (parsedSource is Map) {
      final List<String> fieldNodes = field!.split('.');
      final label = parsedSource[fieldNodes[0]];
      if (label != null) {
        if (fieldNodes.length > 1) {
          // nested fields of the 'foo.bar.zoo' variety
          final children = field.substring(fieldNodes[0].length + 1);
          if (label is List<Map>) {
            label.forEach((arrayItem) {
              parseField(arrayItem, children, source: source);
            });
          } else {
            parseField(label, children, source: source);
          }
        } else {
          final val = extractSuggestion(label);
          if (val != null) {
            if (val is List) {
              if (showDistinctSuggestions == true) {
                return val.any((suggestion) =>
                    populateSuggestionsList(suggestion, parsedSource, source));
              }
              val.forEach((suggestion) =>
                  populateSuggestionsList(suggestion, parsedSource, source));
            }
            return populateSuggestionsList(val, parsedSource, source);
          }
        }
      }
    }
    return false;
  }

  void traverseSuggestions() {
    if (showDistinctSuggestions == true) {
      suggestions
          .forEach((item) => fields.any((field) => parseField(item, field)));
    } else {
      suggestions.forEach((item) => fields.forEach((field) {
            parseField(item, field);
          }));
    }
  }

  traverseSuggestions();

  if (suggestionsList.length < suggestions.length && !skipWordMatch) {
    /*
			When we have synonym we set skipWordMatch to false as it may discard
			the suggestion if word doesnt match term.
			For eg: iphone, ios are synonyms and on searching iphone isWordMatch
			in  populateSuggestionList may discard ios source which decreases no.
			of items in suggestionsList
		*/
    skipWordMatch = true;
    traverseSuggestions();
  }

  return withSuggestionClickIds(suggestionsList);
}

List<Map> parseCompAggToHits(String? aggFieldName, List<Map> buckets) {
  return buckets.map((Map bucket) {
    return {
      '_doc_count': bucket['doc_count'],
      // To handle the aggregation results for term and composite aggs
      '_key':
          bucket['key'] is Map ? bucket['key'][aggFieldName] : bucket['key'],
      ...(bucket[aggFieldName] != null ? bucket[aggFieldName] : {})
    };
  }).toList();
}

bool isEqual(dynamic x, dynamic y) {
  Function deepEq = const DeepCollectionEquality().equals;
  return deepEq(x, y);
}
