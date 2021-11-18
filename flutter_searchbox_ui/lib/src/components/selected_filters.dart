import 'dart:math';

import 'package:flutter/material.dart';
import 'package:searchbase/searchbase.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';
import '../utils.dart';

class SelectedFilter {
  final String filterLabel;
  final String filterValue;
  const SelectedFilter({required this.filterLabel, required this.filterValue});
}

// It creates a selectable filter UI view displaying the current selected values from other active widgets.
//
// This component is useful for improving selection accessibility of other components.
//
// Examples Use(s):
//    - displaying all the user selected facet filters together in the main view area for better accessibility.
class SelectedFilters extends StatefulWidget {
  /// A list of component ids to subscribe to.
  /// [Optional]
  /// This property allows users to select the search contollerer for which
  /// they want to display the filter value.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   subscribeTo: const ['range-selector', 'map-widget'],
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

  const SelectedFilters({
    this.subscribeTo,
    this.filterLabel,
    this.showClearAll = true,
    this.clearAllLabel,
    this.onClearAll,
    this.onClear,
    this.resetToDefault = false,
    this.defaultValues,
    this.hideDefaultValues = false,
    Key? key,
  }) : super(key: key);

  @override
  _SelectedFiltersState createState() => _SelectedFiltersState();
}

class _SelectedFiltersState extends State<SelectedFilters> {
  final Map<String, dynamic> _selectedFilters = {};
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => setSelectedFilters());
  }

  Map<String, SearchController> get activeWidgets {
    return SearchBaseProvider.of(context).getActiveWidgets();
  }

  dynamic getResetValue(String id) {
    if (widget.resetToDefault == true) {
      if (widget.defaultValues == null || widget.defaultValues!.isEmpty) {
        throw ("defaultValues property is expected when resetToDefault is set to true");
      }

      return widget.defaultValues![id] ?? "";
    }

    return "";
  }

  void setSelectedFilters() {
    final activeWidgets = this.activeWidgets;
    for (var id in activeWidgets.keys) {
      if (widget.subscribeTo!.isNotEmpty) {
        if (!widget.subscribeTo!.contains(id)) {
          continue;
        }
      }
      final componentInstance = activeWidgets[id];
      componentInstance?.subscribeToStateChanges((changes) {
        setState(() {
          final currentValue = changes['value']?.next;
          if (currentValue != null &&
              !currentValue.isEmpty &&
              (widget.hideDefaultValues == true
                  ? !isEqual(currentValue, widget.defaultValues)
                  : true)) {
            _selectedFilters[id] = currentValue;
          }
        });
      }, ["value"]);
    }
  }

  void clearFilter(String id) {
    final activeWidgets = this.activeWidgets;
    if (widget.onClear != null) {
      widget.onClear!(id, activeWidgets[id]?.value);
    }

    _selectedFilters.remove(id);
    activeWidgets[id]?.setValue(
      getResetValue(id),
      options: Options(triggerCustomQuery: true),
    );
  }

  void clearAllFilters() {
    final activeWidgets = this.activeWidgets;
    for (var id in activeWidgets.keys) {
      _selectedFilters.remove(id);
      var componentInstance = activeWidgets[id];
      componentInstance?.setValue(null);
    }
    for (var id in activeWidgets.keys) {
      var componentInstance = activeWidgets[id];
      componentInstance?.triggerCustomQuery();
    }

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
    return Wrap(
      spacing: 16.0,
      crossAxisAlignment: WrapCrossAlignment.start,
      // gap between adjacent chips
      children: getFilterChips(),
    );
  }
}
