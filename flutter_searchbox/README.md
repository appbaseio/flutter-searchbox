## Flutter SearchBox

[flutter_searchbox](https://github.com/appbaseio/flutter-searchbox/tree/master/flutter_searchbox) provides declarative API to query Elasticsearch, and binds UI widgets with different types of search queries. As the name suggests, it provides a searchbox UI widget for Elasticsearch and Appbase.io.

## Installation

To install `flutter_searchbox`, please follow the following steps:

1. Depend on it

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_searchbox: ^1.0.0
  searchbase: ^1.0.0
```

2. Install it

You can install packages from the command line:

```bash
$ flutter pub get
```

## Basic usage

### A simple example

![Basic Example](http://g.recordit.co/N0M8IOYeqT.gif)

The following example renders an autosuggestion [SearchBox](`search-widget`) with one custom widget [SearchWidgetConnector](`result-widget`) to render the results. The `result-widget` watches the `search-widget` for input changes and updates its UI when the user selects a suggestion.

```dart
import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';

void main() {
  runApp(FlutterSearchBoxApp());
}

class FlutterSearchBoxApp extends StatelessWidget {
  final SearchBase searchbase;
  final index = 'good-books-ds';
  final credentials = 'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61';
  final url = 'https://arc-cluster-appbase-demo-6pjy6z.searchbase.io';

  FlutterSearchBoxApp({Key key, this.searchbase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The SearchBaseProvider should wrap your MaterialApp or WidgetsApp. This will
    // ensure all routes have access to the store.
    return SearchBaseProvider(
      // Pass the searchbase instance to the SearchBaseProvider. Any ancestor `SearchWidgetConnector`
      // Widgets will find and use this value as the `SearchWidget`.
      searchbase: SearchBase(index, url, credentials,
          appbaseConfig: AppbaseSettings(recordAnalytics: true)),
      child: MaterialApp(
        title: "SearchBox Demo",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
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
                        size: 10,
                        dataField: [
                          {'field': 'original_title', 'weight': 1},
                          {'field': 'original_title.search', 'weight': 3}
                        ],
                      ));
                }),
          ],
          title: Text('SearchBox Demo'),
        ),
        body: Center(
          // A custom UI widget to render a list of results
          child: SearchWidgetConnector(
              id: 'result-widget',
              dataField: 'original_title',
              react: {
                'and': ['search-widget'],
              },
              size: 10,
              triggerQueryOnInit: true,
              preserveResults: true,
              builder: (context, searchWidget) => ResultsWidget(searchWidget)),
        ),
      ),
    );
  }
}

class ResultsWidget extends StatelessWidget {
  final SearchWidget searchWidget;
  ResultsWidget(this.searchWidget);
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
                  '${searchWidget.results.numberOfResults} results found in ${searchWidget.results.time.toString()} ms'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                var offset =
                    (searchWidget.from != null ? searchWidget.from : 0) +
                        searchWidget.size;
                if (index == offset - 1) {
                  if (searchWidget.results.numberOfResults > offset) {
                    // Load next set of results
                    searchWidget.setFrom(offset,
                        options: Options(triggerDefaultQuery: true));
                  }
                }
              });

              return Container(
                  child: (index < searchWidget.results.data.length)
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
                                        searchWidget.results.data[index]
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
                                                  'By: ${searchWidget.results.data[index]["original_title"]}',
                                              child: Text(
                                                searchWidget
                                                            .results
                                                            .data[index][
                                                                "original_title"]
                                                            .length <
                                                        40
                                                    ? searchWidget
                                                            .results.data[index]
                                                        ["original_title"]
                                                    : '${searchWidget.results.data[index]["original_title"].substring(0, 39)}...',
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
                                                  'By: ${searchWidget.results.data[index]["authors"]}',
                                              child: Text(
                                                searchWidget
                                                            .results
                                                            .data[index]
                                                                ["authors"]
                                                            .length >
                                                        50
                                                    ? 'By: ${searchWidget.results.data[index]["authors"].substring(0, 49)}...'
                                                    : 'By: ${searchWidget.results.data[index]["authors"]}',
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
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 5, 0, 0),
                                              child: Text(
                                                '(${searchWidget.results.data[index]["average_rating"]} avg)',
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
                                                'Pub: ${searchWidget.results.data[index]["original_publication_year"]}',
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
                      : (searchWidget.requestPending
                          ? Center(child: CircularProgressIndicator())
                          : ListTile(
                              title: Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: searchWidget.results.data.length > 0
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
            itemCount: searchWidget.results.data.length + 1,
          ),
        ),
      ],
    );
  }
}
```

### An example with a facet

![Facet Example](http://g.recordit.co/2hqx7pGrdP.gif)

The following example renders one more custom widget with id `author-filter` to render a list of authors. This widget is being used by `result-widget` to filter the results data. The `author-filter` widget also reacts to the `search-widget` (check the `react` property) to update the authors list reactively whenever the search query changes.

```dart
import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';

void main() {
  runApp(FlutterSearchBoxApp());
}

class FlutterSearchBoxApp extends StatelessWidget {
  final SearchBase searchbase;
  final index = 'good-books-ds';
  final credentials = 'a03a1cb71321:75b6603d-9456-4a5a-af6b-a487b309eb61';
  final url = 'https://arc-cluster-appbase-demo-6pjy6z.searchbase.io';

  FlutterSearchBoxApp({Key key, this.searchbase}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The SearchBaseProvider should wrap your MaterialApp or WidgetsApp. This will
    // ensure all routes have access to the store.
    return SearchBaseProvider(
      // Pass the searchbase instance to the SearchBaseProvider. Any ancestor `SearchWidgetConnector`
      // Widgets will find and use this value as the `SearchWidget`.
      searchbase: SearchBase(index, url, credentials,
          appbaseConfig: AppbaseSettings(recordAnalytics: true)),
      child: MaterialApp(
        title: "SearchBox Demo",
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
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
                          size: 10,
                          dataField: [
                            {'field': 'original_title', 'weight': 1},
                            {'field': 'original_title.search', 'weight': 3}
                          ],
                        ));
                  }),
            ],
            title: Text('SearchBox Demo'),
          ),
          body: Center(
            // A custom UI widget to render a list of results
            child: SearchWidgetConnector(
                id: 'result-widget',
                dataField: 'original_title',
                react: {
                  'and': ['search-widget', 'author-filter'],
                },
                size: 10,
                triggerQueryOnInit: true,
                preserveResults: true,
                builder: (context, searchWidget) =>
                    ResultsWidget(searchWidget)),
          ),
          // A custom UI widget to render a list of authors
          drawer: SearchWidgetConnector(
            id: 'author-filter',
            type: QueryType.term,
            dataField: "authors.keyword",
            size: 10,
            // Initialize with default value
            value: List<String>(),
            react: {
              'and': ['search-widget']
            },
            builder: (context, searchWidget) {
              // Call searchWidget's query at first time
              if (searchWidget.query == null) {
                searchWidget.triggerDefaultQuery();
              }
              return AuthorFilter(searchWidget);
            },
            // Avoid fetching query for each open/close action instead call it manually
            triggerQueryOnInit: false,
            // Do not remove the search widget's instance after unmount
            destroyOnDispose: false,
          )),
    );
  }
}

class ResultsWidget extends StatelessWidget {
  final SearchWidget searchWidget;
  ResultsWidget(this.searchWidget);
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
                  '${searchWidget.results.numberOfResults} results found in ${searchWidget.results.time.toString()} ms'),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                var offset =
                    (searchWidget.from != null ? searchWidget.from : 0) +
                        searchWidget.size;
                if (index == offset - 1) {
                  if (searchWidget.results.numberOfResults > offset) {
                    // Load next set of results
                    searchWidget.setFrom(offset,
                        options: Options(triggerDefaultQuery: true));
                  }
                }
              });

              return Container(
                  child: (index < searchWidget.results.data.length)
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
                                        searchWidget.results.data[index]
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
                                                  'By: ${searchWidget.results.data[index]["original_title"]}',
                                              child: Text(
                                                searchWidget
                                                            .results
                                                            .data[index][
                                                                "original_title"]
                                                            .length <
                                                        40
                                                    ? searchWidget
                                                            .results.data[index]
                                                        ["original_title"]
                                                    : '${searchWidget.results.data[index]["original_title"].substring(0, 39)}...',
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
                                                  'By: ${searchWidget.results.data[index]["authors"]}',
                                              child: Text(
                                                searchWidget
                                                            .results
                                                            .data[index]
                                                                ["authors"]
                                                            .length >
                                                        50
                                                    ? 'By: ${searchWidget.results.data[index]["authors"].substring(0, 49)}...'
                                                    : 'By: ${searchWidget.results.data[index]["authors"]}',
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
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 5, 0, 0),
                                              child: Text(
                                                '(${searchWidget.results.data[index]["average_rating"]} avg)',
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
                                                'Pub: ${searchWidget.results.data[index]["original_publication_year"]}',
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
                      : (searchWidget.requestPending
                          ? Center(child: CircularProgressIndicator())
                          : ListTile(
                              title: Center(
                                child: RichText(
                                  text: TextSpan(
                                    text: searchWidget.results.data.length > 0
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
            itemCount: searchWidget.results.data.length + 1,
          ),
        ),
      ],
    );
  }
}

class FilterHeader extends PreferredSize {
  final double height;
  final Widget child;

  FilterHeader({@required this.child, this.height = kToolbarHeight});

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      // color: Colors.white,
      alignment: Alignment.centerLeft,
      child: child,
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
    );
  }
}

class AuthorFilter extends StatelessWidget {
  final SearchWidget searchWidget;

  AuthorFilter(this.searchWidget);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 105, 0, 0),
        child: Column(
          children: [
            Container(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  height: 750,
                  color: Colors.white,
                  child: Scaffold(
                    appBar: FilterHeader(
                      height: 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: 'Selects Authors',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ],
                      ),
                    ),
                    body: searchWidget.requestPending
                        ? Center(child: CircularProgressIndicator())
                        : ListView(
                            children:
                                searchWidget.aggregationData.data.map((bucket) {
                              return Container(
                                child: Column(
                                  children: [
                                    new CheckboxListTile(
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      activeColor: Colors.black54,
                                      dense: true,
                                      title: new Text(
                                          "${bucket['_key']} (${bucket['_doc_count']})"),
                                      value: (searchWidget.value == null
                                              ? []
                                              : searchWidget.value)
                                          .contains(bucket['_key']),
                                      onChanged: (bool value) {
                                        final List<String> values =
                                            searchWidget.value == null
                                                ? []
                                                : searchWidget.value;
                                        if (values.contains(bucket['_key'])) {
                                          values.remove(bucket['_key']);
                                        } else {
                                          values.add(bucket['_key']);
                                        }
                                        searchWidget.setValue(values);
                                      },
                                    ),
                                    const Divider(
                                      color: Colors.black,
                                      height: 10,
                                      thickness: 0.1,
                                      indent: 25,
                                      endIndent: 20,
                                    )
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ),
              ),
            ),
            Container(
              child: Align(
                alignment: Alignment.center,
                child: Container(
                  color: Colors.black,
                  height: 70,
                  width: 500,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 6,
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 23.0),
                            color: Colors.black,
                            child: Text(
                              'Apply',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              searchWidget.triggerCustomQuery();
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                text: '|',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 50,
                                    fontWeight: FontWeight.w100),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: RaisedButton(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 23.0),
                            color: Colors.black,
                            child: Text(
                              'Close',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

```
