import 'package:flutter/material.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'package:searchbase/searchbase.dart';
import './searchbaseprovider.dart';

/// It allows you to access the current state of your widgets along with the search results.
/// For instance, you can use this component to create results/no results or query/no query pages.
///
/// Examples Use(s):
///    - perform side-effects based on the results states of various widgets.
///    - render custom UI based on the current state of app.
///
/// For example,
/// ```dart
/// StateProvider(
///  subscribeTo: {
///    'author-filter': [KeysToSubscribe.Value]
///  },
///  onChange: (next, prev) {
///    print("Next state");
///    print(next['author-filter']?.va
///    print("Prev state");
///    print(prev['author-filter']?.value);
///  },
///  build: (searchState) {
///    var results =
///        searchState['result-widget']?.results?.numberOfResults;
///
///    if (results != null) {
///      return Text("results" + results.toString());
///    }
///    return Text("results" + "empty");
///  },
/// )
/// ```dart
class StateProvider extends StatefulWidget {
  /// A map of widget ids and list of properties to subscribe to.
  ///
  /// This property allows users to select the widgets for which
  /// they want to listen to the state changes.
  /// For example,
  /// ```dart
  /// StateProvider(
  ///   ...
  ///   subscribeTo: {
  ///     'result-component': [KeysToSubscribe.Results, KeysToSubscribe.From]
  ///   },
  ///   ...
  /// )
  /// ```
  final Map<String, List<KeysToSubscribe>>? subscribeTo;

  /// Callback function,  is a callback function called when the search state changes
  /// and accepts the previous and next search state as arguments.
  /// For example,
  /// ```dart
  /// StateProvider(
  ///   ...
  ///   onChange: (nextState, prevState) {
  ///         // do something here
  ///     },
  ///   ...
  /// )
  /// ```
  final void Function(Map<String, SearchControllerState>,
      Map<String, SearchControllerState>)? onChange;

  /// It is used for rendering a custom UI based on updated state
  /// For example,
  /// ```dart
  /// StateProvider(
  ///   ...
  ///   build: (controllerState) {
  ///     return Text(
  ///       'Total results on screen--- ${controllerState["result-widget"]?.results?.data?.length ?? ''} ',
  ///       style: TextStyle(
  ///         fontSize: 19.0,
  ///         color: Colors.red,
  ///       ),
  ///     );
  ///   },
  ///   ...
  /// )
  /// ```
  final Widget Function(Map<String, SearchControllerState>)? build;

  StateProvider({
    this.subscribeTo,
    this.onChange,
    this.build,
    Key? key,
  }) : super(key: key) {
    assert(build != null || onChange != null,
        "Atleast one, build or onChange prop is required.");
  }

  @override
  _StateProviderState createState() => _StateProviderState();
}

class _StateProviderState extends State<StateProvider> {
  Map<String, SearchControllerState> _controllersState = {};

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => subscribeToProperties());
  }

  void subscribeToProperties() {
    try {
      _controllersState = SearchStateController(
        searchBase: SearchBaseProvider.of(context),
        subscribeTo: widget.subscribeTo,
        onChange: (next, prev) {
          if (mounted) {
            setState(() {
              _controllersState = next;
            });
          }
          widget.onChange!(next, prev);
        },
      ).current;

      setState(() {});
    } catch (e) {
      print('error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.build != null) {
      return widget.build!(_controllersState);
    }
    return SizedBox.shrink();
  }
}
