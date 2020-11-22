import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/services.dart';
import 'recording.dart';

import 'package:wakelock/wakelock.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'fancybox.dart';
import 'storage.dart';

void main() {
  runApp(MyApp());
  if (!Foundation.kReleaseMode) {
    Wakelock.enable();
  }
}

//use an async method so we can await
void maybeStartFGS() async {
  ///if the app was killed+relaunched, this function will be executed again
  ///but if the foreground service stayed alive,
  ///this does not need to be re-done
  if (!(await ForegroundService.foregroundServiceIsStarted())) {
    await ForegroundService.setServiceIntervalSeconds(1);

    //necessity of editMode is dubious (see function comments)
    await ForegroundService.notification.startEditMode();

    await ForegroundService.notification
        .setTitle("Noise Meter"); //TODO: app name here
    await ForegroundService.notification.setText("Currently recording");

    await ForegroundService.notification.finishEditMode();

    await ForegroundService.startForegroundService(foregroundServiceFunction);
    await ForegroundService.getWakeLock();
  }

  ///this exists solely in the main app/isolate,
  ///so needs to be redone after every app kill+relaunch
}

void foregroundServiceFunction() {
  ForegroundService.notification.setText("Recording");

  if (!ForegroundService.isIsolateCommunicationSetup) {
    ForegroundService.setupIsolateCommunication((data) {
      debugPrint("bg isolate received: $data");
    });
  }
//ForegroundService.sendToPort("${DateTime.now()}");
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _appMessage = "";
  String time = "111";
  Recording rec;
  Storage stor;
  double recordedMax = -1;

  @override
  void initState() {
    super.initState();
    //ForegroundService.setupIsolateCommunication(onNotificationData);
    rec = Recording();
    loop();
    _toggleForegroundServiceOnOff();
    rec.start();
    stor = Storage();

  }

  void loop() {
    Timer.periodic(Duration(milliseconds: 100), (timer) async {
      double v = rec.volume;
      if (v != null) {
        if (v > recordedMax) {
          recordedMax = v;
          stor.writeContent(v);
        }
      }
      setState(() {});
    });
  }

  void onNotificationData(data) {
    setState(() {
      debugPrint("main received: $data");

      time = "main received: $data";
    });
  }

  void _toggleForegroundServiceOnOff() async {
    final fgsIsRunning = await ForegroundService.foregroundServiceIsStarted();
    String appMessage;

    if (fgsIsRunning) {
      await ForegroundService.stopForegroundService();
      appMessage = "Stopped recording noise data.";
    } else {
      maybeStartFGS();
      appMessage = "Started recording noise data.";
    }

    setState(() {
      _appMessage = appMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Apoleia'),
        ),
        body: Center(
            child: Column(
          children: <Widget>[
            Text(_appMessage, style: TextStyle(fontStyle: FontStyle.italic)),
            RaisedButton(
                child: rec.active ? Icon(Icons.stop) : Icon(Icons.mic),
                onPressed: () {
                  _toggleForegroundServiceOnOff();
                  rec.toggle();
                }),
            Text(rec.volumeStr, style: TextStyle(fontSize: 20)),
            Row(children: <Widget>[
              FancyBox(),
              Padding(
                padding: EdgeInsets.only(
                    left: 5, top: rec.volume * 2, bottom: 255 - rec.volume * 2),
                child: Icon(Icons.arrow_back),
              ),
            ], mainAxisAlignment: MainAxisAlignment.center),
            Text(
                "Today's max volume that you have been exposed to id $recordedMax DB")
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )),
      ),
    );
  }
}
