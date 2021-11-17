library flutter_searchbox;

import 'dart:async';
import 'package:searchbase/searchbase.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:speech_to_text/speech_to_text_provider.dart' as stp;
import 'package:speech_to_text/speech_recognition_event.dart' as ste;
import 'dart:io' show Platform;

// [MicOptions] class allows to define custom configuration for mic
class MicOptions {
  /// [listenFor] sets the maximum duration that it will listen for, after that it automatically stops the listen for you.
  ///
  /// The default is 30 seonds. It should be in a range of `5s` to `30s`.
  Duration? listenFor;

  /// [pauseFor] sets the maximum duration of a pause in speech with no words detected, after that it automatically stops the listen for you.
  ///
  /// The default value is 3 seconds for ios and 5 seconds for android. It should be in a range of `3s` to `30s` and must be less than [listenFor] property.
  Duration? pauseFor;

  /// The maximum number of allowed words in speech. Mic would automatically stop once it hit the maximum word limit.
  ///
  /// The default value is set to 12. It should be in a range of `1` to `30` words.
  int? maximumWordsLimit;

  /// Allows to custom the micIcon at the right side.
  Widget? /*?*/ micIcon;

  /// To use a custom mic icon if the permission is denied.
  Widget? micIconDenied;

  /// To use a custom mic icon when mic is in listening state.
  Widget? micIconOn;

  /// Customize mic icon when speech recognition failed or user didn't speak.
  Widget? micIconOff;

  ///[partialResults] if true the listen reports results as they are recognized, when false only final results are reported. Defaults to true.
  bool? partialResults;

  /// [localeId] is an optional locale that can be used to listen in a language other than the current system default. See [locales] to find the list of supported languages for listening
  String? localeId;

  MicOptions(
      {this.listenFor,
      this.pauseFor,
      this.maximumWordsLimit,
      this.micIcon,
      this.micIconDenied,
      this.micIconOff,
      this.micIconOn,
      this.partialResults,
      this.localeId});
}

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

/// Build a Widget using the [BuildContext] and [ViewModel].
typedef ViewModelBuilder<ViewModel> = Widget Function(
  BuildContext context,
  SearchController vm,
);

// Can be used to access the searchbase context
class _SearchBaseConnector<S, ViewModel> extends StatelessWidget {
  final Widget Function(SearchBase searchbase) child;

  const _SearchBaseConnector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child(SearchBaseProvider.of(context));
  }
}

class _SearchWidgetListenerState<S, ViewModel>
    extends State<_SearchWidgetListener<S, ViewModel>> {
  final ViewModelBuilder<ViewModel> builder;

  final SearchBase searchbase;

  final String id;

  late SearchController componentInstance;

  final List<String>? subscribeTo;

  /// Defaults to `true`. It can be used to prevent the default query execution.
  final bool? triggerQueryOnInit;

  /// Defaults to `true`. It can be used to prevent state updates.
  final bool? shouldListenForChanges;

  /// If set to `true` then on dispose the widget will get removed from seachbase context i.e can not participate in query generation.
  final bool? destroyOnDispose;

  Map? componentConfig;

  _SearchWidgetListenerState({
    required this.searchbase,
    required this.builder,
    required this.id,
    this.subscribeTo,
    this.triggerQueryOnInit,
    this.shouldListenForChanges,
    this.destroyOnDispose = false,
    this.componentConfig,
  }) {
    // Subscribe to state changes
    this.componentInstance = searchbase.register(id, componentConfig);
    if (this.shouldListenForChanges != false) {
      this
          .componentInstance
          .subscribeToStateChanges(subscribeToState, subscribeTo);
    }
  }

  @override
  void initState() {
    // Trigger the initial query
    if (triggerQueryOnInit != false) {
      componentInstance.triggerDefaultQuery();
    }
    super.initState();
  }

  @override
  void dispose() {
    // Remove subscriptions
    componentInstance.unsubscribeToStateChanges(subscribeToState);
    if (destroyOnDispose == true) {
      // Unregister component
      searchbase.unregister(id);
    }
    super.dispose();
  }

  void subscribeToState(Map<String, Changes> changes) {
    if (mounted) {
      // Trigger the rebuild on state changes
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      componentInstance,
    );
  }
}

class _SearchWidgetListener<S, ViewModel> extends StatefulWidget {
  final ViewModelBuilder<ViewModel> builder;

  final SearchBase searchbase;

  final List<String>? subscribeTo;

  /// Defaults to `true`. It can be used to prevent the default query execution.
  final bool? triggerQueryOnInit;

  /// Defaults to `true`. It can be used to prevent state updates.
  final bool? shouldListenForChanges;

  /// Defaults to `true`. If set to `false` then component will not get removed from seachbase context i.e can participate in query generation.
  final bool? destroyOnDispose;

  // Properties to configure search component
  final String id;

  final String? index;
  final String? url;
  final String? credentials;
  final Map<String, String>? headers;
  // to enable the recording of analytics
  final AppbaseSettings? appbaseConfig;

  final QueryType? type;

  final Map<String, dynamic>? react;

  final String? queryFormat;

  final dynamic dataField;

  final String? categoryField;

  final String? categoryValue;

  final String? /*?*/ nestedField;

  final int? from;

  final int? size;

  final SortType? sortBy;

  final dynamic value;

  final String? aggregationField;

  final int? aggregationSize;

  final Map? after;

  final bool? includeNullValues;

  final List<String>? includeFields;

  final List<String>? excludeFields;

  final dynamic fuzziness;

  final bool? searchOperators;

  final bool? highlight;

  final dynamic highlightField;

  final Map? customHighlight;

  final int? interval;

  final List<String>? aggregations;

  final String? missingLabel;

  final bool? showMissing;

  final Map Function(SearchController component)? defaultQuery;

  final Map Function(SearchController component)? customQuery;

  final bool? execute;

  final bool? enableSynonyms;

  final String? selectAllLabel;

  final bool? pagination;

  final bool? queryString;

  // To enable the popular suggestions
  final bool? enablePopularSuggestions;

  /// can be used to configure the size of popular suggestions. The default value is `5`.
  final int? maxPopularSuggestions;

  // To show the distinct suggestions
  final bool? showDistinctSuggestions;

  // preserve the data for infinite loading
  final bool? preserveResults;

  /// When set to `true`, the dependent controller's (which is set via react prop) value would get cleared whenever the query changes.
  ///
  /// The default value is `false`
  final bool clearOnQueryChange;
  // callbacks
  final TransformRequest? transformRequest;

  final TransformResponse? transformResponse;

  final List<Map>? results;

  final String? distinctField;

  final Map? distinctFieldConfig;

  /* ---- callbacks to create the side effects while querying ----- */

  final Future Function(dynamic value)? beforeValueChange;

  /* ------------- change events -------------------------------- */

  // called when value changes
  final void Function(dynamic next, {dynamic prev})? onValueChange;

  // called when results change
  final void Function(List<Map> next, {List<Map> prev})? onResults;

  // called when composite aggregationData change
  final void Function(List<Map> next, {List<Map> prev})? onAggregationData;
  // called when there is an error while fetching results
  final void Function(dynamic error)? onError;

  // called when request status changes
  final void Function(String next, {String prev})? onRequestStatusChange;

  // called when query changes
  final void Function(Map next, {Map prev})? onQueryChange;

  _SearchWidgetListener({
    Key? key,
    required this.searchbase,
    required this.builder,
    required this.id,
    this.index,
    this.credentials,
    this.url,
    this.subscribeTo,
    this.triggerQueryOnInit,
    this.shouldListenForChanges,
    this.destroyOnDispose,
    // properties to configure search component class
    this.appbaseConfig,
    this.transformRequest,
    this.transformResponse,
    this.headers,
    this.type,
    this.react,
    this.queryFormat,
    this.dataField,
    this.categoryField,
    this.categoryValue,
    this.nestedField,
    this.from,
    this.size,
    this.sortBy,
    this.aggregationField,
    this.aggregationSize,
    this.after,
    this.includeNullValues,
    this.includeFields,
    this.excludeFields,
    this.fuzziness,
    this.searchOperators,
    this.highlight,
    this.highlightField,
    this.customHighlight,
    this.interval,
    this.aggregations,
    this.missingLabel,
    this.showMissing,
    this.execute,
    this.enableSynonyms,
    this.selectAllLabel,
    this.pagination,
    this.queryString,
    this.defaultQuery,
    this.customQuery,
    this.beforeValueChange,
    this.onValueChange,
    this.onResults,
    this.onAggregationData,
    this.onError,
    this.onRequestStatusChange,
    this.onQueryChange,
    this.enablePopularSuggestions,
    this.maxPopularSuggestions,
    this.showDistinctSuggestions,
    this.preserveResults,
    this.clearOnQueryChange = false,
    this.value,
    this.results,
    this.distinctField,
    this.distinctFieldConfig,
  }) : super(key: key);

  @override
  _SearchWidgetListenerState createState() =>
      _SearchWidgetListenerState<S, ViewModel>(
        id: id,
        searchbase: searchbase,
        componentConfig: {
          'index': index,
          'url': url,
          'credentials': credentials,
          'headers': headers,
          'transformRequest': transformRequest,
          'transformResponse': transformResponse,
          'appbaseConfig': appbaseConfig,
          'type': type,
          'dataField': dataField,
          'react': react,
          'queryFormat': queryFormat,
          'categoryField': categoryField,
          'categoryValue': categoryValue,
          'nestedField': nestedField,
          'from': from,
          'size': size,
          'sortBy': sortBy,
          'aggregationField': aggregationField,
          'aggregationSize': aggregationSize,
          'after': after,
          'includeNullValues': includeNullValues,
          'includeFields': includeFields,
          'excludeFields': excludeFields,
          'results': results,
          'fuzziness': fuzziness,
          'searchOperators': searchOperators,
          'highlight': highlight,
          'highlightField': highlightField,
          'customHighlight': customHighlight,
          'interval': interval,
          'aggregations': aggregations,
          'missingLabel': missingLabel,
          'showMissing': showMissing,
          'execute': execute,
          'enableSynonyms': enableSynonyms,
          'selectAllLabel': selectAllLabel,
          'pagination': pagination,
          'queryString': queryString,
          'defaultQuery': defaultQuery,
          'customQuery': customQuery,
          'beforeValueChange': beforeValueChange,
          'onValueChange': onValueChange,
          'onResults': onResults,
          'onAggregationData': onAggregationData,
          'onError': onError,
          'onRequestStatusChange': onRequestStatusChange,
          'onQueryChange': onQueryChange,
          'enablePopularSuggestions': enablePopularSuggestions,
          'maxPopularSuggestions': maxPopularSuggestions,
          'showDistinctSuggestions': showDistinctSuggestions,
          'preserveResults': preserveResults,
          'clearOnQueryChange': clearOnQueryChange,
          'value': value,
          'distinctField': distinctField,
          'distinctFieldConfig': distinctFieldConfig,
        },
        builder: builder,
        subscribeTo: subscribeTo,
        triggerQueryOnInit: triggerQueryOnInit,
        shouldListenForChanges: shouldListenForChanges,
        destroyOnDispose: destroyOnDispose,
      );
}

class _MicButtonListeningState extends State<_MicButtonListening>
    with SingleTickerProviderStateMixin {
  _MicButtonListeningState();

  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      child: Icon(
        Icons.mic,
        color: Colors.white,
      ),
      decoration:
          BoxDecoration(shape: BoxShape.circle, color: Colors.blue, boxShadow: [
        BoxShadow(
            color: Colors.lightBlue,
            blurRadius: _animation.value,
            spreadRadius: _animation.value)
      ]),
    );
  }
}

class _MicButtonListening extends StatefulWidget {
  _MicButtonListening();
  @override
  _MicButtonListeningState createState() => _MicButtonListeningState();
}

class _MicButtonState extends State<_MicButton> {
  final stp.SpeechToTextProvider? speechToTextInstance;
  final void Function()? onStart;
  final MicOptions? micOptions;
  final void Function(String out)? onMicResults;

  late StreamSubscription<ste.SpeechRecognitionEvent> _subscription;

  bool? _isListening = false;
  bool _isDialogActive = false;
  bool _isSpeechAvailable = false;
  bool _isSubscribed = false;
  String _recognizedText = "";
  MicOptions defaultMicOptions = MicOptions(
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: Platform.isAndroid ? 5 : 3),
      localeId: null,
      partialResults: true,
      micIcon: Icon(Icons.mic),
      micIconDenied: Icon(Icons.mic_off),
      micIconOff: Container(
        width: 70,
        height: 70,
        child: Icon(Icons.mic, color: Colors.white),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
      ),
      micIconOn: _MicButtonListening(),
      maximumWordsLimit: 12);

  BuildContext? dialogContext;
  void Function(void Function() fn)? setStateDialog;

  _MicButtonState(this.speechToTextInstance,
      {this.onMicResults, this.onStart, this.micOptions}) {
    if (micOptions != null) {
      if (micOptions!.listenFor != null) {
        // listenFor must be in range between between 5s to 30s
        assert(micOptions!.listenFor!.compareTo(Duration(seconds: 30)) < 0,
            "listenFor can not be greater than 30s");
        assert(micOptions!.listenFor!.compareTo(Duration(seconds: 3)) > 0,
            "listenFor can not be less than 3s");
      }
      MicOptions normalizedOptions = getNormalizedMicOptions();
      if (micOptions!.pauseFor != null) {
        assert(micOptions!.pauseFor!.compareTo(Duration(milliseconds: 100)) > 0,
            "pauseFor can not be less than 100ms");
        assert(
            micOptions!.pauseFor!.compareTo(normalizedOptions.listenFor!) < 0,
            "pauseFor can not be greater than listen for:" +
                normalizedOptions.listenFor.toString());
      }
      if (micOptions!.maximumWordsLimit != null) {
        assert(micOptions!.maximumWordsLimit! > 1,
            "maximumWordsLimit can not be less than 1");
        assert(micOptions!.maximumWordsLimit! < 30,
            "maximumWordsLimit can not be greater than 30");
      }
    }
  }

  @override
  void initState() {
    _subscription = speechToTextInstance!.stream.listen((recognitionEvent) {
      if (recognitionEvent.isListening != _isListening) {
        setState(() {
          _isListening = recognitionEvent.isListening;
        });
        if (recognitionEvent.isListening!) {
          _showMyDialog();
        }
        if (setStateDialog != null) {
          setStateDialog!(() {});
        }
      }
      if (recognitionEvent.eventType ==
          ste.SpeechRecognitionEventType.partialRecognitionEvent) {
        MicOptions micOptions = getNormalizedMicOptions();
        // Allow maximum 12 words
        if (recognitionEvent.isListening! &&
            _recognizedText.split(' ').length > micOptions.maximumWordsLimit!) {
          stop();
        } else {
          _recognizedText = recognitionEvent.recognitionResult!.recognizedWords;
        }
        if (setStateDialog != null) {
          setStateDialog!(() {});
        }
      }
      if (recognitionEvent.eventType ==
          ste.SpeechRecognitionEventType.finalRecognitionEvent) {
        _recognizedText = recognitionEvent.recognitionResult!.recognizedWords;

        if (setStateDialog != null) {
          setStateDialog!(() {});
        }
        Future.delayed(Duration(milliseconds: 200)).then((value) {
          if (dialogContext != null) {
            // close the dialog box
            Navigator.of(dialogContext!).pop();
            // call mic results
            onMicResults!(_recognizedText);
          }
        });
      }
    }, cancelOnError: true);

    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _showMyDialog() async {
    if (_isDialogActive) {
      return null;
    }
    _recognizedText = "";
    _isDialogActive = true;
    TextStyle textStyle = new TextStyle(
      fontSize: 18.0,
      height: 2,
      fontWeight: FontWeight.w400,
    );
    MicOptions micOptions = getNormalizedMicOptions();
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            dialogContext = context;
            setStateDialog = setState;
            return AlertDialog(
              content: IntrinsicHeight(
                child: Column(children: [
                  Container(
                      height: 120.0,
                      child: _isListening!
                          ? micOptions.micIconOn
                          : GestureDetector(
                              onTap: start,
                              child: micOptions.micIconOff,
                            )),
                  Container(
                    height: 110,
                    child: _isListening!
                        ? _recognizedText != ""
                            ? Text(_recognizedText,
                                style: textStyle, textAlign: TextAlign.center)
                            : Text('Listening',
                                style: textStyle, textAlign: TextAlign.center)
                        : _recognizedText == ""
                            ? Text('Did not hear. Try Again',
                                style: textStyle, textAlign: TextAlign.center)
                            : Text(_recognizedText,
                                style: textStyle, textAlign: TextAlign.center),
                  )
                ]),
              ),
            );
          },
        );
      },
    ).then((val) {
      _isDialogActive = false;
      dialogContext = null;
      setStateDialog = null;
    });
  }

  void start() async {
    bool isSpeechAvailable = _isSpeechAvailable;
    if (!isSpeechAvailable) {
      isSpeechAvailable = await speechToTextInstance!.initialize();
      setState(() {
        _isSpeechAvailable = isSpeechAvailable;
        _isSubscribed = true;
      });
    }
    if (isSpeechAvailable) {
      MicOptions micOptions = getNormalizedMicOptions();
      speechToTextInstance!.listen(
        listenFor: micOptions.listenFor,
        pauseFor: micOptions.pauseFor,
        localeId: micOptions.localeId,
        partialResults: micOptions.partialResults!,
      );
    }
  }

  void stop() async {
    speechToTextInstance!.stop();
  }

  MicOptions getNormalizedMicOptions() {
    MicOptions finalMicOptions = defaultMicOptions;
    if (micOptions != null) {
      if (micOptions!.listenFor != null) {
        finalMicOptions.listenFor = micOptions!.listenFor;
      }
      if (micOptions!.pauseFor != null) {
        finalMicOptions.pauseFor = micOptions!.pauseFor;
      }
      if (micOptions!.maximumWordsLimit != null) {
        finalMicOptions.maximumWordsLimit = micOptions!.maximumWordsLimit;
      }
      if (micOptions!.micIcon != null) {
        finalMicOptions.micIcon = micOptions!.micIcon;
      }
      if (micOptions!.micIconDenied != null) {
        finalMicOptions.micIconDenied = micOptions!.micIconDenied;
      }
      if (micOptions!.micIconOn != null) {
        finalMicOptions.micIconOn = micOptions!.micIconOn;
      }
      if (micOptions!.micIconOff != null) {
        finalMicOptions.micIconOff = micOptions!.micIconOff;
      }
      if (micOptions!.localeId != null) {
        finalMicOptions.localeId = micOptions!.localeId;
      }
      if (micOptions!.partialResults != null) {
        finalMicOptions.partialResults = micOptions!.partialResults;
      }
    }
    return finalMicOptions;
  }

  @override
  Widget build(BuildContext context) {
    MicOptions micOptions = getNormalizedMicOptions();
    return IconButton(
        icon: _isListening! || _isSpeechAvailable || !_isSubscribed
            ? micOptions.micIcon!
            : micOptions.micIconDenied!,
        onPressed: () async {
          if (!_isListening!) {
            onStart!();
            start();
          }
        });
  }
}

class _MicButton extends StatefulWidget {
  final void Function(String out)? onMicResults;
  final void Function()? onStart;
  final stp.SpeechToTextProvider? speechToTextInstance;
  final MicOptions? micOptions;

  _MicButton(this.speechToTextInstance,
      {this.onMicResults, this.onStart, this.micOptions});

  @override
  _MicButtonState createState() => _MicButtonState(speechToTextInstance,
      onMicResults: this.onMicResults,
      onStart: this.onStart,
      micOptions: this.micOptions);
}

/// [SearchWidgetConnector] represents a search widget that can be used to bind to different kinds of search UI widgets.
///
/// It uses the [SearchController] class to bind any UI widget to be able to query appbase.io declaratively. Some examples of components you can bind this with:
/// -   a category filter widget,
/// -   a search bar widget,
/// -   a price range widget,
/// -   a location filter widget,
/// -   a widget to render the search results.
///
class SearchWidgetConnector<S, ViewModel> extends StatelessWidget {
  /// Build a Widget using the [BuildContext] and [ViewModel]
  final ViewModelBuilder<ViewModel> builder;

  /// This property allows to define a list of properties of [SearchController] class which can trigger the re-build when any changes happen.
  ///
  /// For example, if `subscribeTo` is defined as `['results']` then it'll only update the UI when results property would change.
  final List<String>? subscribeTo;

  /// It can be used to prevent the default query execution at the time of initial build.
  ///
  /// Defaults to `true`.
  final bool? triggerQueryOnInit;

  /// It can be used to prevent state updates.
  ///
  /// Defaults to `true`. If set to `false` then no rebuild would be performed.
  final bool? shouldListenForChanges;

  /// If set to `false` then after dispose the component will not get removed from seachbase context i.e can actively participate in query generation.
  ///
  /// Defaults to `true`.
  final bool? destroyOnDispose;

  /// A unique identifier of the component, can be referenced in other widgets' `react` prop to reactively update data.
  final String id;

  /// Refers to an index of the Elasticsearch cluster.
  ///
  /// If not defined, then value will be inherited from [SearchBaseProvider].
  /// `Note:` Multiple indexes can be connected to Elasticsearch by specifying comma-separated index names.
  final String? index;

  /// URL for the Elasticsearch cluster.
  ///
  /// If not defined, then value will be inherited from [SearchBaseProvider].
  final String? url;

  /// Basic Auth credentials if required for authentication purposes.
  ///
  /// It should be a string of the format `username:password`. If you are using an appbase.io cluster, you will find credentials under the `Security > API credentials` section of the appbase.io dashboard.
  /// If you are not using an appbase.io cluster, credentials may not be necessary - although having open access to your Elasticsearch cluster is not recommended.
  /// If not defined, then value will be inherited from [SearchBaseProvider].
  final String? credentials;

  /// Set custom headers to be sent with each server request as key/value pairs.
  ///
  /// If not defined then value will be inherited from [SearchBaseProvider].
  final Map<String, String>? headers;

  /// It allows you to customize the analytics experience when appbase.io is used as a backend.
  ///
  /// If not defined then value will be inherited from [SearchBaseProvider].
  final AppbaseSettings? appbaseConfig;

  /// This property represents the type of the query which is defaults to [QueryType.search], valid values are [QueryType.search], [QueryType.term], [QueryType.range] & [QueryType.geo].
  ///
  /// You can read more [here](https://docs.appbase.io/docs/search/reactivesearch-api/implement#type-of-queries).
  final QueryType? type;

  /// It is useful for components whose data view should reactively update when on or more dependent components change their states.
  ///
  /// For example, a widget to display the results can depend on the search widget to filter the results.
  ///  -   **key** `string`
  ///      one of `and`, `or`, `not` defines the combining clause.
  ///      -   **and** clause implies that the results will be filtered by matches from **all** of the associated widget states.
  ///      -   **or** clause implies that the results will be filtered by matches from **at least one** of the associated widget states.
  ///      -   **not** clause implies that the results will be filtered by an **inverse** match of the associated widget states.
  ///  -   **value** `string or Array or Object`
  ///      -   `string` is used for specifying a single widget by its `id`.
  ///      -   `Array` is used for specifying multiple components by their `id`.
  ///      -   `Object` is used for nesting other key clauses.

  /// An example of a `react` clause where all three clauses are used and values are `Object`, `Array` and `string`.

  ///  ```dart
  /// {
  ///		'and': {
  ///			'or': ['CityComp', 'TopicComp'],
  ///			'not': 'BlacklistComp',
  ///		},
  ///	}
  /// ```

  /// Here, we are specifying that the results should update whenever one of the blacklist items is not present and simultaneously any one of the city or topics matches.
  final Map<String, dynamic>? react;

  /// Sets the query format, can be **or** or **and**.
  ///
  /// Defaults to **or**.
  ///
  /// -   **or** returns all the results matching **any** of the search query text's parameters. For example, searching for "bat man" with **or** will return all the results matching either "bat" or "man".
  /// -   On the other hand with **and**, only results matching both "bat" and "man" will be returned. It returns the results matching **all** of the search query text's parameters.
  final String? queryFormat;

  /// The index field(s) to be connected to the component’s UI view.
  ///
  /// It accepts an `List<String>` in addition to `<String>`, which is useful for searching across multiple fields with or without field weights.
  ///
  /// Field weights allow weighted search for the index fields. A higher number implies a higher relevance weight for the corresponding field in the search results.
  /// You can define the `dataField` property as a `List<Map>` of to set the field weights. The object must have the `field` and `weight` keys.
  /// For example,
  /// ```dart
  /// [
  ///   {
  ///     'field': 'original_title',
  ///     'weight': 1
  ///   },
  ///   {
  ///     'field': 'original_title.search',
  ///     'weight': 3
  ///   },
  /// ]
  /// ```
  final dynamic dataField;

  /// Index field mapped to the category value.
  final String? categoryField;

  /// This is the selected category value. It is used for informing the search result.
  final String? categoryValue;

  /// Sets the `nested` field path that allows an array of objects to be indexed in a way that can be queried independently of each other.
  ///
  /// Applicable only when dataField's mapping is of `nested` type.
  final String? nestedField;

  /// To define from which page to start the results, it is important to implement pagination.
  final int? from;

  /// Number of suggestions and results to fetch per request.
  final int? size;

  /// Sorts the results by either [SortType.asc], [SortType.desc] or [SortType.count] order.
  ///
  /// Please note that the [SortType.count] is only applicable for [QueryType.term] type of search widgets.
  final SortType? sortBy;

  /// Represents the value for a particular [QueryType].
  ///
  /// Depending on the query type, the value format would differ.
  /// You can refer to the different value formats over [here](https://docs.appbase.io/docs/search/reactivesearch-api/reference#value).
  final dynamic value;

  /// It enables you to get `DISTINCT` results (useful when you are dealing with sessions, events, and logs type data).
  ///
  /// It utilizes [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) which are newly introduced in ES v6 and offer vast performance benefits over a traditional terms aggregation.
  final String? aggregationField;

  /// To set the number of buckets to be returned by aggregations.
  ///
  /// > Note: This is a new feature and only available for appbase versions >= 7.41.0.
  final int? aggregationSize;

  /// This property can be used to implement the pagination for `aggregations`.
  ///
  /// We use the [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) of `Elasticsearch` to execute the aggregations' query,
  /// the response of composite aggregations includes a key named `after_key` which can be used to fetch the next set of aggregations for the same query.
  /// You can read more about the pagination for composite aggregations at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html#_pagination).
  final Map? after;

  /// If you have sparse data or documents or items not having the value in the specified field or mapping, then this prop enables you to show that data.
  final bool? includeNullValues;

  // It allows to define fields to be included in search results.
  final List<String>? includeFields;

  // It allows to define fields to be excluded in search results.
  final List<String>? excludeFields;

  /// Useful for showing the correct results for an incorrect search parameter by taking the fuzziness into account.
  ///
  /// For example, with a substitution of one character, `fox` can become `box`.
  /// Read more about it in the elastic search https://www.elastic.co/guide/en/elasticsearch/guide/current/fuzziness.html.
  final dynamic fuzziness;

  /// If set to `true`, then you can use special characters in the search query to enable the advanced search.
  ///
  /// Defaults to `false`.
  /// You can read more about this property at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-simple-query-string-query.html).
  final bool? searchOperators;

  /// To define whether highlighting should be enabled in the returned results.
  ///
  /// Defaults to `false`.
  final bool? highlight;

  /// If highlighting is enabled, this property allows specifying the fields which should be returned with the matching highlights.
  ///
  /// When not specified, it defaults to applying highlights on the field(s) specified in the **dataField** property.
  /// It can be of type `String` or `List<String>`.
  final dynamic highlightField;

  /// It can be used to set the custom highlight settings.
  ///
  /// You can read the `Elasticsearch` docs for the highlight options at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-highlighting.html).
  final Map? customHighlight;

  /// To set the histogram bar interval for [QueryType.range] type of widgets, applicable when [aggregations](/docs/search/reactivesearch-api/reference/#aggregations) value is set to `["histogram"]`.
  ///
  /// Defaults to `Math.ceil((range.end - range.start) / 100) || 1`.
  final int? interval;

  /// It helps you to utilize the built-in aggregations for [QueryType.range] type of widgets directly, valid values are:
  /// -   `max`: to retrieve the maximum value for a `dataField`,
  /// -   `min`: to retrieve the minimum value for a `dataField`,
  /// -   `histogram`: to retrieve the histogram aggregations for a particular `interval`
  final List<String>? aggregations;

  /// When set to `true` then it also retrieves the aggregations for missing fields.
  ///
  /// Defaults to `false`.
  final bool? showMissing;

  /// It allows you to specify a custom label to show when [showMissing](/docs/search/reactivesearch-api/reference/#showmissing) is set to `true`.
  ///
  /// Defaults to `N/A`.
  final String? missingLabel;

  /// It is a callback function that takes the [SearchController] instance as parameter and **returns** the data query to be applied to the source component, as defined in Elasticsearch Query DSL, which doesn't get leaked to other components.
  ///
  /// In simple words, `defaultQuery` is used with data-driven components to impact their own data.
  /// It is meant to modify the default query which is used by a component to render the UI.
  ///
  ///  Some of the valid use-cases are:
  ///
  ///  -   To modify the query to render the `suggestions` or `results` in [QueryType.search] type of components.
  ///  -   To modify the `aggregations` in [QueryType.term] type of components.
  ///
  ///  For example, in a [QueryType.term] type of component showing a list of cities, you may only want to render cities belonging to `India`.
  ///
  ///```dart
  /// Map (SearchController searchController) => ({
  ///   		'query': {
  ///   			'terms': {
  ///   				'country': ['India'],
  ///   			},
  ///   		},
  ///   	}
  ///   )
  ///```
  final Map Function(SearchController searchController)? defaultQuery;

  /// It takes [SearchController] instance as parameter and **returns** the query to be applied to the dependent widgets by `react` prop, as defined in Elasticsearch Query DSL.
  ///
  /// For example, the following example has two components **search-widget**(to render the suggestions) and **result-widget**(to render the results).
  /// The **result-widget** depends on the **search-widget** to update the results based on the selected suggestion.
  /// The **search-widget** has the `customQuery` prop defined that will not affect the query for suggestions(that is how `customQuery` is different from `defaultQuery`)
  /// but it'll affect the query for **result-widget** because of the `react` dependency on **search-widget**.
  ///
  /// ```dart
  /// SearchWidgetConnector(
  ///   id: "search-widget",
  ///   dataField: ["original_title", "original_title.search"],
  ///   customQuery: (SearchController searchController) => ({
  ///     'timeout': '1s',
  ///      'query': {
  ///       'match_phrase_prefix': {
  ///         'fieldName': {
  ///           'query': 'hello world',
  ///           'max_expansions': 10,
  ///         },
  ///       },
  ///     },
  ///   })
  /// )
  ///
  /// SearchWidgetConnector(
  ///   id: "result-widget",
  ///   dataField: "original_title",
  ///   react: {
  ///    'and': ['search-component']
  ///   }
  /// )
  /// ```
  final Map Function(SearchController searchController)? customQuery;

  /// This property can be used to control (enable/disable) the synonyms behavior for a particular query.
  ///
  /// Defaults to `true`, if set to `false` then fields having `.synonyms` suffix will not affect the query.
  final bool? enableSynonyms;

  /// This property allows you to add a new property in the list with a particular value in such a way that
  /// when selected i.e `value` is similar/contains to that label(`selectAllLabel`) then [QueryType.term] query will make sure that
  /// the `field` exists in the `results`.
  final String? selectAllLabel;

  /// This property allows you to implement the `pagination` for [QueryType.term] type of queries.
  ///
  /// If `pagination` is set to `true` then appbase will use the [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) of Elasticsearch
  /// instead of [terms aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html).
  final bool? pagination;

  /// If set to `true` than it allows you to create a complex search that includes wildcard characters, searches across multiple fields, and more.
  ///
  /// Defaults to `false`.
  /// Read more about it [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html).
  final bool? queryString;

  /// It can be useful to curate search suggestions based on actual search queries that your users are making.
  ///
  /// Defaults to `false`. You can read more about it over [here](https://docs.appbase.io/docs/analytics/popular-suggestions).
  final bool? enablePopularSuggestions;

  /// It can be used to configure the size of popular suggestions.
  ///
  /// The default size is `5`.
  final int? maxPopularSuggestions;

  /// To display one suggestion per document.
  ///
  /// If set to `false` multiple suggestions may show up for the same document as the searched value might appear in multiple fields of the same document,
  /// this is true only if you have configured multiple fields in `dataField` prop. Defaults to `true`.
  ///
  ///  **Example** if you have `showDistinctSuggestions` is set to `false` and have the following configurations
  ///
  ///  ```dart
  ///  // Your document:
  ///  {
  ///  	"name": "Warn",
  ///  	"address": "Washington"
  ///  }
  ///  // SearchWidgetConnector:
  ///  dataField: ['name', 'address']
  ///
  ///  // Search Query:
  ///  "wa"
  ///  ```

  ///  Then there will be 2 suggestions from the same document
  ///  as we have the search term present in both the fields
  ///  specified in `dataField`.
  ///
  ///  ```
  ///  Warn
  ///  Washington
  ///  ```
  final bool? showDistinctSuggestions;

  /// It set to `true` then it preserves the previously loaded results data that can be used to persist pagination or implement infinite loading.
  final bool? preserveResults;

  /// When set to `true`, the controller's value would get cleared whenever the query of a watcher controller(which is set via react prop) changes.
  ///
  /// The default value is `false`
  final bool clearOnQueryChange;

  /// A list of map to pre-populate results with static data.
  ///
  /// Data must be in form of Elasticsearch response.
  final List<Map>? results;

  // callbacks

  /// Enables transformation of network request before execution.
  ///
  /// This function will give you the request object as the param and expect an updated request in return, for execution.
  /// For example, we will add the `credentials` property in the request using `transformRequest`.
  ///
  /// ```dart
  /// Future (Map request) =>
  ///      Future.value({
  ///          ...request,
  ///          'credentials': 'include',
  ///      })
  ///  }
  /// ```
  final TransformRequest? transformRequest;

  /// Enables transformation of search network response before rendering them.
  ///
  /// It is an asynchronous function which will accept an Elasticsearch response object as param and is expected to return an updated response as the return value.
  /// For example:
  /// ```dart
  /// Future (Map elasticsearchResponse) async {
  ///	 final ids = elasticsearchResponse['hits']['hits'].map(item => item._id);
  ///	 final extraInformation = await getExtraInformation(ids);
  ///	 final hits = elasticsearchResponse['hits']['hits'].map(item => {
  ///		final extraInformationItem = extraInformation.find(
  ///			otherItem => otherItem._id === item._id,
  ///		);
  ///		return Future.value({
  ///			...item,
  ///			...extraInformationItem,
  ///		};
  ///	}));
  ///
  ///	return Future.value({
  ///		...elasticsearchResponse,
  ///		'hits': {
  ///			...elasticsearchResponse.hits,
  ///			hits,
  ///		},
  ///	});
  ///}
  /// ```
  final TransformResponse? transformResponse;

  /// This prop returns only the distinct value documents for the specified field.
  /// It is equivalent to the DISTINCT clause in SQL. It internally uses the collapse feature of Elasticsearch.
  /// You can read more about it over here - https://www.elastic.co/guide/en/elasticsearch/reference/current/collapse-search-results.html
  final String? distinctField;

  /// This prop allows specifying additional options to the distinctField prop.
  /// Using the allowed DSL, one can specify how to return K distinct values (default value of K=1),
  /// sort them by a specific order, or return a second level of distinct values.
  /// distinctFieldConfig object corresponds to the inner_hits key's DSL.
  /// You can read more about it over here - https://www.elastic.co/guide/en/elasticsearch/reference/current/collapse-search-results.html
  ///
  /// For example,
  /// ```dart
  /// SearchBox(
  ///   ...
  ///   distinctField: 'authors.keyword',
  ///   distinctFieldConfig: {
  ///     'inner_hits': {
  ///       'name': 'other_books',
  ///       'size': 5,
  ///       'sort': [
  ///         {'timestamp': 'asc'}
  ///       ],
  ///     },
  ///   'max_concurrent_group_searches': 4, },
  /// )
  /// ```
  final Map? distinctFieldConfig;

  /* ---- callbacks to create the side effects while querying ----- */

  /// It is a callback function which accepts component's future **value** as a
  /// parameter and **returns** a [Future].
  ///
  /// It is called every-time before a component's value changes.
  /// The promise, if and when resolved, triggers the execution of the component's query and if rejected, kills the query execution.
  /// This method can act as a gatekeeper for query execution, since it only executes the query after the provided promise has been resolved.
  ///
  /// For example:
  /// ```dart
  /// Future (value) {
  ///   // called before the value is set
  ///   // returns a [Future]
  ///   // update state or component props
  ///   return Future.value(value);
  ///   // or Future.error()
  /// }
  /// ```
  final Future Function(dynamic value)? beforeValueChange;

  /* ------------- change events -------------------------------- */

  /// It is called every-time the widget's value changes.
  ///
  /// This property is handy in cases where you want to generate a side-effect on value selection.
  /// For example: You want to show a pop-up modal with the valid discount coupon code when a user searches for a product in a [SearchBox].
  final void Function(dynamic next, {dynamic prev})? onValueChange;

  /// It can be used to listen for the `results` changes.
  final void Function(List<Map> next, {List<Map> prev})? onResults;

  /// It can be used to listen for the `aggregationData` property changes.
  final void Function(List<Map> next, {List<Map> prev})? onAggregationData;

  /// It gets triggered in case of an error occurs while fetching results.
  final void Function(dynamic error)? onError;

  /// It can be used to listen for the request status changes.
  final void Function(String next, {String prev})? onRequestStatusChange;

  /// It is a callback function which accepts widget's **prevQuery** and **nextQuery** as parameters.
  ///
  /// It is called everytime the widget's query changes.
  /// This property is handy in cases where you want to generate a side-effect whenever the widget's query would change.
  final void Function(Map next, {Map prev})? onQueryChange;

  SearchWidgetConnector({
    Key? key,
    required this.builder,
    required this.id,
    this.subscribeTo,
    this.triggerQueryOnInit,
    this.shouldListenForChanges,
    this.destroyOnDispose,
    // properties to configure search component
    this.credentials,
    this.index,
    this.url,
    this.appbaseConfig,
    this.transformRequest,
    this.transformResponse,
    this.headers,
    this.type,
    this.react,
    this.queryFormat,
    this.dataField,
    this.categoryField,
    this.categoryValue,
    this.nestedField,
    this.from,
    this.size,
    this.sortBy,
    this.aggregationField,
    this.aggregationSize,
    this.after,
    this.includeNullValues,
    this.includeFields,
    this.excludeFields,
    this.fuzziness,
    this.searchOperators,
    this.highlight,
    this.highlightField,
    this.customHighlight,
    this.interval,
    this.aggregations,
    this.missingLabel,
    this.showMissing,
    this.enableSynonyms,
    this.selectAllLabel,
    this.pagination,
    this.queryString,
    this.defaultQuery,
    this.customQuery,
    this.beforeValueChange,
    this.onValueChange,
    this.onResults,
    this.onAggregationData,
    this.onError,
    this.onRequestStatusChange,
    this.onQueryChange,
    this.enablePopularSuggestions,
    this.maxPopularSuggestions,
    this.showDistinctSuggestions,
    this.preserveResults,
    this.clearOnQueryChange = false,
    this.value,
    this.results,
    this.distinctField,
    this.distinctFieldConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SearchBaseConnector(
        child: (searchbase) => _SearchWidgetListener(
              id: id,
              searchbase: searchbase,
              builder: builder,
              subscribeTo: subscribeTo,
              triggerQueryOnInit: triggerQueryOnInit,
              shouldListenForChanges: shouldListenForChanges,
              destroyOnDispose: destroyOnDispose,
              // properties to configure search component
              credentials: credentials,
              index: index,
              url: url,
              appbaseConfig: appbaseConfig,
              transformRequest: transformRequest,
              transformResponse: transformResponse,
              headers: headers,
              type: type,
              react: react,
              queryFormat: queryFormat,
              dataField: dataField,
              categoryField: categoryField,
              categoryValue: categoryValue,
              nestedField: nestedField,
              from: from,
              size: size,
              sortBy: sortBy,
              aggregationField: aggregationField,
              aggregationSize: aggregationSize,
              after: after,
              includeNullValues: includeNullValues,
              includeFields: includeFields,
              excludeFields: excludeFields,
              fuzziness: fuzziness,
              searchOperators: searchOperators,
              highlight: highlight,
              highlightField: highlightField,
              customHighlight: customHighlight,
              interval: interval,
              aggregations: aggregations,
              missingLabel: missingLabel,
              showMissing: showMissing,
              enableSynonyms: enableSynonyms,
              selectAllLabel: selectAllLabel,
              pagination: pagination,
              queryString: queryString,
              defaultQuery: defaultQuery,
              customQuery: customQuery,
              beforeValueChange: beforeValueChange,
              onValueChange: onValueChange,
              onResults: onResults,
              onAggregationData: onAggregationData,
              onError: onError,
              onRequestStatusChange: onRequestStatusChange,
              onQueryChange: onQueryChange,
              enablePopularSuggestions: enablePopularSuggestions,
              maxPopularSuggestions: maxPopularSuggestions,
              showDistinctSuggestions: showDistinctSuggestions,
              preserveResults: preserveResults,
              clearOnQueryChange: clearOnQueryChange,
              value: value,
              results: results,
              distinctField: distinctField,
              distinctFieldConfig: distinctFieldConfig,
            ));
  }
}

/// [SearchBox] offers a performance focused searchbox UI widget to query and display results from your Elasticsearch cluster.
///
/// It extends the [SearchDelegate] class which means that to display the [SearchBox] UI you have to invoke the **showSearch** method with [SearchBox] as delegate.
class SearchBox<S, ViewModel> extends SearchDelegate<String?> {
  // Properties to configure search component

  /// A unique identifier of the component, can be referenced in other widgets' `react` prop to reactively update data.
  final String id;

  /// Refers to an index of the Elasticsearch cluster.
  ///
  /// If not defined, then value will be inherited from [SearchBaseProvider].
  /// `Note:` Multiple indexes can be connected to Elasticsearch by specifying comma-separated index names.
  final String? index;

  /// URL for the Elasticsearch cluster.
  ///
  /// If not defined, then value will be inherited from [SearchBaseProvider].
  final String? url;

  /// Basic Auth credentials if required for authentication purposes.
  ///
  /// It should be a string of the format `username:password`. If you are using an appbase.io cluster, you will find credentials under the `Security > API credentials` section of the appbase.io dashboard.
  /// If you are not using an appbase.io cluster, credentials may not be necessary - although having open access to your Elasticsearch cluster is not recommended.
  /// If not defined, then value will be inherited from [SearchBaseProvider].
  final String? credentials;

  /// Set custom headers to be sent with each server request as key/value pairs.
  ///
  /// If not defined then value will be inherited from [SearchBaseProvider].
  final Map<String, String>? headers;

  /// It allows you to customize the analytics experience when appbase.io is used as a backend.
  ///
  /// If not defined then value will be inherited from [SearchBaseProvider].
  final AppbaseSettings? appbaseConfig;

  /// It is useful for components whose data view should reactively update when on or more dependent components change their states.
  ///
  /// For example, a widget to display the results can depend on the search widget to filter the results.
  ///  -   **key** `string`
  ///      one of `and`, `or`, `not` defines the combining clause.
  ///      -   **and** clause implies that the results will be filtered by matches from **all** of the associated widget states.
  ///      -   **or** clause implies that the results will be filtered by matches from **at least one** of the associated widget states.
  ///      -   **not** clause implies that the results will be filtered by an **inverse** match of the associated widget states.
  ///  -   **value** `string or Array or Object`
  ///      -   `string` is used for specifying a single widget by its `id`.
  ///      -   `Array` is used for specifying multiple components by their `id`.
  ///      -   `Object` is used for nesting other key clauses.

  /// An example of a `react` clause where all three clauses are used and values are `Object`, `Array` and `string`.

  ///  ```dart
  /// {
  ///		'and': {
  ///			'or': ['CityComp', 'TopicComp'],
  ///			'not': 'BlacklistComp',
  ///		},
  ///	}
  /// ```

  /// Here, we are specifying that the results should update whenever one of the blacklist items is not present and simultaneously any one of the city or topics matches.
  final Map<String, dynamic>? react;

  /// Sets the query format, can be **or** or **and**.
  ///
  /// Defaults to **or**.
  ///
  /// -   **or** returns all the results matching **any** of the search query text's parameters. For example, searching for "bat man" with **or** will return all the results matching either "bat" or "man".
  /// -   On the other hand with **and**, only results matching both "bat" and "man" will be returned. It returns the results matching **all** of the search query text's parameters.
  final String? queryFormat;

  /// The index field(s) to be connected to the component’s UI view.
  ///
  /// It accepts an `List<String>` in addition to `<String>`, which is useful for searching across multiple fields with or without field weights.
  ///
  /// Field weights allow weighted search for the index fields. A higher number implies a higher relevance weight for the corresponding field in the search results.
  /// You can define the `dataField` property as a `List<Map>` of to set the field weights. The object must have the `field` and `weight` keys.
  /// For example,
  /// ```dart
  /// [
  ///   {
  ///     'field': 'original_title',
  ///     'weight': 1
  ///   },
  ///   {
  ///     'field': 'original_title.search',
  ///     'weight': 3
  ///   },
  /// ]
  /// ```
  final dynamic dataField;

  /// Index field mapped to the category value.
  final String? categoryField;

  /// This is the selected category value. It is used for informing the search result.
  final String? categoryValue;

  /// Sets the `nested` field path that allows an array of objects to be indexed in a way that can be queried independently of each other.
  ///
  /// Applicable only when dataField's mapping is of `nested` type.
  final String? nestedField;

  /// To define from which page to start the results, it is important to implement pagination.
  final int? from;

  /// Number of suggestions and results to fetch per request.
  final int? size;

  /// Sorts the results by either [SortType.asc], [SortType.desc] or [SortType.count] order.
  ///
  /// Please note that the [SortType.count] is only applicable for [QueryType.term] type of search widgets.
  final SortType? sortBy;

  /// It enables you to get `DISTINCT` results (useful when you are dealing with sessions, events, and logs type data).
  ///
  /// It utilizes [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) which are newly introduced in ES v6 and offer vast performance benefits over a traditional terms aggregation.
  final String? aggregationField;

  /// To set the number of buckets to be returned by aggregations.
  ///
  /// > Note: This is a new feature and only available for appbase versions >= 7.41.0.
  final int? aggregationSize;

  /// This property can be used to implement the pagination for `aggregations`.
  ///
  /// We use the [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) of `Elasticsearch` to execute the aggregations' query,
  /// the response of composite aggregations includes a key named `after_key` which can be used to fetch the next set of aggregations for the same query.
  /// You can read more about the pagination for composite aggregations at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html#_pagination).
  final Map? after;

  /// If you have sparse data or documents or items not having the value in the specified field or mapping, then this prop enables you to show that data.
  final bool? includeNullValues;

  // It allows to define fields to be included in search results.
  final List<String>? includeFields;

  // It allows to define fields to be excluded in search results.
  final List<String>? excludeFields;

  /// Useful for showing the correct results for an incorrect search parameter by taking the fuzziness into account.
  ///
  /// For example, with a substitution of one character, `fox` can become `box`.
  /// Read more about it in the elastic search https://www.elastic.co/guide/en/elasticsearch/guide/current/fuzziness.html.
  final dynamic fuzziness;

  /// If set to `true`, then you can use special characters in the search query to enable the advanced search.
  ///
  /// Defaults to `false`.
  /// You can read more about this property at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-simple-query-string-query.html).
  final bool? searchOperators;

  /// To define whether highlighting should be enabled in the returned results.
  ///
  /// Defaults to `false`.
  final bool? highlight;

  /// If highlighting is enabled, this property allows specifying the fields which should be returned with the matching highlights.
  ///
  /// When not specified, it defaults to applying highlights on the field(s) specified in the **dataField** property.
  /// It can be of type `String` or `List<String>`.
  final dynamic highlightField;

  /// It can be used to set the custom highlight settings.
  ///
  /// You can read the `Elasticsearch` docs for the highlight options at [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-highlighting.html).
  final Map? customHighlight;

  /// To set the histogram bar interval for [QueryType.range] type of widgets, applicable when [aggregations](/docs/search/reactivesearch-api/reference/#aggregations) value is set to `["histogram"]`.
  ///
  /// Defaults to `Math.ceil((range.end - range.start) / 100) || 1`.
  final int? interval;

  /// It helps you to utilize the built-in aggregations for [QueryType.range] type of widgets directly, valid values are:
  /// -   `max`: to retrieve the maximum value for a `dataField`,
  /// -   `min`: to retrieve the minimum value for a `dataField`,
  /// -   `histogram`: to retrieve the histogram aggregations for a particular `interval`
  final List<String>? aggregations;

  /// When set to `true` then it also retrieves the aggregations for missing fields.
  ///
  /// Defaults to `false`.
  final bool? showMissing;

  /// It allows you to specify a custom label to show when [showMissing](/docs/search/reactivesearch-api/reference/#showmissing) is set to `true`.
  ///
  /// Defaults to `N/A`.
  final String? missingLabel;

  /// It is a callback function that takes the [SearchController] instance as parameter and **returns** the data query to be applied to the source component, as defined in Elasticsearch Query DSL, which doesn't get leaked to other components.
  ///
  /// In simple words, `defaultQuery` is used with data-driven components to impact their own data.
  /// It is meant to modify the default query which is used by a component to render the UI.
  ///
  ///  Some of the valid use-cases are:
  ///
  ///  -   To modify the query to render the `suggestions` or `results` in [QueryType.search] type of components.
  ///  -   To modify the `aggregations` in [QueryType.term] type of components.
  ///
  ///  For example, in a [QueryType.term] type of component showing a list of cities, you may only want to render cities belonging to `India`.
  ///
  ///```dart
  /// Map (SearchController searchController) => ({
  ///   		'query': {
  ///   			'terms': {
  ///   				'country': ['India'],
  ///   			},
  ///   		},
  ///   	}
  ///   )
  ///```
  final Map Function(SearchController searchController)? defaultQuery;

  /// It takes [SearchController] instance as parameter and **returns** the query to be applied to the dependent widgets by `react` prop, as defined in Elasticsearch Query DSL.
  ///
  /// For example, the following example has two components **search-widget**(to render the suggestions) and **result-widget**(to render the results).
  /// The **result-widget** depends on the **search-widget** to update the results based on the selected suggestion.
  /// The **search-widget** has the `customQuery` prop defined that will not affect the query for suggestions(that is how `customQuery` is different from `defaultQuery`)
  /// but it'll affect the query for **result-widget** because of the `react` dependency on **search-widget**.
  ///
  /// ```dart
  /// SearchWidgetConnector(
  ///   id: "search-widget",
  ///   dataField: ["original_title", "original_title.search"],
  ///   customQuery: (SearchController searchController) => ({
  ///     'timeout': '1s',
  ///      'query': {
  ///       'match_phrase_prefix': {
  ///         'fieldName': {
  ///           'query': 'hello world',
  ///           'max_expansions': 10,
  ///         },
  ///       },
  ///     },
  ///   })
  /// )
  ///
  /// SearchWidgetConnector(
  ///   id: "result-widget",
  ///   dataField: "original_title",
  ///   react: {
  ///    'and': ['search-component']
  ///   }
  /// )
  /// ```
  final Map Function(SearchController searchController)? customQuery;

  /// This property can be used to control (enable/disable) the synonyms behavior for a particular query.
  ///
  /// Defaults to `true`, if set to `false` then fields having `.synonyms` suffix will not affect the query.
  final bool? enableSynonyms;

  /// This property allows you to add a new property in the list with a particular value in such a way that
  /// when selected i.e `value` is similar/contains to that label(`selectAllLabel`) then [QueryType.term] query will make sure that
  /// the `field` exists in the `results`.
  final String? selectAllLabel;

  /// This property allows you to implement the `pagination` for [QueryType.term] type of queries.
  ///
  /// If `pagination` is set to `true` then appbase will use the [composite aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-composite-aggregation.html) of Elasticsearch
  /// instead of [terms aggregations](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html).
  final bool? pagination;

  /// If set to `true` than it allows you to create a complex search that includes wildcard characters, searches across multiple fields, and more.
  ///
  /// Defaults to `false`.
  /// Read more about it [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-query-string-query.html).
  final bool? queryString;

  /// It can be useful to curate search suggestions based on actual search queries that your users are making.
  ///
  /// Defaults to `false`. You can read more about it over [here](https://docs.appbase.io/docs/analytics/popular-suggestions).
  final bool? enablePopularSuggestions;

  /// It can be used to configure the size of popular suggestions.
  ///
  /// The default size is `5`.
  final int? maxPopularSuggestions;

  /// To display one suggestion per document.
  ///
  /// If set to `false` multiple suggestions may show up for the same document as the searched value might appear in multiple fields of the same document,
  /// this is true only if you have configured multiple fields in `dataField` prop. Defaults to `true`.
  ///
  ///  **Example** if you have `showDistinctSuggestions` is set to `false` and have the following configurations
  ///
  ///  ```dart
  ///  // Your document:
  ///  {
  ///  	"name": "Warn",
  ///  	"address": "Washington"
  ///  }
  ///  // SearchWidgetConnector:
  ///  dataField: ['name', 'address']
  ///
  ///  // Search Query:
  ///  "wa"
  ///  ```

  ///  Then there will be 2 suggestions from the same document
  ///  as we have the search term present in both the fields
  ///  specified in `dataField`.
  ///
  ///  ```
  ///  Warn
  ///  Washington
  ///  ```
  final bool showDistinctSuggestions;

  /// It set to `true` then it preserves the previously loaded results data that can be used to persist pagination or implement infinite loading.
  final bool? /*?*/ preserveResults;

  /// When set to `true`, the dependent controller's (which is set via react prop) value would get cleared whenever the query changes.
  ///
  /// The default value is `false`
  final bool clearOnQueryChange;

  // callbacks

  /// Enables transformation of network request before execution.
  ///
  /// This function will give you the request object as the param and expect an updated request in return, for execution.
  /// For example, we will add the `credentials` property in the request using `transformRequest`.
  ///
  /// ```dart
  /// Future (Map request) =>
  ///      Future.value({
  ///          ...request,
  ///          'credentials': 'include',
  ///      })
  ///  }
  /// ```
  final TransformRequest? transformRequest;

  /// Enables transformation of search network response before rendering them.
  ///
  /// It is an asynchronous function which will accept an Elasticsearch response object as param and is expected to return an updated response as the return value.
  /// For example:
  /// ```dart
  /// Future (Map elasticsearchResponse) async {
  ///	 final ids = elasticsearchResponse['hits']['hits'].map(item => item._id);
  ///	 final extraInformation = await getExtraInformation(ids);
  ///	 final hits = elasticsearchResponse['hits']['hits'].map(item => {
  ///		final extraInformationItem = extraInformation.find(
  ///			otherItem => otherItem._id === item._id,
  ///		);
  ///		return Future.value({
  ///			...item,
  ///			...extraInformationItem,
  ///		};
  ///	}));
  ///
  ///	return Future.value({
  ///		...elasticsearchResponse,
  ///		'hits': {
  ///			...elasticsearchResponse.hits,
  ///			hits,
  ///		},
  ///	});
  ///}
  /// ```
  final TransformResponse? transformResponse;

  /// A list of map to pre-populate results with static data.
  ///
  /// Data must be in form of Elasticsearch response.
  final List<Map>? results;

  /// This prop returns only the distinct value documents for the specified field.
  /// It is equivalent to the DISTINCT clause in SQL. It internally uses the collapse feature of Elasticsearch.
  /// You can read more about it over here - https://www.elastic.co/guide/en/elasticsearch/reference/current/collapse-search-results.html
  final String? distinctField;

  /// This prop allows specifying additional options to the distinctField prop.
  /// Using the allowed DSL, one can specify how to return K distinct values (default value of K=1),
  /// sort them by a specific order, or return a second level of distinct values.
  /// distinctFieldConfig object corresponds to the inner_hits key's DSL.
  /// You can read more about it over here - https://www.elastic.co/guide/en/elasticsearch/reference/current/collapse-search-results.html
  ///
  /// For example,
  /// ```dart
  /// SearchBox(
  ///   ...
  ///   distinctField: 'authors.keyword',
  ///   distinctFieldConfig: {
  ///     'inner_hits': {
  ///       'name': 'other_books',
  ///       'size': 5,
  ///       'sort': [
  ///         {'timestamp': 'asc'}
  ///       ],
  ///     },
  ///   'max_concurrent_group_searches': 4, },
  /// )
  /// ```
  final Map? distinctFieldConfig;

  /* ---- callbacks to create the side effects while querying ----- */

  /// It is a callback function which accepts component's future **value** as a
  /// parameter and **returns** a [Future].
  ///
  /// It is called every-time before a component's value changes.
  /// The promise, if and when resolved, triggers the execution of the component's query and if rejected, kills the query execution.
  /// This method can act as a gatekeeper for query execution, since it only executes the query after the provided promise has been resolved.
  ///
  /// For example:
  /// ```dart
  /// Future (value) {
  ///   // called before the value is set
  ///   // returns a [Future]
  ///   // update state or component props
  ///   return Future.value(value);
  ///   // or Future.error()
  /// }
  /// ```
  final Future Function(dynamic value)? beforeValueChange;

  /* ------------- change events -------------------------------- */

  /// It is called every-time the widget's value changes.
  ///
  /// This property is handy in cases where you want to generate a side-effect on value selection.
  /// For example: You want to show a pop-up modal with the valid discount coupon code when a user searches for a product in a [SearchBox].
  final void Function(dynamic next, {dynamic prev})? onValueChange;

  /// It can be used to listen for the `results` changes.
  final void Function(List<Map> next, {List<Map> prev})? onResults;

  /// It can be used to listen for the `aggregationData` property changes.
  final void Function(List<Map> next, {List<Map> prev})? onAggregationData;

  /// It gets triggered in case of an error occurs while fetching results.
  final void Function(dynamic error)? onError;

  /// It can be used to listen for the request status changes.
  final void Function(String next, {String prev})? onRequestStatusChange;

  /// It is a callback function which accepts widget's **prevQuery** and **nextQuery** as parameters.
  ///
  /// It is called everytime the widget's query changes.
  /// This property is handy in cases where you want to generate a side-effect whenever the widget's query would change.
  final void Function(Map next, {Map? prev})? onQueryChange;

  // SearchBox specific properties

  /// If set to `true` then users will see the top recent searches as the default suggestions.
  ///
  /// Defaults to `false`. Appbase.io recommends defining a unique id for each user to personalize the recent searches.
  /// > Note: Please note that this feature only works when `recordAnalytics` is set to `true` in `appbaseConfig`.
  final bool enableRecentSearches;

  /// This property allows you to enable the auto-fill behavior for suggestions.
  ///
  /// Defaults to `true`. It helps users to select a suggestion without applying the search which further refines the auto-suggestions i.e minimizes the number of taps or scrolls that the user has to perform before finding the result.
  final bool showAutoFill;

  /// It can be used to render the custom UI for suggestion list item.
  final Widget Function(Suggestion suggestion, Function handleTap)?
      buildSuggestionItem;

  /// This property allows to enable the voice search.
  ///
  /// Flutter searchbox uses the [speech_to_text](https://pub.dev/packages/speech_to_text) library to integrate the voice search.
  /// [speech_to_text](https://pub.dev/packages/speech_to_text) recommends to create a global instance of the `SpeechToTextProvider` class so we allow to pass an existing/new instance to [SearchBox] widget.
  /// For example,
  /// ```
  /// import 'package:speech_to_text/speech_to_text.dart' as stt;
  /// import 'package:speech_to_text/speech_to_text_provider.dart' as stp;
  ///
  /// // Create the instance at top of your application.
  /// final stp.SpeechToTextProvider speechToTextInstance =
  /// stp.SpeechToTextProvider(stt.SpeechToText());
  ///
  /// // Pass it like other properties
  /// SearchBox(
  ///   speechToTextInstance: speechToTextInstance
  /// )
  ///
  /// ```
  final stp.SpeechToTextProvider? speechToTextInstance;

  /// To customize the mic settings if voice search is enabled
  final MicOptions? micOptions;

  /// [customActions] allows to define the additional actions at the right of search bar.
  ///
  /// For an example,
  /// - a custom mic icon to handle voice search,
  /// - a search icon to perform search action etc.
  List<Widget>? customActions;

  SearchBox(
      {Key? key,
      required this.id,
      // properties to configure search component
      this.credentials,
      this.index,
      this.url,
      this.appbaseConfig,
      this.transformRequest,
      this.transformResponse,
      this.headers,
      this.react,
      this.queryFormat,
      this.dataField,
      this.categoryField,
      this.categoryValue,
      this.nestedField,
      this.from,
      this.size,
      this.sortBy,
      this.aggregationField,
      this.aggregationSize,
      this.after,
      this.includeNullValues,
      this.includeFields,
      this.excludeFields,
      this.fuzziness,
      this.searchOperators,
      this.highlight,
      this.highlightField,
      this.customHighlight,
      this.interval,
      this.aggregations,
      this.missingLabel,
      this.showMissing,
      this.enableSynonyms,
      this.selectAllLabel,
      this.pagination,
      this.queryString,
      this.defaultQuery,
      this.customQuery,
      this.beforeValueChange,
      this.onValueChange,
      this.onResults,
      this.onAggregationData,
      this.onError,
      this.onRequestStatusChange,
      this.onQueryChange,
      this.enablePopularSuggestions,
      this.maxPopularSuggestions,
      this.showDistinctSuggestions = true,
      this.preserveResults,
      this.clearOnQueryChange = true,
      this.distinctField,
      this.distinctFieldConfig,
      this.results,
      // searchbox specific properties
      this.enableRecentSearches = false,
      this.showAutoFill = false,
      // to customize ui
      this.buildSuggestionItem,
      // voice search
      this.speechToTextInstance,
      this.micOptions,
      // custom actions
      this.customActions});

  @override
  List<Widget> buildActions(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (this.aggregationField != null) {
        debugPrint(
            'Warning(SearchBox): The `aggregationField` prop has been marked as deprecated, please use the `distinctField` prop instead.');
      }
    });
    return [
      ...customActions != null ? customActions! : [],
      speechToTextInstance != null
          ? _MicButton(speechToTextInstance, micOptions: micOptions,
              onStart: () {
              query = "";
            }, onMicResults: (String output) {
              if (output != "") {
                SearchController? component =
                    SearchBaseProvider.of(context).getSearchWidget(id);
                // clear value
                if (component != null) {
                  component.setValue(output,
                      options: Options(
                          triggerCustomQuery: true,
                          triggerDefaultQuery: true,
                          stateChanges: false));
                  query = output;

                  Future.delayed(Duration(milliseconds: 700)).then((value) {
                    close(context, null);
                  });
                }
              }
            })
          : Container(),
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            SearchController? component =
                SearchBaseProvider.of(context).getSearchWidget(id);
            // clear value
            if (component != null) {
              component.setValue('',
                  options: Options(
                      triggerCustomQuery: true, triggerDefaultQuery: true));
            }
            query = '';
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      SearchController? component =
          SearchBaseProvider.of(context).getSearchWidget(id);
      if (component != null && query.isNotEmpty) {
        component.setValue(query, options: Options(triggerCustomQuery: true));
        close(context, null);
      }
    });
    return Container();
  }

  ListView getSuggestionList(BuildContext context,
      SearchController searchController, List<Suggestion> list) {
    List<Widget> suggestionsList = list.map((suggestion) {
      void handleTap() {
        // Perform actions on suggestions tap
        searchController.setValue(suggestion.value,
            options: Options(triggerCustomQuery: true));
        this.query = suggestion.value;
        String? objectId;
        if (suggestion.source != null && suggestion.source!['_id'] is String) {
          objectId = suggestion.source!['_id'].toString();
        }
        if (objectId != null &&
            suggestion.clickId != null &&
            searchController.appbaseSettings?.recordAnalytics == true) {
          try {
            // Record click analytics
            searchController.recordClick({objectId: suggestion.clickId!},
                isSuggestionClick: true);
          } catch (e) {
            print(e);
          }
        }

        close(context, null);
      }

      return Container(
          alignment: Alignment.topLeft,
          height: 50,
          child: buildSuggestionItem != null
              ? buildSuggestionItem!(suggestion, handleTap)
              : Container(
                  child: ListTile(
                    onTap: handleTap,
                    leading: suggestion.isRecentSearch
                        ? Icon(Icons.history)
                        : (suggestion.isPopularSuggestion)
                            ? Icon(Icons.trending_up)
                            : Icon(Icons.search),
                    title: Text(suggestion.label,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: showAutoFill == true
                        ? IconButton(
                            icon: Icon(FeatherIcons.arrowUpLeft),
                            onPressed: () => {this.query = suggestion.value})
                        : null,
                  ),
                  decoration: new BoxDecoration(
                      border: new Border(
                          bottom: new BorderSide(
                              color: Color(0xFFC8C8C8), width: 0.5)))));
    }).toList();
    return ListView(
        padding: const EdgeInsets.all(8), children: suggestionsList);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SearchWidgetConnector(
        id: id,
        triggerQueryOnInit: true,
        subscribeTo: [
          'error',
          'requestPending',
          'results',
          'value',
          'recentSearches'
        ],
        // properties to configure search component
        credentials: credentials,
        index: index,
        url: url,
        appbaseConfig: appbaseConfig,
        transformRequest: transformRequest,
        transformResponse: transformResponse,
        headers: headers,
        type: QueryType.search,
        react: react,
        queryFormat: queryFormat,
        dataField: dataField,
        categoryField: categoryField,
        categoryValue: categoryValue,
        nestedField: nestedField,
        from: from,
        size: size,
        sortBy: sortBy,
        aggregationField: aggregationField,
        aggregationSize: aggregationSize,
        after: after,
        includeNullValues: includeNullValues,
        includeFields: includeFields,
        excludeFields: excludeFields,
        fuzziness: fuzziness,
        searchOperators: searchOperators,
        highlight: highlight,
        highlightField: highlightField,
        customHighlight: customHighlight,
        interval: interval,
        aggregations: aggregations,
        missingLabel: missingLabel,
        showMissing: showMissing,
        enableSynonyms: enableSynonyms,
        selectAllLabel: selectAllLabel,
        pagination: pagination,
        queryString: queryString,
        defaultQuery: defaultQuery,
        customQuery: customQuery,
        beforeValueChange: beforeValueChange,
        onValueChange: onValueChange,
        onResults: onResults,
        onAggregationData: onAggregationData,
        onError: onError,
        onRequestStatusChange: onRequestStatusChange,
        onQueryChange: onQueryChange,
        enablePopularSuggestions: enablePopularSuggestions,
        maxPopularSuggestions: maxPopularSuggestions,
        showDistinctSuggestions: showDistinctSuggestions,
        preserveResults: preserveResults,
        clearOnQueryChange: clearOnQueryChange,
        value: query,
        results: results,
        distinctField: distinctField,
        distinctFieldConfig: distinctFieldConfig,
        builder: (context, searchController) {
          if (query != searchController.value) {
            // To fetch the suggestions
            searchController.setValue(query,
                options: Options(triggerDefaultQuery: true));
          }
          if (query.isEmpty) {
            if (enableRecentSearches == true) {
              // Fetch recent searches
              searchController.getRecentSearches(
                  options: Options(stateChanges: false));
            }
          }
          // If query is empty then render recent searches
          if (query.isEmpty &&
              searchController.recentSearches?.isNotEmpty == true) {
            return getSuggestionList(
                context, searchController, searchController.recentSearches!);
          }
          final List<Suggestion> popularSuggestions = searchController
              .suggestions
              .where((suggestion) => suggestion.isPopularSuggestion)
              .toList();
          List<Suggestion> filteredSuggestions = [];
          // Only display relevant suggestions when query is not empty
          if (query.isNotEmpty) {
            filteredSuggestions = searchController.suggestions
                .where((suggestion) => !suggestion.isPopularSuggestion)
                .toList();
            // Limit the suggestions by size
            if (filteredSuggestions.length > this.size!) {
              filteredSuggestions.sublist(0, this.size);
            }
          }
          // Append popular suggestions at bottom
          if (popularSuggestions.isNotEmpty) {
            filteredSuggestions = [
              ...filteredSuggestions,
              ...popularSuggestions
            ];
          }
          return (popularSuggestions.isEmpty && filteredSuggestions.isEmpty)
              ? ((query.isNotEmpty && searchController.requestPending == false)
                  ? Container(
                      child: Center(child: Text('No suggestions found')),
                    )
                  : searchController.requestPending
                      ? Center(child: CircularProgressIndicator())
                      : Container())
              : getSuggestionList(
                  context, searchController, filteredSuggestions);
        });
  }
}
