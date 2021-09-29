## Flutter SearchBox UI

[flutter_searchbox_ui](https://github.com/appbaseio/flutter-searchbox/tree/master/flutter_searchbox_ui) provides React UI components for Elasticsearch,  UI widgets with different types of search queries. As the name suggests, it provides  UI widgets for Elasticsearch and Appbase.io.

Currently, We support `range_input` 

## Installation

To install `flutter_searchbox_ui`, please follow the following steps:

1. Depend on it

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_searchbox: ^2.0.1-nullsafety
  searchbase: ^2.1.0
  flutter_searchbox_ui: 1.0.0
```

2. Install it

You can install packages from the command line:

```bash
$ flutter pub get
```

## Basic usage

### An example with RangeInput

<p float="left" style="margin-top: 50px">
  <img alt="Basic Example" src="https://user-images.githubusercontent.com/57627350/135332703-00b4632a-75fc-49c6-9165-c57e164f1b9e.gif" width="250" />
</p>

The following example renders a `RangeInput` ui widget from the `flutter_searchbox_ui` library with id `range-filter` to render a range input selector,. This widget is being used by `result-widget` to filter the results data based on the range of `original_publication_year` of books, selected in `range-filter`(check the `react` property).


```dart
import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'package:flutter_searchbox_ui/flutter_searchbox_ui.dart';

import 'results.dart';


void main() {
  runApp(FlutterSearchBoxUIApp());
}

class FlutterSearchBoxUIApp extends StatelessWidget {
  // Avoid creating searchbase instance in build method
  // to preserve state on hot reloading
  final searchbaseInstance = SearchBase(
      'good-books-ds',
      'https://appbase-demo-ansible-abxiydt-arc.searchbase.io',
      'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61',
      appbaseConfig: AppbaseSettings(
          recordAnalytics: true,
          // Use unique user id to personalize the recent searches
          userId: 'jon@appbase.io'));

  
  FlutterSearchBoxUIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The SearchBaseProvider should wrap your MaterialApp or WidgetsApp. This will
    // ensure all routes have access to the store.
    return SearchBaseProvider(
      // Pass the searchbase instance to the SearchBaseProvider. Any ancestor `SearchWidgetConnector`
      // widgets will find and use this value as the `SearchController`.
      searchbase: searchbaseInstance,
      child: MaterialApp(
        title: "SearchBox Demo",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home:const  HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}): super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SearchBox Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Invoke the Search Delegate to display search UI with autosuggestions
                    showSearch(
                      context: context,
                      // SearchBox widget from flutter searchbox
                      delegate: SearchBox(
                          // A unique identifier that can be used by other widgetss to reactively update data
                          id: 'search-widget',
                          enableRecentSearches: true,
                          enablePopularSuggestions: true,
                          showAutoFill: true,
                          maxPopularSuggestions: 3,
                          size: 5,
                          dataField: [
                            {'field': 'original_title', 'weight': 1},
                            {'field': 'original_title.search', 'weight': 3}
                          ],
                          // pass the speech to text instance to enable voice search
                          ),
                      // Initialize query to persist suggestions for active search
                      query: SearchBaseProvider?.of(context)
                          .getSearchWidget('search-widget')
                          ?.value
                          ?.toString(),
                    );
                  }),
            ],
            title: Text('SearchBox Demo'),
          ),
          body: Center(
            // A custom UI widget to render a list of results
            child: SearchWidgetConnector(
                id: 'result-widget',
                dataField: 'original_title',
                react: const {
                  'and': ['search-widget', 'range'],
                },
                size: 10,
                triggerQueryOnInit: true,
                preserveResults: true,
                builder: (context, searchController) =>
                    ResultsWidget(searchController)),
          ),
          // A custom UI widget to render a list of authors
          drawer: Theme(
            data: Theme.of(context).copyWith(
              // Set the transparency here
              canvasColor: Colors.white.withOpacity(
                  .6), //or any other color you want. e.g Colors.blue.withOpacity(0.5)
            ),
            child: Container(
              color: Colors.transparent,
              width: 400,
              child: Drawer(
                  child: Container(
                child: Center(
                  key: const Key("key1"),
                  child: RangeInput(
                    key: const Key("key2"),
                    id: 'range',
                    title: "Range",
                    rangeLabel: "until",
                    dataField: 'original_publication_year',
                    range: const RangeType(
                        start: 3000, end: ['other', 1990, 2000, 2010]),
                    rangeLabels: RangeLabelsType(
                      start: (value) {
                        return '# $value €';
                      },
                      end: (value) {
                        return '# $value €';
                      },
                    ),
                    validateRange: (start, end) {
                      if (start < end) {
                        return true;
                      }
                      return false;
                    },
                    errorMessage: (start, end) {
                      return 'Starting value: $start seems greater than Ending Value: $end';
                    },
                  ),
                ),
              )),
            ),
          )),
    );
  }
}

```