import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file/local.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'audio_converter.dart';
import 'package:flutter_searchbox/flutter_searchbox.dart';

typedef void SetOverlay(bool status, String value);

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
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  Map<dynamic, dynamic> searchWidgetState;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    searchWidgetState = SearchBaseProvider.of(context).getActiveWidgets();
    return new IconButton(
      icon: Icon(Icons.mic),
      onPressed: () async {
        switch (_currentStatus) {
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

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        var appDocDirectory;
        bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
        if (!isAndroid) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        var current = await _recorder.current(channel: 0);
        setState(() {
          _current = current;
          _currentStatus = current.status;
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _start() async {
    try {
      widget.setOverlay(false, '');
      widget.setOverlay(true, 'listening...');
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      var count = 0;
      var pauseDuration = 0;
      bool speaking = false;
      bool trigger = false;
      new Timer.periodic(tick, (Timer t) async {
        count += 1;

        if (count >= 100) {
          _stop();
          t.cancel();
        }

        var current = await _recorder.current(channel: 0);

        if (current.metering.isMeteringEnabled) {
          if (current.metering.peakPower > -7) {
            speaking = true;
            pauseDuration = 0;
            trigger = false;
          } else {
            if (speaking) {
              trigger = true;
            }
            if (pauseDuration > 8 && trigger) {
              _stop();
              t.cancel();
              trigger = false;
            }
            speaking = false;
            pauseDuration += 1;
          }
        }

        if (mounted) {
          setState(() {
            _current = current;
            _currentStatus = _current.status;
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var result = await _recorder.stop();
    if (mounted) {
      widget.setOverlay(false, '');
      widget.setOverlay(true, 'processing...');
      await setState(() {
        _current = result;
        _currentStatus = _current.status;
      });
      var audioConverter = new AudioConverter(path: result.path);
      var response = await audioConverter.convertSTT();
      var responseString = response.results
          .map((e) => e.alternatives.first.transcript)
          .join('\n');
      widget.setOverlay(false, '');
      widget.setOverlay(
          true,
          responseString.length > 0
              ? responseString
              : "Didn't hear anything, try again!");
      const tick = const Duration(milliseconds: 50);
      var count = 0;
      new Timer.periodic(tick, (Timer t) {
        count += 1;
        if (count > 30) {
          if (responseString.length > 0) {
            searchWidgetState['search-widget'].setValue(response.results
                .map((e) => e.alternatives.first.transcript)
                .join('\n'));
            searchWidgetState['search-widget'].triggerCustomQuery();
            Navigator.pop(context);
          }

          widget.setOverlay(false, '');
          audioConverter.deleteFile();
          t.cancel();
        }
      });
    }
  }
}
