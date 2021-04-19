import 'dart:io';
import 'package:google_speech/google_speech.dart';
import 'package:google_speech/speech_client_authenticator.dart';

// This widget is responsible for all the transformation operations including connecting
// to a google STT server via a service account, configuring the recognition params, get the response
// back from the google server and finally delete the audio file that's been processed
class AudioConverter {
  final String path;
  AudioConverter({this.path}) : assert(path != null);

  // enter your private key from Google STT API
  final serviceAccount = ServiceAccount.fromString(r'''{}''');

  // set config according to usecase
  final config = RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-IN');

  // reading the audio content from the path
  Future<List<int>> _getAudioContent(String path) async {
    return File(path).readAsBytesSync().toList();
  }

  // connecting to Google Speech API to transform the audio file to text and getting the response  back
  convertSTT() async {
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final audio = await _getAudioContent(path);
    final response = await speechToText.recognize(config, audio);
    return response;
  }

  // deleting the audio file once the response is received
  deleteFile() async {
    try {
      await File(path).delete();
    } catch (e) {
      return 0;
    }
  }
}
