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
                  child:   child: RangeInput(
                    key: const Key("key2"),
                    id: 'range',
                    title: "Range L",
                    rangeLabel: "to",
                    dataField: 'original_publication_year',
                    range: const RangeType(
                        start: 3000, end: ['other', 1990, 2000, 2010],),
                    defaultValue: const DefaultValue(start: 1980, end: 2060),
                    rangeLabels: RangeLabelsType(
                      start: (value) {
                        return value == 'other' ? 'Custom Other' : 'yr $value';
                      },
                      end: (value) {
                        return value == 'other' ? 'Custom Other' : 'yr $value';
                      },
                    ),
                    validateRange: (start, end) {
                      print('custom validate');
                      if (start < end) {
                        return true;
                      }
                      return false;
                    },
                    errorMessage: (start, end) {
                      return 'Custom error $start > $end';
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

___results.dart___
```dart
import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';

class StarDisplay extends StatelessWidget {
  final int value;
  const StarDisplay({Key? key, this.value = 0}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (index) {
          return Icon(
            index < value ? Icons.star : Icons.star_border,
            size: 20,
          );
        }),
      ),
    );
  }
}

class ResultsWidget extends StatelessWidget {
  final SearchController searchController;
  ResultsWidget(this.searchController);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              color: Colors.white,
              height: 20,
              child: Text(
                  '${searchController.results!.numberOfResults} results found in ${searchController.results!.time.toString()} ms'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                var offset = (searchController.from != null
                        ? searchController.from
                        : 0)! +
                    searchController.size!;
                if (index == offset - 1) {
                  if (searchController.results!.numberOfResults > offset) {
                    // Load next set of results
                    searchController.setFrom(offset,
                        options: Options(triggerDefaultQuery: true));
                  }
                }
              });

              return Container(
                  child: (index < searchController.results!.data.length)
                      ? Container(
                          margin: const EdgeInsets.all(0.5),
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                          decoration: new BoxDecoration(
                              border: Border.all(color: Colors.black26)),
                          height: 200,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Card(
                                      semanticContainer: true,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      child: Image.network(
                                        searchController.results!.data[index]
                                            ["image_medium"],
                                        fit: BoxFit.fill,
                                      ),
                                      elevation: 5,
                                      margin: EdgeInsets.all(10),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 110,
                                          width: 280,
                                          child: ListTile(
                                            title: Tooltip(
                                              padding: EdgeInsets.all(5),
                                              height: 35,
                                              textStyle: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                                color: Colors.white,
                                              ),
                                              message:
                                                  'By: ${searchController.results!.data[index]["original_title"]}',
                                              child: Text(
                                                searchController
                                                            .results!
                                                            .data[index][
                                                                "original_title"]
                                                            .length <
                                                        40
                                                    ? searchController.results!
                                                            .data[index]
                                                        ["original_title"]
                                                    : '${searchController.results!.data[index]["original_title"].substring(0, 39)}...',
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                ),
                                              ),
                                            ),
                                            subtitle: Tooltip(
                                              padding: EdgeInsets.all(5),
                                              height: 35,
                                              textStyle: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                  fontWeight:
                                                      FontWeight.normal),
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey,
                                                    spreadRadius: 1,
                                                    blurRadius: 1,
                                                    offset: Offset(0, 1),
                                                  ),
                                                ],
                                                color: Colors.white,
                                              ),
                                              message:
                                                  'By: ${searchController.results!.data[index]["authors"]}',
                                              child: Text(
                                                searchController
                                                            .results!
                                                            .data[index]
                                                                ["authors"]
                                                            .length >
                                                        50
                                                    ? 'By: ${searchController.results!.data[index]["authors"].substring(0, 49)}...'
                                                    : 'By: ${searchController.results!.data[index]["authors"]}',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                            ),
                                            isThreeLine: true,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      25, 0, 0, 0),
                                              child: IconTheme(
                                                data: IconThemeData(
                                                  color: Colors.amber,
                                                  size: 48,
                                                ),
                                                child: StarDisplay(
                                                    value: searchController
                                                            .results!
                                                            .data[index][
                                                        "average_rating_rounded"]),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 5, 0, 0),
                                              child: Text(
                                                '(${searchController.results!.data[index]["average_rating"]} avg)',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      27, 10, 0, 0),
                                              child: Text(
                                                'Pub: ${searchController.results!.data[index]["original_publication_year"]}',
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : (searchController.requestPending
                          ? Center(child: CircularProgressIndicator())
                          : ListTile(
                              title: Center(
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        searchController.results!.data.length >
                                                0
                                            ? "No more results"
                                            : 'No results found',
                                    style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )));
            },
            itemCount: searchController.results!.data.length + 1,
          ),
        ),
      ],
    );
  }
}

```