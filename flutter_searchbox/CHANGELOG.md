## 4.0.1

- updates deprecated API use for onPrimary/primary → foregroundColor/backgroundColor in example / author_filter.dart
- updates searchbase dependency to 4.0.1
- updates README, modernizes Flutter code examples

## 4.0.0

- stable release

## 4.0.0-alpha.6

- update searchbase: expose URL through transformRequest function

## 4.0.0-alpha.5

- update searchbase

## 4.0.0-alpha.4

- bug fixes

## 4.0.0-alpha.1

- alpha version for Dart 3 upgrade

## [3.2.0] - 05-09-2022

- stable release

## 3.2.10-beta

- Upgrade searchbase

## 3.2.9-beta

- add support for `compoundClause` property

## 3.2.7-beta

- feat: support httpRequestTimeout prop
- upgrade searchbase

## 3.2.6-beta

- Upgrade searchbase

## 3.2.5-beta

- Upgrade searchbase

## 3.2.4-beta

- Upgrade searchbase

## 3.2.2-beta

- Upgrade searchbase

## 3.2.1-beta

- Upgrade searchbase

## 3.2.0-beta

- Upgrade to Flutter 3

## [3.0.0] - 21-04-2022

- Add [StateProvider] widget.
- Breaking Change (as per **searchbase: 3.0.0**)

  - [SearchWidgetConnector]/ [SearchController] accepts subscribeTo as [List<KeysToSubscribe>];
  - `subscribeToStateChanges()` now accepts array of enums (`KeysToSubscribe`) for properties to subscribe, instead of hard-coded strings.
    Also, the subscription callback function receives a `ChangesController` class argument instead of `Changes` type.

    - **before**

    ```dart
        widgetInstance.subscribeToStateChanges((Changes change){
            print('${changes['results']!.next}');
        }, ['results']);
    ```

    - **after**

    ```dart
        widgetInstance.subscribeToStateChanges((ChangesController change){
            print('${changes.Results!.next}');
        }, [KeysToSubscribe.Results]);
    ```

  > Refer to docs to see the `KeysToSubscribe` enum defined under _types.dart_

## [2.2.4-nullsafety] - 15-01-2022

- Update searchbase

## [2.2.3-nullsafety] - 03-11-2021

- Update beforeValueChange function signature

## [2.2.2-nullsafety] - 26-10-2021

- Update searchbase

## [2.2.1-nullsafety] - 9-09-2021

- Update provider package

## [2.2.0-nullsafety] - 19-08-2021

- Add support for `clearOnQueryChange` property

## [2.0.1-nullsafety] - 20-07-2021

- Add support for `index` property in search widget connector
- Remove `dataField` validation (required)

## [2.0.0-nullsafety] - 13-05-2021

- Add support for null safety

## [1.2.0] - 13-03-2021

- Add support to customize voice search experience

## [1.1.0] - 25-02-2021

- Add support for voice search in `SearchBox` widget

## [1.0.0] - 19-02-2021

- Add `aggregationSize` property to define size of aggregations
- Fix an issue with multiple API calls to recent searches when query is empty

## [1.0.0-alpha.6] - 17-02-2021

- Update searchbase

## [1.0.0-alpha.5] - 05-02-2021

- Add support to implement pagination with aggregations

## [1.0.0-alpha.4] - 22-01-2021

- Update searchbase that introduces a breaking change to rename SearchWidget class to SearchController class

## [1.0.0-alpha.3] - 22-01-2021

- Format Docs

## [1.0.0-alpha.2] - 21-01-2021

- Update example to fix hot reloading issues
- Catch error while triggering click analytics
- Fix suggestions parsing when `dataField` is not defined
- Display popular suggestions as default suggestions
- Update example to persist search query

## [1.0.0-alpha.1] - 14-01-2021.

- Format docs

## [1.0.0-alpha] - 14-01-2021.

- Add `SearchBaseProvider` widget
- Add `SearchBox` widget
- Add `SearchWidgetConnector` widget
