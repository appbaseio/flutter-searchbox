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
  final serviceAccount = ServiceAccount.fromString(r'''{
    "type": "service_account",
    "project_id": "flutter-stt-sear-1615527491796",
    "private_key_id": "5a6b73ff8b542c61ece5ed90eb4f99266fa56b0e",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDTwIe+NBZQ+m2k\nJlnTP1ejg06VMHIhDFPf5o9DRrYSw3HZQx4dd98Kxgjrx4Pzp0MCuoXsod4OXjKc\n1jni1v6bjUnoelSStgqFVc1m0nqolz0MlzfN1MyzyyqwUe+Ru3ZmkO/rnANqQtyJ\nvBoEoPMDkwFN7F2rCBLQQp++5/5VqkXWEgZ8+eDcFPCUyLiNdh7A8OFl8qiW4iLZ\nqSlu/TWTDin8Vv+zvtFOyLV8bfKL85GLhUHo7jbUZw5+v/+uyiGl/ZLGIKkQP8Ka\nIEKooto9oFvLoc9n257B1Ov9pR6AHk3oKJiH1i8irUtLgr5q5TeugOIvK8kb9D6u\nhk+lDLFHAgMBAAECggEAWTmUOSo7iQ2s63EZgnD7XbPzhduvC4vlP8An98Iw8EEY\nlOK6KtKa0jBWC/u69w0wqFKuIeKm7cj1bK68H4BWMndbgDEjt9orHrnj3gKsmqN3\nnvmNExcq1kuyhi9QUkj6gAdsgQvxSHI5+XOgRvkGzSfBcfM6GNpDCyw3obqhqbhc\njyqIrP9+4AUUUK0JADXJq83bdIPXXe4sPBQsK/x7BNfEaGTJ5UWFnjV9M0s5W3GK\nzUGQOoyj2I/HpWxr4hVeiAp1q3fWT9s+nPICYnaAvrUbypFEHjY8stF2SM3jyQI9\nDln6mWE01pMwCBbsz5iBlGR4JdEoMQxfvDEfBmpsWQKBgQDsLOC15zfGmf6SdvSH\nTP7EyXdp18pz3Oun4v5+1JsyVDOtTakBGI2oA3xKG2CMgKAAjP+giClESsVcUOY+\noo2BV26LVLvBJ2WmcolKjNunzO2/8ZM8iNPzOEUu0E2svl/9h3Gy7FZd9JPBDm2B\nkinCtDXsUjXx1jIYlrZHRWrAZQKBgQDlhtOhXvWxbw7iJZD8TCYWwFkl9FdRn8dG\nOOr7Sl1ZgxzjVyW+9KM0svoRPupCD1dm6whKhfaMm8lQwWC+5tQnOS5xulZv3JnJ\nwhxplQj1cuVn0gmd9D8WweVP+GDsJQKD4NR6nYNDfpWgfnxJm2WX9KDRL+PKoDjk\n9rgKAmpSOwKBgH5Uwx6KP9uMJBBUcRiupti8q5OCSlkPoz56vYc6UonpYHsjP3PG\nnn9w3dsGKe7+Hpgs09AbBXfyRv/Khl6atPaqvgbpnEUFven6+lVWY2iuxb4Wipum\n1TkUsG0KH4J3kwEaokcDBG/dk+uAvDLC7HOp0e5HS3PBD6r3cylMiH3BAoGBAIRn\n6MGYdAdtV5qhrSe+DeLmBwdcEtslXuFliDh6R6uRdSK4bS/hFB0ceiFkt+Jv0y2t\nu9Sxvu6SF+ocA+Fca1pNJDu7EI3rJlQ7RASsUsS1CR2BDsct1Q8dv1kIoXDYUMEe\n+7PYFZbj+RDipnQXzt1/4x2JkNCc6PU8ViKADjFtAoGAWzKhYQNnCkJXSQZGwCG7\n9W5LpzKjF48c7kB2x6EC33gSaXOZRKV2R+mnHL3rlZh57i9kMHObHbOrRaDOxnby\nEwg0ZPER+q4oSldeZrG4oNV8iCWeGcc/f0ZF1NxkFJeSudDcOMSC6GR7piyoRKjw\nlGAPsL9T+gMXd9U5xfqN788=\n-----END PRIVATE KEY-----\n",
    "client_email": "starting-account-s2z6fqoajm67@flutter-stt-sear-1615527491796.iam.gserviceaccount.com",
    "client_id": "107417012912825488053",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/starting-account-s2z6fqoajm67%40flutter-stt-sear-1615527491796.iam.gserviceaccount.com"
  }''');

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
