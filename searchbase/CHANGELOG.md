## 3.2.1-beta

- Fix a bug in searchController class https://github.com/appbaseio/flutter-searchbox/pull/23

## 3.2.0-beta

- Upgrade to Flutter 3

## 3.0.0

- Add support for [KeysToSubscribe] enum.
- Add support for [ChangesController] class to read the state changes in subscriber method.
- Breaking Change
  - `subscribeToStateChanges()` now accepts array of enums ([KeysToSubscribe]) for properties to subscribe, instead of hard-coded strings.
    Also, the subscription callback function receives a [ChangesController] class argument instead of [Changes] type. - **before**
    `dart widgetInstance.subscribeToStateChanges((Changes change){ print('${changes['results']!.next}'); }, ['results']); ` - **after**
    `dart widgetInstance.subscribeToStateChanges((ChangesController change){ print('${changes.Results!.next}'); }, [KeysToSubscribe.Results]); `
    > Refer to docs to see the [KeysToSubscribe] enum defined under _types.dart_

## 2.2.4

- Fix callbacks for change events

## 2.2.3

- Apply value returned by `beforeValueChange` method

## 2.2.2

- Fix `beforeValueChange` function signature

## 2.2.1

- Fix `aggregationField` is same as `dataField` issue
- Export `results.dart`

## 2.2.0

- Add support for `clearOnQueryChange` property

## 2.1.0

- Add support for `index` property in search controller
- Remove `dataField` validation (required)

## 2.0.1

- Fix properties parameter in subscribeToStateChanges method

## 2.0.0

- Add support for null safety

## 1.0.1

- Fix docs

## 1.0.0

- Add `aggregationSize` property to define size of aggregations

## 1.0.0-alpha.9

- Fix type error when `preserveResults` is not defined

## 1.0.0-alpha.8

- Add support to paginate aggregations

## 1.0.0-alpha.7

BREAKING: Rename SearchWidget class to SearchController

## 1.0.0-alpha.6

- Format Docs

## 1.0.0-alpha.5

- Fix suggestions parsing logic if `dataField` is not defined
- Fix `onError` type error
- Add more properties in `Suggestion` class to differentiate between recent, popular and relevant suggestions.

## 1.0.0-alpha.4

- Format docs

## 1.0.0-alpha.3

- Fix docs link

## 1.0.0-alpha.2

- Fix docs link

## 1.0.0-alpha.1

- Fix bugs
- Add documentation with example

## 1.0.0-alpha

- Add `SearchWidget` and `SearchBase` classes
- Implement query generation and analytics
- Recent searches
- Popular Suggestions
