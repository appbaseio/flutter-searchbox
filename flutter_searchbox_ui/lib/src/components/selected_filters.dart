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

  // If `true` then display `Clear All` button. Defaults to `true`.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   showClearAll: false,
  ///   ...
  /// )
  /// ```
  final bool? showClearAll;

  // To modify the clear all label.
  /// For example,
  /// ```dart
  /// SelectedFilters(
  ///   ...
  ///   clearAllLabel: "Vanish All",
  ///   ...
  /// )
  /// ```
  final String? clearAllLabel;

  const SelectedFilters({
    this.subscribeTo,
    this.filterLabel,
    this.showClearAll = true,
    this.clearAllLabel,
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
          if (currentValue != null && !currentValue.isEmpty) {
            _selectedFilters[id] = currentValue;
          }
        });
      }, ["value"]);
    }
  }

  void clearFilter(String id) {
    _selectedFilters.remove(id);
    final activeWidgets = this.activeWidgets;
    activeWidgets[id]?.setValue(
      "",
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
