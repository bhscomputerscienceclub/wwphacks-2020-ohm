import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/services.dart';

class Recording {
  bool _isRecording = false;
  NoiseMeter _noiseMeter;
  StreamSubscription<NoiseReading> _noiseSubscription;
  double volume;

  bool get active {
    return _isRecording;
  }

  String get volumeStr {
    return volume.toStringAsFixed(1);
  }

  Recording() {
    _noiseMeter = new NoiseMeter(onError);
  }
  void onError(PlatformException e) {
    print(e.toString());
    _isRecording = false;
  }

  void callback() {}

  void onData(NoiseReading noiseReading) {
    this.callback();
    //print(noiseReading.toString());

    if (!this._isRecording) {
      this._isRecording = true;
    }
    volume = noiseReading.meanDecibel;

    /// Do someting with the noiseReading object
  }

  void start() async {
    try {
      debugPrint('aaa');
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (err) {
      print(err);
    }
  }

  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }

      this._isRecording = false;
      this.callback();
      volume = 0;
    } catch (err) {
      print('stopRecorder error: $err');
    }
  }

  void toggle() async {
    _isRecording ? stop() : start();
  }
}
