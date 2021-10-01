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
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
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
            title: Text('RangeInput Demo'),
          ),
          body: Center(
            // A custom UI widget to render a list of results
            child: SearchWidgetConnector(
                id: 'result-widget',
                dataField: 'original_title',
                react: const {
                  'and': [
                    'range-selector',
                  ],
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
                  .8), //or any other color you want. e.g Colors.blue.withOpacity(0.5)
            ),
            child: Container(
              color: Colors.transparent,
              width: 400,
              child: Drawer(
                  child: Container(
                child: Center(
                  child: RangeInput(
                    id: 'range-selector',
                    title: "Publication Year",
                    rangeLabel: "to",
                    dataField: 'original_publication_year',
                    range: RangeType(
                      start: 3000,
                      end: ['other', 1990, 2000, 2010],
                    ),
                    defaultValue: DefaultValue(start: 1980, end: 2060),
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
