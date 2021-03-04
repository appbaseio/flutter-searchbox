# Flutter Searchbox Contribution Guide 🔍

Welcome to the contribution guide! We welcome all contributions. You can see the list of open issues over [here](https://github.com/appbaseio/flutter-searchbox/issues). If you're interested in picking up something, feel free to start a discussion 😺

The searchbox monorepo contains the code for the headless core(`searchbase`) and the searchbox UI widgets for flutter(`flutter_searchbox`). Project specific README files are available inside each package.

## Initial setup

1. Fork the repository in order to send PRs

2. Clone the repo from your profile, use SSH if possible. Read more about it over [here](https://help.github.com/articles/connecting-to-github-with-ssh/).

3. `cd` into the project directory

4. Checkout the `master` branch (should be default)

5. Install flutter SDK. Please follow the instructions mentioned at [here](https://flutter.dev/docs/get-started/install/macos).


## Searchbase

- Searchbase dart code is located at [here](https://github.com/appbaseio/flutter-searchbox/tree/master/searchbase/lib).

- To run an example follow the below steps:

1. `cd` into the example
```bash
cd searchbase/example/basic
```

2. Install dependencies
```bash
flutter pub get
```
3. Activate webdev
```bash
flutter pub global activate webdev
```
4. Run the example
```bash
webdev serve
```

The web examples depend relatively on the `searchbase` package so you can make the changes in the lib and test on the fly.

**Note:** If you see any issue while running the example please check the [installation guide](https://dart.dev/tutorials/web/get-started) for dart web.

## Flutter Searchbox

- Flutter searchbox provides ready-to-use UI widgets to build search UIs for flutter apps. It uses the `searchbase` library to manage the state of the active search widgets.
- It is located at [here](https://github.com/appbaseio/flutter-searchbox/tree/master/flutter_searchbox).
- If you want to watch for the changes in the `searchbase` lib then use a relative path instead of the direct dependency at [here](https://github.com/appbaseio/flutter-searchbox/blob/master/flutter_searchbox/pubspec.yaml#L14).

- To run an example follow the below steps:
1. `cd` into the example
```bash
cd flutter_searchbox/example
```

2. Open ios simulator
```bash
Open -a Simulator.app
```

3. Install dependencies
```bash
flutter pub get
```

4. Run the example
```bash
flutter run
```

<hr />
