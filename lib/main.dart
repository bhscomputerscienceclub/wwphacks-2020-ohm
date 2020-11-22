import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/services.dart';
import 'recording.dart';

import 'package:wakelock/wakelock.dart';
import 'package:flutter/foundation.dart' as Foundation;
import 'fancybox.dart';

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
  @override
  void initState() {
    super.initState();
    //ForegroundService.setupIsolateCommunication(onNotificationData);
    rec = Recording();
    loop();
    _toggleForegroundServiceOnOff();
    rec.start();
  }

  void loop() {
    Timer.periodic(Duration(milliseconds: 33), (timer) {
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
      appMessage = "Stopped foreground service.";
    } else {
      maybeStartFGS();
      appMessage = "Started foreground service.";
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
            Text(rec.volumeStr,style: TextStyle(fontSize: )),
            Row(children: <Widget>[
              FancyBox(),
              Padding(
                padding: EdgeInsets.only(
                    left: 5, top: rec.volume, bottom: 255 - rec.volume),
                child: Icon(Icons.arrow_back),
              ),
            ],mainAxisAlignment: MainAxisAlignment.center)
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        )),
      ),
    );
  }
}
