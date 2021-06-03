import 'dart:async';

// import 'dart:js';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class Storage {
// ignore: non_constant_identifier_names
  int count_of_aggressive_events = 0;
  int time = 15;
  double score = 0.0;
  List<String> dates = [];
  List<String> scores = [];
}

SharedPreferences _prefs;

Storage storage = Storage();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
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

  Animation animation;
  AnimationController controller;

  void load() async {
    _interpreter = await Interpreter.fromAsset('iot-final.tflite');
    print("Interpreter loadeded successfully");
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

  // ignore: non_constant_identifier_names
  int CountAggressiveEvents(int count) {
    count = count + 1;
    return count;
  }

  @override
  void initState() {
    super.initState();
    // controller = AnimationController(
    //   vsync:this,
    //   duration:Duration(seconds: 2),
    // );
    // animation = Tween(
    //   begin: 0.5,
    //   end: 1.0,
    // ).animate(controller);
    //
    // controller.forward();
    //
    // controller.repeat();
    // controller.addListener(() {
    //   setState(() {});
    // });

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
            storage.count_of_aggressive_events =
                CountAggressiveEvents(storage.count_of_aggressive_events);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('IOT'),
        backgroundColor: Colors.cyan[500],
      ),
      body: _loaded
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // Padding(
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //     children: <Widget>[
                  //       Text('Analyzing Driver Behaviour.....',
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.w400, fontSize: 20)),
                  //     ],
                  //   ),
                  //   padding: const EdgeInsets.all(16.0),
                  // ),
                  const SizedBox(height: 20),
                  AnimatedTextKit(
                    animatedTexts: [
                      FadeAnimatedText(
                        'Analysing Driver Behaviour....',
                        textStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                      // TyperAnimatedText('and then do your best'),
                      // TyperAnimatedText('- W.Edwards Deming'),
                    ],
                    // onTap: (){},
                  ),
                  // FadeTransition(
                  //   opacity: animation,
                  //   child: Text('Analysing Driver Behaviour....',
                  //       style: TextStyle(
                  //           fontWeight: FontWeight.w400,
                  //           fontSize: 20,
                  //           color: Colors.black)),
                  // ),
                  const SizedBox(height: 100),
                  Timer(context, storage.time),
                  const SizedBox(height: 50),
                  Center(
                      child: Text('$final_Label',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 20)))
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
    // controller.dispose();
    Stream.cancel();
  }
}

// ignore: non_constant_identifier_names
Widget Timer(BuildContext context, int duration) {
  CountDownController _controller = CountDownController();
  int _duration = duration;

  return Center(
      child: CircularCountDownTimer(
    duration: _duration,
    initialDuration: 0,
    controller: _controller,
    width: MediaQuery.of(context).size.width / 4,
    height: MediaQuery.of(context).size.height / 4,
    ringColor: Colors.white,
    ringGradient: null,
    fillColor: Color(0xFFA7FFEB),
    fillGradient: null,
    backgroundColor: Color(0xFF80DEEA),
    backgroundGradient: null,
    strokeWidth: 10.0,
    strokeCap: StrokeCap.round,
    textStyle: TextStyle(
        fontSize: 33.0, color: Colors.white, fontWeight: FontWeight.bold),
    textFormat: CountdownTextFormat.S,
    isReverse: false,
    isReverseAnimation: false,
    isTimerTextShown: true,
    autoStart: true,
    onStart: () {
      print('Countdown Started');
    },
    onComplete: () {
      print('Countdown Ended');
      print(storage.count_of_aggressive_events);
      storage.score = Score(storage.time, storage.count_of_aggressive_events);
      Future.delayed(const Duration(milliseconds: 3000), () {});
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/end', (Route<dynamic> route) => false);
    },
  ));
}

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(storage.dates);
    print(storage.scores);
    print(storage.count_of_aggressive_events);
    print(storage.score);
    print(storage.time);
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Welcome'),
          backgroundColor: Colors.cyan[500],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 100),
              new Container(

                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20, top: 40, right: 20),
                  child: Column(children:<Widget>[
                      Container(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: <Widget>[
                          Text(
                      "Hello Rider",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700)),
                    SizedBox(height: 80,width: 80,child: Tab(icon:Icon(Icons.drive_eta)))])),
                    const SizedBox(height:20),
                    Text(
                    "Press the start button to analyse the Driver's Behaviour",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  )])),
              const SizedBox(height: 200),
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

// ignore: must_be_immutable
class End extends StatelessWidget {
  void savescore() async {
    _prefs = await SharedPreferences.getInstance();
    // ignore: non_constant_identifier_names
    bool Checkdates = _prefs.containsKey('dates');
    // ignore: non_constant_identifier_names

    storage.scores.add(storage.score.toString());
    storage.dates.add(DateTime.now().toString());

    if (!Checkdates) {
      _prefs.setStringList("dates", storage.dates);
      _prefs.setStringList("scores", storage.scores);
    }
    if (Checkdates) {
      storage.dates = _prefs.getStringList("dates");
      storage.scores = _prefs.getStringList("scores");

      storage.scores.add(storage.score.toStringAsFixed(2));
      storage.dates.add(DateTime.now().toString());

      _prefs.setStringList("dates", storage.dates);
      _prefs.setStringList("scores", storage.scores);
    }
    storage.score = 0;
    storage.count_of_aggressive_events = 0;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        backgroundColor: Colors.white,
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  )),
              const SizedBox(height: 75),
              new Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 20, top: 40, right: 20),
                  child: Text(
                    "${storage.score.toStringAsFixed(2)}/10",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  )),
              const SizedBox(height: 100),
              RaisedButton(
                onPressed: () async {
                  await savescore();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/start', (Route<dynamic> route) => false);
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

// ignore: must_be_immutable
class Report extends StatefulWidget {
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  List dates;
  List scores;

  bool isScoreAvailable = false;

  void getScore() async {
    _prefs = await SharedPreferences.getInstance();
    // ignore: non_constant_identifier_names
    bool Checkdates = _prefs.containsKey('dates');
    // ignore: non_constant_identifier_names
    bool Checkscores = _prefs.containsKey('scores');

    if (Checkdates && Checkscores) {
      dates = _prefs.getStringList("dates");
      scores = _prefs.getStringList("scores");
      print(scores);
      print(dates);
      isScoreAvailable = true;
      setState(() {});
    }
  }

void Dialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
    return AlertDialog(
      title: Center(child: Text("Delete")),
      content: Container(
        child: Text(
            "All your Driver scores will be deleted. Are you sure?"),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'Ok',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
          onPressed: () async {
            storage.scores = [];
            storage.dates = [];
            _prefs.clear();
            isScoreAvailable = false;
            Navigator.pop(context);
            setState(() {});
          },
        ),
        FlatButton(
          child: Text(
            'Cancel',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
          onPressed: () async {
            Navigator.pop(context);
          },
        ),
      ],
    );
  },
  );
}



  void initState() {
    super.initState();
    getScore();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var height = (screenSize.height) * 0.85;
    // TODO: implement build
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: const Text('Reports'),
            backgroundColor: Colors.cyan[500],
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    Dialog();
                  })
            ]),
        body: new SingleChildScrollView(
            child: isScoreAvailable
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Date",
                                    style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "Score",
                                    style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w600),
                                  ),
                                ]),
                          ),
                        ),
                        Container(
                          height: height,
                          child: ListView.builder(
                            itemCount: scores.length,
                            itemBuilder: (BuildContext ctxt, index) {
                              return Card(
                                color: double.parse(scores[
                                            scores.length - 1 - index]) >=
                                        5.0
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "${dates[scores.length - 1 - index].substring(0, 10)}"
                                              .toString(),
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                        Text(
                                          "${scores[scores.length - 1 - index]}"
                                              .toString(),
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                      ]),
                                ),
                              );
                            },
                          ),
                        )
                      ])
                : Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 20, top: 40, right: 20),
                    child: Center(
                        child: Text(
                      "No Reports Found!!",
                      style:
                          TextStyle(fontSize: 21, fontWeight: FontWeight.w400),
                    )))),
      );
    });
  }
}

// ignore: non_constant_identifier_names
double Score(time, count) {
  double score = (time - count) / time * 10;
  if (score < 0) return 0;
  return score;
}
