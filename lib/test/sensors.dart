// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
// import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:sensors/sensors.dart';
// import 'package:tflite/tflite.dart';
import 'package:tflite_flutter/tflite_flutter.dart';


// import 'snake.dart';



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key,this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const String model = "Model";
class _MyHomePageState extends State<MyHomePage> {

  // String _model = model;
  // bool _busy = false;

  // TensorFlow Lite Interpreter object
  Interpreter _interpreter;

  void load() async{
    _interpreter = await Interpreter.fromAsset('model2.tflite');
    print("INterpreter loadeded successfully");
    // input: List<Object>
    // var inputs = [2.751983,-1.831725,0.978224,2.751983,-1.831725,10.784874,-0.003034,-0.023511	,0.047136	,323.213582];
  }
  List run(inputs){
    var outputs = List<double>(7).reshape([1, 7]);
    outputs = [0,0,0,0,0,0,0].reshape([1,7]);
    _interpreter.run(inputs, outputs);
    return outputs;
  }


  // loadModel()  async {
  //   // Tflite.close();
  //   // try {
  //     String res;
  //     res = await Tflite.loadModel(
  //         model: "assets/model.tflite",
  //     );
  //   // }on PlatformException {
  //     // print(e)
  //     // print("Failed to load to model");
  //   // }
  // }

  // Uint8List convert(List<double> data){
  //   List<int> lis = List();
  //   for(int i=0;i<9;i++)
  //
  //     lis.add(data[i].round());
  //
  //   return Uint8List.fromList(lis);
  // }

  // predict(l) async{
  //   // var recognitions = await Tflite
  //   var recognitions = await Tflite.runModelOnBinary(binary: l);
  //   // return recognitions;
  //   setState(() {
  //     _recognitions = recognitions;
  //     print(_recognitions);
  //   });
  // }

  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<List> sensorvalues;
  // final outputStream = <StreamController<dynamic>>[];
  List<StreamSubscription<dynamic>> _streamSubscriptions =
  <StreamSubscription<dynamic>>[];
  var outputs;
  // ignore: non_constant_identifier_names
  String final_Label;

  @override
  Widget build(BuildContext context) {
    // final List<String> accelerometer =
    // _accelerometerValues.map((double v) => v.toStringAsFixed(1)).toList();
    // final List<String> gyroscope =
    // _gyroscopeValues.map((double v) => v.toStringAsFixed(1)).toList();
    // final List<String> userAccelerometer = _userAccelerometerValues
    //     .map((double v) => v.toStringAsFixed(1))
    //     .toList();
    // final List<double> output = List<double>  List;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Testing: '),
              ],
            ),
        padding: const EdgeInsets.all(16.0),
      ),
              Container(
                height: 220,
                width: 220,
                decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Text("Sensor values ${sensorvalues[0]}")
              ),
          // Container(
          //     height: 220,
          //     width: 220,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.all(Radius.circular(10)),
          //     ),
          //     child: Text("Sensor values ${sensorvalues[1]}")
          // ),
          // Container(
          //     height: 220,
          //     width: 220,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.all(Radius.circular(10)),
          //     ),
          //     child: Text("Sensor values ${sensorvalues[2]}")
          // ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('$final_Label'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
          // Padding(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       Text('UserAccelerometer: $userAccelerometer'),
          //     ],
          //   ),
          //   padding: const EdgeInsets.all(16.0),
          // ),
          // Padding(
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       Text('Gyroscope: $gyroscope'),
          //     ],
          //   ),
          //   padding: const EdgeInsets.all(16.0),
          // ),
        ],
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

  // ignore: non_constant_identifier_names, missing_return
  String Map_id_labels(int id){
    if(id == 0)
      return "Non aggressive Event";
    if(id == 1)
    return "Aggressive right curve";
    if(id == 2)
    return "Aggressive left curve";
    if(id == 3)
    return "Aggressive right lane";
    if(id == 4)
    return "Aggressive left lane";
    if(id == 5)
    return "Aggressive breaking";
    if(id == 6)
    return "Aggressive acceleration";
  }
  int getlabel(outputs){
    double value = 0.0;
    int id = 0;
    if(outputs!=null){
      for(int i =0;i<outputs.length;i++) {
          if (outputs[i] > value) {
            id = i;
            value = outputs[i];
          }
        }
    }
    else
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
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event){
    setState(() {
          sensorvalues = [_accelerometerValues, _userAccelerometerValues, _gyroscopeValues];
          List<double> inputs = [sensorvalues[0][0],sensorvalues[0][1],sensorvalues[0][2],
                                  sensorvalues[1][0],sensorvalues[1][1],sensorvalues[1][2],
                                  sensorvalues[2][0],sensorvalues[2][1],sensorvalues[2][2],2
                                ];
          outputs = run(inputs);
          // print(outputs);
          int index = getlabel(outputs[0]);
          print(index);
          final_Label = Map_id_labels(index);
          print(final_Label);
    });
    }));
    load();
    // Future.delayed(const Duration(milliseconds: 1000), () {
    //   List<double> inputs = [_accelerometerValues[0],_accelerometerValues[1],_accelerometerValues[2],_accelerometerValues[0],_accelerometerValues[1],_accelerometerValues[2]+9.7,
    //     _gyroscopeValues[0],_gyroscopeValues[1],_gyroscopeValues[2],323];
    //   // var inputs = [2.751983,-1.831725,0.978224,2.751983,-1.831725,10.784874,-0.003034,-0.023511	,0.047136	,323.213582];
    //   var outputs = run(inputs);
    //   setState(() {
    //     print(outputs);
    //   });
    //
    // });
  }
}

