import 'package:searchbase/searchbase.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// If the SearchBaseProvider.of method fails, this error will be thrown.
///
/// Often, when the `of` method fails, it is difficult to understand why since
/// there can be multiple causes. This error explains those causes so the user
/// can understand and fix the issue.
class SearchBaseProviderError<S> extends Error {
  /// Creates a SearchBaseProviderError
  SearchBaseProviderError();

  @override
  String toString() {
    return '''Error: No $S found. To fix, please try:
          
  * Wrapping your MaterialApp with the SearchBase, 
  rather than an individual Route
  * Providing full type information to your SearchBaseProvider, 
  SearchBase and SearchWidgetConnector
  * Ensure you are using consistent and complete imports. 
  E.g. always use `import 'package:my_app/app_state.dart';
  
If none of these solutions work, please file a bug at:
https://github.com/appbaseio/flutter-searchbox/issues/new
      ''';
  }
}

/// [SearchBaseProvider] is a provider widget that provides the [SearchBase] context to all descendants of this Widget.
///
/// Generally it should be a root widget in your App. Connect a widget by using [SearchWidgetConnector] or [SearchBox].
/// [SearchBaseProvider] binds the backend app (data source) with the UI view widgets (elements wrapped within [SearchBaseProvider]), allowing a UI widget to be reactively updated every time there is a change in the data source or in other UI widgets.
class SearchBaseProvider extends InheritedWidget {
  final SearchBase _searchbase;

  /// Create a [SearchBaseProvider] by passing in the required [searchbase] and [child] parameters.
  const SearchBaseProvider({
    Key? key,
    required SearchBase searchbase,
    required Widget child,
  })  : _searchbase = searchbase,
        super(key: key, child: child);

  static SearchBase of(BuildContext context, {bool listen = true}) {
    final provider = (listen
        ? context.dependOnInheritedWidgetOfExactType<SearchBaseProvider>()
        : context
            .getElementForInheritedWidgetOfExactType<SearchBaseProvider>()
            ?.widget) as SearchBaseProvider?;

    if (provider == null) throw SearchBaseProviderError<SearchBaseProvider>();

    return provider._searchbase;
  }

  @override
  bool updateShouldNotify(SearchBaseProvider oldWidget) =>
      _searchbase != oldWidget._searchbase;
}
