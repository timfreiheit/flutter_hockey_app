import 'package:flutter/material.dart';
import 'package:flutter_hockey_app/flutter_hockey_app.dart';

void main() {
  HockeyAppClient.init(appId: "78ebb62a66504e3c912e5bfbba37f289");
  HockeyAppClient.runInZone(() {
    runApp(new MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: Column(
            children: <Widget>[
              Text('Running on: ${null.toString()}\n  '),
              FlatButton(
                onPressed: () {
                  throw Error();
                },
                child: Text("ashjfas"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
