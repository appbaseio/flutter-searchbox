## 4.0.0-alpha.6

- Improved: Map - onCameraIdle callback to prevent unnecessary queries on mount

## 4.0.0-alpha.5

- update searchbase and flutter_searchbox: expose URL through transformRequest function

## 4.0.0-alpha.4

- upgrade searchbase and flutter_searchbox


## 4.0.0-alpha.3

## 4.0.0-alpha.1

- alpha release for Dart 3 support

## [3.2.0] - 05-09-2022

- stable release

## 3.2.11-beta

- Upgrade searchbase
- Upgrade flutter_searchbox

## 3.2.10-beta

- add support for `compoundClause` property

## 3.2.9-beta

- RangeInput: triggerQueryOnMount prop support
- httpRequestTimeout Support for RangeInput and ReactiveGoogleMap

## 3.2.8-beta

- fix: reset filters bug - regression
- Upgrade searchbase
- Upgrade flutter_searchbox

## 3.2.7-beta

- Upgrade searchbase
- Upgrade flutter_searchbox

## 3.2.6-beta

- fix: value not set for range_filter when used on tablets

## 3.2.5-beta

- Upgrade searchbase - fix multiple API calls when resetting filters
- Upgrade flutter_searchbox

## 3.2.4-beta

- Upgrade searchbase
- Upgrade flutter_searchbox

## 3.2.3-beta

- Upgrade searchbase
- Upgrade flutter_searchbox

## 3.2.2-beta

- Upgrade searchbase

## 3.2.1-beta

- Upgrade searchbase

## 3.2.0-beta

- Upgrade to Flutter 3

## [1.1.0] - 21-04-2022

- Breaking changes as per `searchbase: 3.0.0` & `flutter_searchbox: 3.0.0`
  - `RangeInput()`'s subscribeTo property accepts a list of enums(KeysToSubscribe) instead of List<String>.
    - **before**
      ```dart
        RangeInput(
          subscribeTo: ['results', 'aggregationData']
        )
      ```
    - **after**
      `dart RangeInput( subscribeTo: [KeysToSubscribe.Results, KeysToSubscribe.AggregationData] ) `
      > The same applies for `ReactiveGoogleMap()` widget.

## [1.0.20-alpha] - 16-02-2022

- Allow strings and bool type in SelectedFilters

## [1.0.19-alpha] - 08-012-2022

- Fix type errors

## [1.0.17-alpha] - 17-01-2022

- Fix callback for change events

## [1.0.16-alpha] - 14-12-2021

- fix: selected_filters widget breaking when used in a page or drawer
- fix: range_input widget breaking when passed with a non-acceptable value as defaultvalue

## [1.0.15-alpha] - 19-11-2021

- Fix issues reported: range-input not working well with selected-filters
- null value handling

## [1.0.14-alpha] - 19-11-2021

- Update docs

## [1.0.13-alpha] - 03-11-2021.

- Add SelectedFilters widget
- Update RangeInput widget to support SelectedFilters widget.

## [1.0.12-alpha] - 17-11-2021.

## [1.0.11-alpha] - 03-11-2021.

- Update flutter searchbox

## [1.0.8-alpha] - 26-10-2021.

- Update docs

## [1.0.7-alpha] - 26-10-2021.

- Add support for `ReactiveGoogleMap` component

## [1.0.6-alpha] - 13-10-2021.

Define new props.

- closeIcon => To customize close icon in input box.
- dropdownIcon=> To customize dropdown icon.

## [1.0.5-alpha] - 08-10-2021.

- Refined logic for default value and query firing.

## [1.0.4-alpha] - 07-10-2021.

- Adds detailed defs for `range` parameter.
- Refactors example to display `RangeInput` on the HomePage.
- Changes `no limit` to `no_limit`, for unbounded upper bound.
- updated example with all arguments usage

## [1.0.3-alpha] - 06-10-2021.

- Allows custom stlyes to be set.
- Fixes broken ui when clearing dropdown.
- Triggers query with default values.
- Supports unbounded upper limit via `no limit` dropdown option.

## [1.0.2-alpha] - 30-09-2021.

- Simplified RangeInput Example.
- Fix `Readme` for example.

## [1.0.1-alpha] - 30-09-2021.

- Fix `RangeInput` widget for bugs.
  - validation bugs.
  - display range labels for text input also.
  - updated documentation with relevant example snippets.

## [1.0.0-alpha] - 30-09-2021.

- Add `RangeInput` widget
