import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart' as sb;
import 'package:flutter_searchbox/flutter_searchbox.dart';
import 'dart:async';
import '../utils.dart';

class BuildOptions {
  /// A map of search controller id to [sb.SearchController]
  /// One can loop through the map to get the corresponding raw value for each filter.
  /// For example,
  /// selectedValues.forEach((filterId, filterValue){
  ///     // do something with extracted values
  /// })
  final Map<String, dynamic> selectedValues;

  /// A utility method to parse the value to a string.
  /// It covers all the value formats supported by Appbase.
  final String Function(dynamic value) getValueAsString;

  /// To reset the controller value to `null`.
  /// The second param is optional which can be used to define the reset
  /// value (default is `null).
  /// For example,
  /// clearValue("searchbox", "")
  final void Function(String id, [dynamic resetTo]) clearValue;

  /// To clear the values
  /// An optional param can be defined to reset values for controllers.
  /// For example,
  /// clearValues({ "searchbox": "", "author-filter": [] })
  final void Function([Map<String, dynamic> resetTo]) clearValues;

  BuildOptions({
    required this.selectedValues,
    required this.getValueAsString,
    required this.clearValue,
    required this.clearValues,
  });
}

/// It creates a selectable filter UI view displaying the current selected values from other active widgets.
///
/// This component is useful for improving selection accessibility of other components.
///
/// Examples Use(s):
///    - displaying all the user selected facet filters together in the main view area for better accessibility.
class SelectedFilters extends StatefulWidget {
  /// A list of component ids to subscribe to.
  ///
  /// This property allows users to select the search contollerer for which
  /// they want to display the filter value.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   subscribeTo: const ['range-selector'],
  ///   ...
  /// )
  /// ```
  final List<String>? subscribeTo;

  /// An optional prop to define the filter labels for each controller.
  /// The default value of filter is the `$id: $value`.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   filterLabel: (id, value) {
  ///     if (id == 'range-selector') {
  ///       return 'Range: $value';
  ///     }
  ///      return '$id: $value';
  ///    },
  ///   ...
  /// )
  /// ```
  final String Function(String id, String value)? filterLabel;

  /// If `true` then display `Clear All` button. Defaults to `true`.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   showClearAll: false,
  ///   ...
  /// )
  /// ```
  final bool? showClearAll;

  /// To modify the clear all label.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   clearAllLabel: "Vanish All",
  ///   ...
  /// )
  /// ```
  final String? clearAllLabel;

  /// A map of active widgets' default values.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   defaultValues: () {
  ///         "price-filter": { start: 10000 }
  ///     },
  ///   ...
  /// )
  /// ```
  final Map<String, dynamic>? defaultValues;

  /// If `true` then `Clear All` action would reset the filter values to default
  /// values. User must define the `defaultValues` prop when `resetToDefault` is `true`.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   resetToDefault: true,
  ///   defaultValues: () {
  ///         "price-filter": { start: 10000 }
  ///     },
  ///   ...
  /// )
  /// ```
  final bool? resetToDefault;

  /// If `true` then SelectedFilters will not show default values of active widgets.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   hideDefaultValues: true,
  ///
  ///   ...
  /// )
  /// ```
  final bool? hideDefaultValues;

  /// Callback function, triggered when all filters are cleared.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   onClearAll: () {
  ///         // do something here
  ///     },
  ///   ...
  /// )
  /// ```
  final void Function()? onClearAll;

  /// Callback function, triggered when a specific filter is cleared.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   onClear: (id, value) {
  ///         // do something here
  ///     },
  ///   ...
  /// )
  /// ```
  final void Function(String, dynamic)? onClear;

  /// It is used for custom rendering the filters
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   buildFilters: (options) {
  ///     List<Widget> widgets = [];
  ///      options!.selectedValues.forEach((id, filterValue) {
  ///      widgets.add(
  ///        Chip(
  ///          label: Text(
  ///              ' $id --- ${options.getValueAsString(filterValue)}'),
  ///          onDeleted: () {
  ///            options.clearValue(id);
  ///          },
  ///        ),
  ///      );
  ///    });
  ///    return Wrap(
  ///      spacing: 16.0,
  ///     crossAxisAlignment: WrapCrossAlignment.start,
  ///     children: widgets,
  ///    );
  ///   },
  ///   ...
  /// )
  /// ```

  final Widget Function(BuildOptions options)? buildFilters;
  SelectedFilters({
    this.subscribeTo,
    this.filterLabel,
    this.showClearAll = true,
    this.clearAllLabel,
    this.onClearAll,
    this.onClear,
    this.resetToDefault,
    this.defaultValues,
    this.hideDefaultValues,
    this.buildFilters,
    Key? key,
  }) : super(key: key) {
    if (resetToDefault != null || hideDefaultValues != null) {
      if (defaultValues == null) {
        throw ("defaultValues property is required, when resetToDefault/ hideDefaultValues properties are used.");
      }
    }
  }

  @override
  _SelectedFiltersState createState() => _SelectedFiltersState();
}

class _SelectedFiltersState extends State<SelectedFilters> {
  final Map<String, dynamic> _selectedFilters = {};
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setSelectedFilters());
  }

  Map<String, sb.SearchController> get activeWidgets {
    return SearchBaseProvider.of(context).getActiveWidgets();
  }

  dynamic getResetValue(String id) {
    try {
      if (widget.resetToDefault == true) {
        return widget.defaultValues is Map ? widget.defaultValues![id] : null;
      }

      return null;
    } catch (e) {
      // ignore: avoid_print
      print('error in $e');
    }
  }

  void setSelectedFilters() {
    try {
      final activeWidgets = this.activeWidgets;
      for (var id in activeWidgets.keys) {
        if (widget.subscribeTo != null && widget.subscribeTo!.isNotEmpty) {
          if (!widget.subscribeTo!.contains(id)) {
            continue;
          }
        }
        final componentInstance = activeWidgets[id];
        // the block below is added to initialize the values
        // after that, subscription method takes charge to update values
        if (mounted) {
          setState(() {
            final currentValue = componentInstance!.value;
            if (!isNullEmptyOrFalse(currentValue) &&
                (widget.hideDefaultValues == true
                    ? !isEqual(currentValue, widget.defaultValues![id])
                    : true)) {
              _selectedFilters[id] = currentValue;
            } else {
              _selectedFilters.remove(id);
            }
          });
        }
        // initialization block ends
        componentInstance?.subscribeToStateChanges((changes) {
          void applyChanges() {
            final currentValue = changes.Value?.next;
            if (!isNullEmptyOrFalse(currentValue) &&
                (widget.hideDefaultValues == true
                    ? !isEqual(currentValue, widget.defaultValues![id])
                    : true)) {
              _selectedFilters[id] = currentValue;
            } else {
              _selectedFilters.remove(id);
            }
          }

          if (mounted) {
            setState(() {
              applyChanges();
            });
          } else {
            applyChanges();
          }
        }, [sb.KeysToSubscribe.Value]);
      }
    } catch (e) {
      // ignore: avoid_print
      print('error $e');
    }
  }

  void clearFilter(String id, [dynamic resetTo]) {
    try {
      final activeWidgets = this.activeWidgets;
      if (widget.onClear != null) {
        widget.onClear!(id, activeWidgets[id]?.value);
      }

      _selectedFilters.remove(id);
      activeWidgets[id]?.setValue(resetTo ?? getResetValue(id),
          options: sb.Options(
            triggerCustomQuery: true,
          ));
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
    }
  }

  void clearAllFilters([Map<String, dynamic>? resetTo]) async {
    final activeWidgets = this.activeWidgets;
    for (var id in activeWidgets.keys) {
      _selectedFilters.remove(id);
      var componentInstance = activeWidgets[id];
      var completer = Completer();
      var resetValue = resetTo != null ? resetTo[id] : getResetValue(id);
      componentInstance?.setValue(resetValue,
          options: sb.Options(completer: completer));
      await completer.future;
    }

    Map<String, dynamic> componentValueMap = {};
    for (var id in activeWidgets.keys) {
      var componentInstance = activeWidgets[id];
      if (componentInstance != null) {
        componentValueMap[id] = componentInstance.value;
      }
    }
    SearchBaseProvider.of(context).setSearchState(componentValueMap);

    if (widget.onClearAll != null) {
      widget.onClearAll!();
    }
  }

  String renderLabel(String id, String value) {
    if (widget.filterLabel != null) {
      return widget.filterLabel!(id, value);
    }

    return id + ": " + value;
  }

  List<Widget> getFilterChips() {
    List<Widget> widgets = [];
    _selectedFilters.forEach((id, filterValue) {
      if (processFilterValues(filterValue) != "") {
        widgets.add(
          Chip(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0)),
            ),
            label: Text(
              renderLabel(id, processFilterValues(filterValue)),
            ),
            onDeleted: () {
              clearFilter(id);
            },
          ),
        );
      }
    });
    if (widgets.length > 1 && widget.showClearAll == true) {
      widgets.add(
        Chip(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.zero),
          ),
          label: Text(widget.clearAllLabel ?? "Clear All"),
          onDeleted: () {
            clearAllFilters();
          },
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buildFilters != null) {
      return widget.buildFilters!(
        BuildOptions(
          selectedValues: _selectedFilters,
          getValueAsString: processFilterValues,
          clearValue: clearFilter,
          clearValues: clearAllFilters,
        ),
      );
    }
    return Wrap(
      spacing: 16.0,
      crossAxisAlignment: WrapCrossAlignment.start,
      // gap between adjacent chips
      children: getFilterChips(),
    );
  }
}
