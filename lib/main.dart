// import 'package:activitytracker/test/fit_kit.dart';
// import 'package:activitytracker/test/googlefit.dart';
// import 'package:activitytracker/test/health.dart';
// import 'package:activitytracker/test/pedometer.dart';
import 'package:activitytracker/test/text_classification.dart';
import 'package:flutter/material.dart';
import 'package:activitytracker/test/sensorsV1.dart';

import 'home.dart';

void main() {
  runApp(MyApp());
}
//
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: Screen1(),
        routes: <String, WidgetBuilder>{
          '/analyse': (context) => MyHomePage(title: "Demo",),
          '/start': (context) => Screen1(),
          '/end': (context) => End(),
        }
    );
  }
}




class Textclassification extends StatefulWidget {
  @override
  _Textclassification createState() => _Textclassification();
}

class _Textclassification extends State<Textclassification> {
  TextEditingController _controller;
  Classifier _classifier;
  List<Widget> _children;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _classifier = Classifier();
    _children = [];
    _children.add(Container());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          title: const Text('Text classification'),
        ),
        body: Container(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: <Widget>[
              Expanded(
                  child: ListView.builder(
                    itemCount: _children.length,
                    itemBuilder: (_, index) {
                      return _children[index];
                    },
                  )),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.orangeAccent)),
                child: Row(children: <Widget>[
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                          hintText: 'Write some text here'),
                      controller: _controller,
                    ),
                  ),
                  FlatButton(
                    child: const Text('Classify'),
                    onPressed: () {
                      final text = _controller.text;
                      final prediction = _classifier.classify(text);
                      setState(() {
                        _children.add(Dismissible(
                          key: GlobalKey(),
                          onDismissed: (direction) {},
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              color: prediction[1] > prediction[0]
                                  ? Colors.lightGreen
                                  : Colors.redAccent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Input: $text",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  Text("Output:"),
                                  Text("   Positive: ${prediction[1]}"),
                                  Text("   Negative: ${prediction[0]}"),
                                ],
                              ),
                            ),
                          ),
                        ));
                        _controller.clear();
                      });
                    },
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
