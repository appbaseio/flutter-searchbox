import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'results.dart';
import 'author_filter.dart';
import 'audio_recorder.dart';
import 'mic_overlay.dart';

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

  FlutterSearchBoxApp({Key key}) : super(key: key);

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
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  OverlayState overlayStack;
  OverlayEntry overlayEntry;

  // To display or hide the overlay that shows the mic icon & the display text
  setOverlay(
      bool overlayVisibility, String displayText, BuildContext context) async {
    if (overlayVisibility) {
      // To find the closest enclosing overlay for the BuildContext
      overlayStack = Overlay.of(context);
      // Creating an entry for the overlay that can contain the mic_overlay widget
      // value contains the text to be displayed by the mic_overlay widget
      overlayEntry =
          OverlayEntry(builder: (context) => MicOverlay(value: displayText));
      // To insert overlayEntry into the overlay stack
      overlayStack.insert(overlayEntry);
    } else {
      if (overlayEntry != null) {
        // To remove the overlayEntry from the overlay stack
        overlayEntry.remove();
        overlayEntry = null;
      }
    }
  }

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
                        // A unique identifier that can be used by other widgets to reactively update data
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
                        customActions: [
                          // passing the Recorder as a custom action to the SearchBox widget
                          Recorder(
                            setOverlay:
                                (bool overlayVisibility, String displayText) {
                              setOverlay(
                                  overlayVisibility, displayText, context);
                            },
                          ),
                        ]),
                    // Initialize query to persist suggestions for active search
                    query: SearchBaseProvider?.of(context)
                        ?.getSearchWidget('search-widget')
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
              react: {
                'and': ['search-widget', 'author-filter'],
              },
              size: 10,
              triggerQueryOnInit: true,
              preserveResults: true,
              builder: (context, searchController) =>
                  ResultsWidget(searchController)),
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
          builder: (context, searchController) {
            // Call searchController's query at first time
            if (searchController.query == null) {
              searchController.triggerDefaultQuery();
            }
            return AuthorFilter(searchController);
          },
          // Avoid fetching query for each open/close action instead call it manually
          triggerQueryOnInit: false,
        ),
      ),
    );
  }
}
