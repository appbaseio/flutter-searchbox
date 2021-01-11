import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'results.dart';
import 'author_filter.dart';

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
    // The StoreProvider should wrap your MaterialApp or WidgetsApp. This will
    // ensure all routes have access to the store.
    return SearchBaseProvider(
      // Pass the store to the StoreProvider. Any ancestor `StoreConnector`
      // Widgets will find and use this value as the `Store`.
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
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: SearchBox(
                          id: 'search-component',
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
            child: SearchComponentConnector(
                id: 'result-component',
                dataField: 'original_title',
                react: {
                  'and': ['search-component', 'author-filter'],
                },
                size: 10,
                triggerQueryOnInit: true,
                preserveResults: true,
                builder: (context, component) => ResultsWidget(component)),
          ),
          drawer: SearchComponentConnector(
            id: 'author-filter',
            type: QueryType.term,
            dataField: "authors.keyword",
            size: 10,
            // Initialize with default value
            value: List<String>(),
            react: {
              'and': ['search-component']
            },
            builder: (context, component) {
              // Call component's query at first time
              if (component.query == null) {
                component.triggerDefaultQuery();
              }
              return AuthorFilter(component);
            },
            // Avoid fetching query for each open/close action instead call it manually;
            triggerQueryOnInit: false,
            // Do not remove the component's insantce after unmount
            destroyOnUnmount: false,
          )),
    );
  }
}
