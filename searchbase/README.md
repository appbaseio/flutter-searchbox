## SearchBase

[searchbase](https://github.com/appbaseio/flutter-searchbox/tree/master/searchbase) is a lightweight and platform agnostic library that provides scaffolding to create search experiences powered by Elasticsearch.

## Example

### A simple example

The following example creates a single widget of type(`search`) to render the results based on the input value.

```dart
import 'dart:html';
import 'package:searchbase/searchbase.dart';

void main() {
  final index = 'gitxplore-app';
  final url = 'https://@appbase-demo-ansible-abxiydt-arc.searchbase.io';
  final credentials = 'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61';
  // Instantiate the [SearchController]
  final searchController = SearchController(
      // Elasticsearch index name
      index,
      // Appbase URL
      url,
      // Appbase credentials
      credentials,
      // Unique identifier for search widget
      'search-widget',
      // Database fields to perform the search
      dataField: ['name', 'description', 'name.search', 'fullname', 'owner', 'topics'],
      // initial value
      value: ''
  );

  // Get the input element
  final searchElement = querySelector('#search');

  // Bind the searchController value to input value
  searchElement.value = searchController.value;

  // Update the search input value to searchController to fetch the results
  searchElement.addEventListener('input', (e) {
	// To fetch the suggestions based on the value changes
	searchController.setValue(e.target.value,
        options: Options(triggerDefaultQuery: true));
  });

  // Build DOM when search results update
  searchController.subscribeToStateChanges((change) {
		final results = change.Results!.next;
		final resultsElement = querySelector('#results');
		resultsElement.innerHTML = '';
		results.data.forEach((element) {
			var node = document.createElement('li'); // Create a <li> node
			var resultNode = document.createTextNode(element.name); // Create a text node
			node.append(resultNode); // Append the text to <li>
			resultsElement.append(node);
		});
	},
	[KeysToSubscribe.Results],
 );

 // Fetch the default results at initial load
 searchController.triggerDefaultQuery();
}
```

Add this in your HTML

```html
<input placeholder="type to search" id="search" />

<div id="results"></div>
```

### An example with a facet

The following example creates three widgets:

- a search widget to perform the search,
- a filter widget to filter the GitHub repo by languages,
- a result widget to render the results based on the selected language filters and search query

The result widget watches for changes to the search and language filter widgets (see the `react` property). It reacts to the inputs and filter selection changes by triggering an `Elasticsearch` query to update results.

The language filter widget is also watching for changes to the search. For example, if somebody searches for `angular` then the language filter will show `javascript` as an option.

> Note: This example is using the `SearchBase` class instead of the `SearchController`(that we used in the previous example) class because here we're using multiple widgets that can have dependencies on each other.

```dart
import 'dart:html';
import 'package:searchbase/searchbase.dart';

void main() {
  final index = 'gitxplore-app';
  final url = 'https://@appbase-demo-ansible-abxiydt-arc.searchbase.io';
  final credentials = 'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61';

  final searchbase = SearchBase(index, url, credentials,
      appbaseConfig: AppbaseSettings(recordAnalytics: true));
  // Register search widget => To render the suggestions
  final searchController = searchbase.register('search-widget', {
    'enablePopularSuggestions': true,
    'dataField': [
      'name',
      'description',
      'name.raw',
      'fullname',
      'owner',
      'topics'
    ]
  });

// Register filter widget with dependency on search widget
  final filterWidget = searchbase.register('language-filter', {
    'type': QueryType.term,
    'dataField': 'language.keyword',
    'react': {'and': 'search-widget'},
    'value': List<String>()
  });

// Register result widget with react dependency on search and filter widget => To render the results
  final resultWidget = searchbase.register('result-widget', {
    'dataField': 'name',
    'react': {
      'and': ['search-widget', 'language-filter']
    },
  });

  // Render results
  querySelector('#output').innerHtml = """
    <div id="root">
      <h2 class="text-center">Searchbase Demo with Facet</h2>
      <div id="autocomplete" class="autocomplete">
        <input class="autocomplete-input" id="input" />
        <ul class="autocomplete-result-list"></ul>
      </div>
      <div class="row">
        <div class="col">
          <div class="filter" id="language-filter"></div>
        </div>
        <div class="col">
          <div id="results">
            <div class="loading">Loading results... </div>
          </div>
        </div>
      </div>
    </div>
  """;
  final input = querySelector('#input');
  void handleInput(e) {
    // Set the value to fetch the suggestions
    searchController.setValue(e.target.value,
        options: Options(triggerDefaultQuery: true));
  }

  input.addEventListener('input', handleInput);

  void handleKeyPress(e) {
    // Fetch the results
    if (e.key == 'Enter') {
      e.preventDefault();
      searchController.triggerCustomQuery();
    }
  }

  input.addEventListener('keydown', handleKeyPress);

  final resultElement = querySelector('#results');

  // Fetch initial results
  resultWidget.triggerDefaultQuery();

  // subscribe to `results` property to update re-build result list when update happens
  resultWidget.subscribeToStateChanges((change) {
    final results = change.Results!.next;
    final items = results.data?.map((i) {
      return """
    <div id=${i['_id']} class="result-set">
      <div class="image">
        <img src=${i['avatar']} alt=${i['name']} />
      </div>
      <div class="details">
        <h4>${i['name']}</h4>
        <p>${i['description']}</p>
      </div>
    </div>""";
    });
    final resultStats = """<p class="results-stats">
                          Showing ${results.numberOfResults} in ${results.time}ms
                        <p>""";

    resultElement.setInnerHtml("${resultStats}${items.join('')}",
        validator: new NodeValidatorBuilder.common()
          ..allowHtml5()
          ..allowElement('img',
              attributes: ['src'], uriPolicy: new DefaultUriPolicy()));
  }, [KeysToSubscribe.Results]);

  // Fetch initial filter options
  filterWidget.triggerDefaultQuery();

  // subscribe to updates in `aggregationData` property so filter options can change based on search
  filterWidget.subscribeToStateChanges((change) {
    final aggregations = change.AggregationData!.next;
    final container = document.getElementById('language-filter');
    container.setInnerHtml('');
    aggregations.data.forEach((i) {
      if (i['_key'] != null) {
        final checkbox = document.createElement('input');
        checkbox.setAttribute('type', 'checkbox');
        checkbox.setAttribute('name', i['_key']);
        checkbox.setAttribute('value', i['_key']);
        checkbox.id = i['_key'];
        checkbox.addEventListener('click', (event) {
          final List<String> values =
              filterWidget.value != null ? filterWidget.value : [];
          if (values.contains(i['_key'])) {
            values.remove(i['_key']);
          } else {
            values.add(i['_key']);
          }
          // Set filter value and trigger custom query
          filterWidget.setValue(values,
              options: Options(stateChanges: true, triggerCustomQuery: true));
        });
        final label = document.createElement('label');
        label.setAttribute('htmlFor', 'i._key');
        label.setInnerHtml("${i['_key']}(${i['_doc_count']})");
        final div = document.createElement('div');
        div.append(checkbox);
        div.append(label);
        container.append(div);
      }
    });
  }, [KeysToSubscribe.AggregationData]);

  searchController.subscribeToStateChanges((change) {
    print('Track State Updates');
    print(change);
  }, [KeysToSubscribe.Results]);
}

class DefaultUriPolicy implements UriPolicy {
  DefaultUriPolicy();
  bool allowsUri(String uri) {
    return true;
  }
}
```

### Facet example extended to use SearchStateController to handle state changes side-effects

This example is a version of the previous example which uses `SearchStateController` class to watch for state changes and perform relevant side-effects.

```dart
import 'dart:html';
import 'package:searchbase/searchbase.dart';

bool areListsEqual(var list1, var list2) {
  // check if both are lists
  if (!(list1 is List && list2 is List)
      // check if both have same length
      ||
      list1.length != list2.length) {
    return false;
  }

  // check if elements are equal
  for (int i = 0; i < list1.length; i++) {
    if (list1[i] != list2[i]) {
      return false;
    }
  }

  return true;
}

class DefaultUriPolicy implements UriPolicy {
  DefaultUriPolicy();
  @override
  bool allowsUri(String uri) {
    return true;
  }
}

void main() {
  final index = 'gitxplore-app';
  final url = 'https://@appbase-demo-ansible-abxiydt-arc.searchbase.io';
  final credentials = 'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61';

  final searchbase = SearchBase(index, url, credentials,
      appbaseConfig: AppbaseSettings(recordAnalytics: true));

  // Register search widget => To render the suggestions
  final searchController = searchbase.register('search-widget', {
    'enablePopularSuggestions': true,
    'dataField': [
      'name',
      'description',
      'name.raw',
      'fullname',
      'owner',
      'topics'
    ]
  });
  // Register filter widget with dependency on search widget
  final filterWidget = searchbase.register('language-filter', {
    'type': QueryType.term,
    'dataField': 'language.keyword',
    'react': {'and': 'search-widget'},
    'value': ""
  });
// Register result widget with react dependency on search and filter widget => To render the results
  final resultWidget = searchbase.register('result-widget', {
    'dataField': 'name',
    'react': {
      'and': ['search-widget', 'language-filter']
    },
    'defaultQuery': (SearchController controller) =>
        ({'track_total_hits': true})
  });

// Render results
  querySelector('#output')!.innerHtml = '''
    <div id="root">
      <h2 class="text-center">Searchbase Demo with Facet</h2>
      <div id="autocomplete" class="autocomplete">
        <input class="autocomplete-input" id="input" />
        <ul class="autocomplete-result-list"></ul>
      </div>
      <div class="row">
        <div class="col">
          <div class="filter" id="language-filter"></div>
        </div>
        <div class="col">
          <div id="results">
            <div class="loading">Loading results... </div>
          </div>
        </div>
      </div>
    </div>
  ''';
  final input = querySelector('#input');
  void handleInput(e) {
    // Set the value to fetch the suggestions
    searchController.setValue(e.target.value,
        options: Options(triggerDefaultQuery: true));
  }

  input!.addEventListener('input', handleInput);

  void handleKeyPress(e) {
    // Fetch the results
    if (e.key == 'Enter') {
      e.preventDefault();
      searchController.triggerCustomQuery();
    }
  }

  input.addEventListener('keydown', handleKeyPress);

  final resultElement = querySelector('#results');
  // Fetch initial results
  resultWidget.triggerDefaultQuery();

  // Fetch initial filter options
  filterWidget.triggerDefaultQuery();
  List<Map<dynamic, dynamic>>? prevAggData = [];

  // Instance of `SearchStateController` class
  // used for subscription to various properties for different widgets
  // and relevant side-effects are performed
  final searchStateController = SearchStateController(
    searchBase: searchbase,
    subscribeTo: {
      'result-widget': [KeysToSubscribe.Results],
      'language-filter': [KeysToSubscribe.AggregationData],
      'search-widget': [KeysToSubscribe.Results],
    },
    onChange: (next, prev) {
      // handle side-effects for state changes in result-widget
      if (next['result-widget'] != null) {
        print('result-widget subscribed');
        final results = next['result-widget']!.results;
        final items = results!.data.map((i) {
          return """
            <div id=${i['_id']} class="result-set">
              <div class="image">
                <img src=${i['avatar']} alt=${i['name']} />
              </div>
              <div class="details">
                <h4>${i['name']}</h4>
                <p>${i['description']}</p>
              </div>
            </div>""";
        });
        final resultStats = '''<p class="results-stats">
                          Showing ${results.numberOfResults} in ${results.time}ms
                        <p>''';
        resultElement!.setInnerHtml("$resultStats${items.join('')}",
            validator: NodeValidatorBuilder.common()
              ..allowHtml5()
              ..allowElement('img',
                  attributes: ['src'], uriPolicy: DefaultUriPolicy()));
      }

      // handle side-effects for state changes in language-filter
      if (next['language-filter'] != null &&
          areListsEqual(next['language-filter']!.aggregationData?.data,
                  prevAggData) ==
              false) {
        prevAggData = next['language-filter']!.aggregationData?.data;
        print('language-widget subscribed');
        final aggregations = next['language-filter']!.aggregationData;
        print(' aggregations?.data ${aggregations?.data}');
        final container = document.getElementById('language-filter');
        container!.setInnerHtml('');
        aggregations?.data?.forEach((i) {
          if (i['_key'] != null) {
            final checkbox = document.createElement('input');
            checkbox.setAttribute('type', 'checkbox');
            checkbox.setAttribute('name', i['_key']);
            checkbox.setAttribute('value', i['_key']);
            checkbox.id = i['_key'];
            checkbox.addEventListener('click', (event) {
              List values = [];
              if (filterWidget.value != null && filterWidget.value != "") {
                values = filterWidget.value;
              }
              if (values.contains(i['_key'])) {
                values.remove(i['_key']);
              } else {
                values.add(i['_key']);
              }
              // Set filter value and trigger custom query
              filterWidget.setValue(values,
                  options:
                      Options(stateChanges: true, triggerCustomQuery: true));
            });
            final label = document.createElement('label');
            label.setAttribute('htmlFor', 'i._key');
            label.setInnerHtml("${i['_key']}(${i['_doc_count']})");
            final div = document.createElement('div');
            div.append(checkbox);
            div.append(label);
            container.append(div);
          }
        });
      }
      // handle side-effects for state changes in search-widget
      if (next['search-widget'] != null) {
        print('search-widget subscribed');
        print('PREV ${prev['search-widget']?.results?.numberOfResults}');
        print('NEXT ${next['search-widget']?.results?.numberOfResults}');
      }
    },
  );
}

```
