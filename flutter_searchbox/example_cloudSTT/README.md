# Flutter Searchbox Cloud STT Example

A basic example to demonstrate the `flutter_searchbox` usage to build search layout with autosuggestions and voice search.

## Getting Started

1. Go to cloud.google.com and create or select a project.
2. Enable the Speech-to-Text API for that project.
3. Create a service account.
4. Download a private key as JSON.
5. Open audio_converter.dart file and paste the JSON object in here -
###
```
final serviceAccount = ServiceAccount.fromString(r'''{in here}''');
```
###
6. Change the config in the audio_converter.dart file according to the use-case.
7. Open terminal then go to the root folder and run the following commands - 
###
```
flutter pub get
flutter run main.dart
```
###

