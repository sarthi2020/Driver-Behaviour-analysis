import 'dart:async';

// import 'dart:js';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Interpreter _interpreter;

  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<List> sensorValues;

  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];

  var outputs;
  // ignore: non_constant_identifier_names
  var Stream;

  // ignore: non_constant_identifier_names
  String final_Label;
  bool _loaded = false;

  void load() async {
    _interpreter = await Interpreter.fromAsset('iot.tflite');
    print("INterpreter loadeded successfully");
    // input: List<Object>
    // var inputs = [2.751983,-1.831725,0.978224,2.751983,-1.831725,10.784874,-0.003034,-0.023511	,0.047136	,323.213582];
  }

  List run(inputs) {
    var outputs = List<double>(8).reshape([1, 8]);
    outputs = [0, 0, 0, 0, 0, 0, 0, 0].reshape([1, 8]);
    _interpreter.run(inputs, outputs);
    return outputs;
  }

  // ignore: non_constant_identifier_names, missing_return
  String Map_id_labels(int id) {
    if (id == 0) return "Non aggressive Event";
    if (id == 1) return "Aggressive right curve";
    if (id == 2) return "Aggressive left curve";
    if (id == 3) return "Aggressive right lane";
    if (id == 4) return "Aggressive left lane";
    if (id == 5) return "Aggressive breaking";
    if (id == 6) return "Aggressive acceleration";
    if (id == 7) return "Normal Driving";
  }

  int getlabel(outputs) {
    double value = 0.0;
    int id = 0;
    if (outputs != null) {
      for (int i = 0; i < outputs.length; i++) {
        if (outputs[i] > value) {
          id = i;
          value = outputs[i];
        }
      }
    } else
      id = 0;
    return id;
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    Stream = userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        if (_loaded) {
          sensorValues = [
            _userAccelerometerValues,
            _accelerometerValues,
            _gyroscopeValues
          ];
          List<double> inputs = <double>[
            sensorValues[0][0],
            sensorValues[0][1],
            sensorValues[0][2],
            sensorValues[1][0],
            sensorValues[1][1],
            sensorValues[1][2],
            sensorValues[2][0],
            sensorValues[2][1],
            sensorValues[2][2]
            // 20
          ];
          outputs = run(inputs);
          int index = getlabel(outputs[0]);
          final_Label = Map_id_labels(index);
          print(final_Label);
          if (final_Label != 'Normal Driving') {
            Stream.pause();
            Future.delayed(const Duration(milliseconds: 1000), () {
              Stream.resume();
            });
          }
        }
      });
    });
    load();

    Future.delayed(const Duration(milliseconds: 5000), () {
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IOT'),
        backgroundColor: Colors.cyan[500],
      ),
      body: _loaded
          ? SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Analyzing Driver Behaviour.....',
                      style: TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 20)),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
            ),
            // Container(
            //     height: 100,
            //     width: 100,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.all(Radius.circular(10)),
            //     ),
            //     child: Text("Accelerometer values "
            //         "[${double.parse((_userAccelerometerValues[0]).toStringAsFixed(2))}, "
            //         "${double.parse((_userAccelerometerValues[1]).toStringAsFixed(2))}, "
            //         "${double.parse((_userAccelerometerValues[2]).toStringAsFixed(2))}]")),
            // Container(
            //     height: 100,
            //     width: 100,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.all(Radius.circular(10)),
            //     ),
            //     child: Text("User Acceleration values "
            //         "[${double.parse((_accelerometerValues[0]).toStringAsFixed(2))}, "
            //         "${double.parse((_accelerometerValues[1]).toStringAsFixed(2))}, "
            //         "${double.parse((_accelerometerValues[2]).toStringAsFixed(2))}]")),
            // Container(
            //     height: 100,
            //     width: 100,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.all(Radius.circular(10)),
            //     ),
            //     child: Text("Gyroscope values "
            //         "[${double.parse((_gyroscopeValues[0]).toStringAsFixed(2))}, "
            //         "${double.parse((_gyroscopeValues[1]).toStringAsFixed(2))}, "
            //         "${double.parse((_gyroscopeValues[2]).toStringAsFixed(2))}]")),
            Timer(context),
            Padding(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('$final_Label',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 20)),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
            ),
          ],
        ),
      )
          : Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }
}

// ignore: non_constant_identifier_names
Widget Timer(BuildContext context) {
  CountDownController _controller = CountDownController();
  int _duration = 60;

  return Center(
      child: CircularCountDownTimer(
        // Countdown duration in Seconds.
        duration: _duration,

        // Countdown initial elapsed Duration in Seconds.
        initialDuration: 0,

        // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
        controller: _controller,

        // Width of the Countdown Widget.
        width: MediaQuery.of(context).size.width / 4,

        // Height of the Countdown Widget.
        height: MediaQuery.of(context).size.height / 4,

        // Ring Color for Countdown Widget.
        ringColor: Colors.white,

        // Ring Gradient for Countdown Widget.
        ringGradient: null,

        // Filling Color for Countdown Widget.
        fillColor: Color(0xFFA7FFEB),

        // Filling Gradient for Countdown Widget.
        fillGradient: null,

        // Background Color for Countdown Widget.
        backgroundColor: Color(0xFF80DEEA),

        // Background Gradient for Countdown Widget.
        backgroundGradient: null,

        // Border Thickness of the Countdown Ring.
        strokeWidth: 10.0,

        // Begin and end contours with a flat edge and no extension.
        strokeCap: StrokeCap.round,

        // Text Style for Countdown Text.
        textStyle: TextStyle(
            fontSize: 33.0, color: Colors.white, fontWeight: FontWeight.bold),

        // Format for the Countdown Text.
        textFormat: CountdownTextFormat.S,

        // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
        isReverse: false,

        // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
        isReverseAnimation: false,

        // Handles visibility of the Countdown Text.
        isTimerTextShown: true,

        // Handles the timer start.
        autoStart: true,

        // This Callback will execute when the Countdown Starts.
        onStart: () {
          // Here, do whatever you want
          print('Countdown Started');
        },

        // This Callback will execute when the Countdown Ends.
        onComplete: () {
          // Here, do whatever you want
          print('Countdown Ended');
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/end', (Route<dynamic> route) => false);
        },
      ));
}

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: const Text('Welcome'),
          backgroundColor: Colors.cyan[500],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              new Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20, top: 40, right: 20),
                  child: Text(
                    "Welcome, Press the start button to analyse the Driver's Behaviour",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )),
              const SizedBox(height: 100),
              RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/analyse');
                },
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  width: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      // end: Alignment(0.8,0.0),
                      colors: [
                        Color(0xFF80DEEA),
                        Color(0xFFA7FFEB),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child:
                        const Text('Start', style: TextStyle(fontSize: 20)),
                      ),
                      Container(
                        child: Icon(Icons.vpn_key),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class End extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: const Text('Score'),
          backgroundColor: Colors.cyan[500],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              new Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20, top: 40, right: 20),
                  child: Text(
                    "Driver's Score is:",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )),
              const SizedBox(height: 100),
              RaisedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/start');
                },
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  width: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      // end: Alignment(0.8,0.0),
                      colors: [
                        Color(0xFF80DEEA),
                        Color(0xFFA7FFEB),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: const Text('Try Again',
                            style: TextStyle(fontSize: 20)),
                      ),
                      Container(
                        child: Icon(Icons.vpn_key),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class Report extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.cyan[500],
      ),
      body: new Center(
          child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 20, top: 40, right: 20),
              child: Center(
                  child: Text(
                    "No Reports Found!!",
                    style: TextStyle(
                        fontSize: 21, fontWeight: FontWeight.w400),
                  )))),

    );
  }
}
