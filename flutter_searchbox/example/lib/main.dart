import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'results.dart';
import 'author_filter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_to_text_provider.dart' as stp;

void main() {
  runApp(FlutterSearchBoxApp());
}

class FlutterSearchBoxApp extends StatelessWidget {
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

  // Create an instance of speech to text provider at top level of your application
  // It is only required to integrate voice search.
  final stp.SpeechToTextProvider speechToTextInstance =
      stp.SpeechToTextProvider(stt.SpeechToText());

  FlutterSearchBoxApp({Key? key}) : super(key: key);

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
        home: HomePage(speechToTextInstance: speechToTextInstance),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final stp.SpeechToTextProvider? speechToTextInstance;

  const HomePage({super.key, this.speechToTextInstance});
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
                  icon: const Icon(Icons.search),
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
                          speechToTextInstance: speechToTextInstance),
                      // Initialize query to persist suggestions for active search
                      query: SearchBaseProvider.of(context)
                          .getSearchWidget('search-widget')
                          ?.value
                          ?.toString(),
                    );
                  }),
            ],
            title: StateProvider(
                subscribeTo: const {
                  'result-widget': [KeysToSubscribe.Results]
                },
                onChange: (next, prev) {
                  print("Next state");
                  print(next['result-widget']?.results?.data.length);
                  print("Prev state");
                  print(prev['result-widget']?.results?.data.length);
                },
                build: (searchState) {
                  var results =
                      searchState['result-widget']?.results?.numberOfResults;
                  print("SEARCH STATE");
                  print(searchState);
                  if (results != null) {
                    return Text("results$results");
                  }
                  return const Text("results" "empty");
                }),
          ),
          body: Center(
            // A custom UI widget to render a list of results
            child: SearchWidgetConnector(
                id: 'result-widget',
                dataField: 'original_title',
                react: const {
                  'and': ['search-widget', 'author-filter'],
                },
                size: 10,
                triggerQueryOnInit: true,
                preserveResults: true,
                builder: (context, searchController) =>
                    ResultsWidget(searchController)),
          ),
          // A custom UI widget to render a list of authors
          // drawer: StateProvider(
          //     subscribeTo: const {
          //       'result-widget': [KeysToSubscribe.Results]
          //     },
          //     build: (searchState) {
          //       var results =
          //           searchState['result-widget']?.results?.numberOfResults;
          //       print("SEARCH STATE");
          //       print(searchState);
          //       if (results != null) {
          //         return Text("results$results");
          //       }
          //       return const Text("results" "empty");
          //     }),
          drawer: SearchWidgetConnector(
            id: 'author-filter',
            type: QueryType.term,
            dataField: "authors.keyword",
            size: 10,
            // Initialize with default value
            value: [],
            react: const {
              'and': ['search-widget']
            },
            builder: (context, searchController) {
              // Call searchController's query at first time
              if (searchController.query == null) {
                searchController.triggerDefaultQuery();
              }
              return AuthorFilter(searchController);
            },
            // Avoid fetching query for each open/close action instead call it manually
            triggerQueryOnInit: false,
          )),
    );
  }
}
