import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file/local.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:searchbase/searchbase.dart';
import 'audio_converter.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';

typedef void SetOverlay(bool status, String value);

// This widget performs the audio recordings for the user's voice input
class Recorder extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  final SetOverlay setOverlay;

  Recorder({@required this.setOverlay, localFileSystem})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem();

  @override
  State<StatefulWidget> createState() => new RecorderState();
}

class RecorderState extends State<Recorder> {
  FlutterAudioRecorder _recorder;
  Recording _recordingInstance;
  RecordingStatus _recordingStatus = RecordingStatus.Unset;

  SearchController searchInstance;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // to retrieve the instance of SearchController for 'search-widget' component
    searchInstance =
        SearchBaseProvider.of(context).getSearchWidget('search-widget');
    return new IconButton(
      icon: Icon(Icons.mic),

      // to call specific functions according to the current recording status
      onPressed: () async {
        switch (_recordingStatus) {
          case RecordingStatus.Initialized:
            {
              _start();
              break;
            }
          case RecordingStatus.Stopped:
            {
              await _init();
              _start();
              break;
            }
          case RecordingStatus.Recording:
            {
              _stop();
              break;
            }
          case RecordingStatus.Paused:
            {
              _stop();
              break;
            }
          default:
            {
              _init();
              break;
            }
        }
      },
    );
  }

  // called when the widget is created
  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        var appDocDirectory;

        // to check the platform for setting up the directory path
        bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
        if (!isAndroid) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }
        // setting up unique path
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // creating an instance of the FlutterAudioRecorder and  setting up the format for the audio file
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        // initialising the recorder and setting up the recording channel
        await _recorder.initialized;
        var currentRecordingInstance = await _recorder.current(channel: 0);

        setState(() {
          _recordingInstance = currentRecordingInstance;
          _recordingStatus = currentRecordingInstance.status;
        });
      } else {
        // message to display in case permissions not found
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  // called to start the recording
  _start() async {
    try {
      widget.setOverlay(false, '');
      widget.setOverlay(true, 'Listening...');
      // starting the recorder and setting up the recording channel
      await _recorder.start();
      var recordingInstance = await _recorder.current(channel: 0);
      setState(() {
        _recordingInstance = recordingInstance;
      });

      // defining the time interval to periodically check the recording meter
      const tick = const Duration(milliseconds: 50);
      var count = 0;
      var pauseDuration = 0;
      bool triggerRequest = false;

      // setting the max time of recording to 5 secs
      new Timer.periodic(tick, (Timer t) async {
        count += 1;

        if (count >= 100) {
          _stop();
          t.cancel();
        }

        var currentRecordingInstance = await _recorder.current(channel: 0);

        // to check the user is speaking or not
        if (currentRecordingInstance.metering.isMeteringEnabled) {
          // condition to check if the user is speaking
          if (currentRecordingInstance.metering.peakPower > -7) {
            pauseDuration = 0;
            triggerRequest = true;
          } else {
            // condition to check the current pause time to trigger the _stop() function
            if (pauseDuration > 8 && triggerRequest) {
              _stop();
              t.cancel();
              triggerRequest = false;
            }
            pauseDuration += 1;
          }
        }

        if (mounted) {
          // to set the recording instance and status when the widgets mounts
          setState(() {
            _recordingInstance = currentRecordingInstance;
            _recordingStatus = _recordingInstance.status;
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  // called to stop the recording
  _stop() async {
    var result = await _recorder.stop();
    if (mounted) {
      widget.setOverlay(false, '');
      widget.setOverlay(true, 'Processing...');
      await setState(() {
        _recordingInstance = result;
        _recordingStatus = _recordingInstance.status;
      });

      // creating an instance of AudioConverter and passing the path to the constructor for the audio file
      var audioConverter = new AudioConverter(path: result.path);
      // calling the convertSTT function on the audioConverter instance to send the audio file to the google server and to get the response back
      var response = await audioConverter.convertSTT();
      // formatting the response to get the input text
      var responseString = response.results
          .map((e) => e.alternatives.first.transcript)
          .join('\n');
      widget.setOverlay(false, '');

      // displaying the transformed text
      widget.setOverlay(
          true,
          responseString.length > 0
              ? responseString
              : "Didn't hear anything, try again!");
      await Future.delayed(Duration(seconds: 2));

      // setting the value of the search instance and triggering the custom query
      if (responseString.length > 0) {
        searchInstance.setValue(responseString);
        searchInstance.triggerCustomQuery();
        Navigator.pop(context);
      }
      // hiding the overlay
      widget.setOverlay(false, '');
      // to delete the already processed audio file
      audioConverter.deleteFile();
    }
  }
}
