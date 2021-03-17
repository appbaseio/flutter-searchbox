import 'dart:io';
import 'package:google_speech/google_speech.dart';
import 'package:google_speech/speech_client_authenticator.dart';

class AudioConverter {
  final String path;
  AudioConverter({this.path}) : assert(path != null);
  // enter your private key from google STT API down below
  final serviceAccount = ServiceAccount.fromString(r'''{}''');
  final config = RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-IN');

  Future<List<int>> _getAudioContent(String path) async {
    return File(path).readAsBytesSync().toList();
  }

  convertSTT() async {
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final audio = await _getAudioContent(path);
    final response = await speechToText.recognize(config, audio);
    return response;
  }

  deleteFile() async {
    try {
      await File(path).delete();
    } catch (e) {
      return 0;
    }
  }
}
