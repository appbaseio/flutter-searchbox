## Searchbox

Searchbox is a lightweight and performance focused search UI component library to query and display results from your Elasticsearch index using declarative props. It's available for React, Vue, React Native and Flutter. This repo contains the Flutter variant of the library. If you're looking for other variants, you can go [here](https://github.com/appbaseio/searchbox).

<p align="center">
  <a href="https://github.com/appbaseio/searchbase/tree/master/packages/searchbox" style="padding: 10px; display: inline;"><img  width="30%" src="https://docs.appbase.io/images/Searchbox_JS@1x.png" alt="searchbox" title="searchbox" /></a>
  <a href="https://github.com/appbaseio/searchbase/tree/master/packages/react-searchbox" style="padding: 10px; display: inline;"><img   width="30%" src="https://docs.appbase.io/images/Searchbox_React@1x.png" alt="react_searchbox" title="react searchbox" /></a>
  <a href="https://github.com/appbaseio/searchbase/tree/master/packages/vue-searchbox" style="padding: 10px; display: inline;"><img   width="30%" src="https://docs.appbase.io/images/Searchbox_Vue@1x.png" alt="vue searchbox" title="vue searchbox" /></a>
</p>
<p align="center">
  <a href="https://github.com/appbaseio/searchbase/tree/master/packages/native"><img width="30%" src="https://opensource.appbase.io/searchbox/images/Searchbox_React_Native.png" alt="react_native_seacrchbox" title="react native searchbox" /></a>
 <a href="https://github.com/appbaseio/flutter-searchbox/tree/master/flutter_searchbox"><img width="30%" src="https://opensource.appbase.io/searchbox/images/Searchbox_Flutter.png" alt="flutter_searchbox" title="flutter searchbox" /></a>
</p>

---

### Getting Started

| Library                                                                                    | Install                                            | Demo                                                                                                                                      | Docs                                                                                   |
| ------------------------------------------------------------------------------------------ | -------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| [Flutter Searchbox](https://docs.appbase.io/docs/reactivesearch/flutter-searchbox/quickstart/)     | [Installation](https://docs.appbase.io/docs/reactivesearch/flutter-searchbox/quickstart/#installation)                   | [Basic](https://codesandbox.io/s/github/appbaseio/searchbase/tree/master/packages/flutter-searchbox/quickstart/#a-simple-example)                           | [Quick Start](https://docs.appbase.io/docs/reactivesearch/flutter-searchbox/quickstart/)   |
| [React Searchbox](https://docs.appbase.io/docs/reactivesearch/react-searchbox/quickstart/) | `npm i @appbaseio/react-searchbox`                 | [Basic](https://codesandbox.io/s/github/appbaseio/searchbase/tree/master/packages/react-searchbox/examples/basic)                         | [Quick Start](https://docs.appbase.io/docs/reactivesearch/react-searchbox/quickstart/) |
| [Searchbox](https://docs.appbase.io/docs/reactivesearch/searchbox/Quickstart/)             | `npm i @appbaseio/searchbox @appbaseio/searchbase` | [Searchbar with Style](https://codesandbox.io/s/github/appbaseio/searchbase/tree/master/packages/searchbox/examples/searchbar-with-style) | [Quick Start](https://docs.appbase.io/docs/reactivesearch/searchbox/Quickstart/)       |
| [Vue Searchbox](https://docs.appbase.io/docs/reactivesearch/vue-searchbox/quickstart/)     | `npm i @appbaseio/vue-searchbox`                   | [Basic](https://codesandbox.io/s/github/appbaseio/searchbase/tree/master/packages/vue-searchbox/examples/basic)                           | [Quick Start](https://docs.appbase.io/docs/reactivesearch/vue-searchbox/quickstart/)   |
| [React Native Searchbox](https://docs.appbase.io/docs/reactivesearch/react-native-searchbox/quickstart/)     | `npm i @appbaseio/react-native-searchbox`                   | [Basic](https://docs.appbase.io/docs/reactivesearch/react-native-searchbox/quickstart/#a-simple-example)                           | [Quick Start](https://docs.appbase.io/docs/reactivesearch/react-native-searchbox/quickstart/)   |


### Features

We have baked some amazing features in libraries which helps getting insights from searches and also help beautify and enhance search experiences.

| Feature                                                                                                                        | Description                                                                                                                                                                 |
| ------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Autosuggestions](https://opensource.appbase.io/playground/?path=/story/search-components-datasearch--basic)                   | Built-in autosuggest functionality with keyboard accessibility.                                                                                                             |
| [Fuzzy Search](https://opensource.appbase.io/playground/?path=/story/search-components-datasearch--with-fuzziness-as-a-number) | Useful for showing the correct results for an incorrect search parameter by taking the fuzziness into account.                                                              |
| Query String Support                                                                                                           | URL query string param based on the search query text value.This is useful for sharing URLs with the component state.                                                       |
| [Search Operators](https://opensource.appbase.io/playground/?path=/story/search-components-datasearch--with-searchoperators)   | Use special characters in the search query to enable an advanced search behavior.                                                                                           |
| [Voice Search](https://opensource.appbase.io/playground/?path=/story/search-components-datasearch--with-showvoicesearch)       | Enable voice input for searching.                                                                                                                                           |
| [Search/Click Analytics](https://docs.appbase.io/docs/analytics/Overview/)                                                     | Search analytics allows you to keep track of the users' search activities which helps you to improve your search experience based on the analytics extracted by Appbase.io. |
| [Feature Results](https://docs.appbase.io/docs/search/Rules/)                                                                  | Promote and hide your results for search queries.                                                                                                                           |
| Customization                                                                                                                  | Support custom UI components in order to maintain a consistentency with existing design system.                                                                             |
                                                          

### Contributing

Please check the [contribution guide](.github/CONTRIBUTING.md).

### Other Projects You Might Like

- [**ReactiveSearch**](https://github.com/appbaseio/reactivesearch/) React, React Native and Vue UI components for building data-driven apps with Elasticsearch.

- [**arc**](https://github.com/appbaseio/arc) API Gateway for Elasticsearch (Out of the box Security, Rate Limit Features, Record Analytics and Request Logs).

- [**dejavu**](https://github.com/appbaseio/dejavu) allows viewing raw data within an appbase.io (or Elasticsearch) app. **Soon to be released feature:** An ability to import custom data from CSV and JSON files, along with a guided walkthrough on applying data mappings.

- [**mirage**](https://github.com/appbaseio/mirage) ReactiveSearch components can be extended using custom Elasticsearch queries. For those new to Elasticsearch, Mirage provides an intuitive GUI for composing queries.

* [**appbase-js**](https://github.com/appbaseio/appbase-js) While building search UIs is dandy with Reactive Search, you might also need to add some input forms. **appbase-js** comes in handy there.

