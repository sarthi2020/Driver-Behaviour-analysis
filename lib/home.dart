library circular_bottom_navigation;

// import 'package:activitytracker/main.dart';
// import 'package:activitytracker/test/fit_kit.dart';
// import 'package:activitytracker/test/imagedetection.dart';
import 'package:activitytracker/test/sensorsV1.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:circular_bottom_navigation/circular_bottom_navigation.dart';
import 'package:circular_bottom_navigation/tab_item.dart';


List<TabItem> tabItems = List.of([
  new TabItem(
    Icons.home,
    "Sensors",
    Colors.cyan[500],
  ),
  new TabItem(
    Icons.layers,
    "Reports",
    Colors.cyan[500],
  ),
  // new TabItem(
  //   Icons.layers,
  //   "Image",
  //   Colors.red,
  // ),
//      labelStyle: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//   new TabItem(Icons.face, "Text", Colors.orangeAccent),
//   new TabItem(Icons.sports_tennis_outlined, "fit", Colors.lightGreen),
]);

class Screen1 extends StatefulWidget {
  @override
  State createState() {
    return _Screen1();
  }
}


class _Screen1 extends State<Screen1> with SingleTickerProviderStateMixin {
  CircularBottomNavigationController _navigationController =
  new CircularBottomNavigationController(0);
  TabController _tabController;

  int _currentIndex = 0; //  used for checking which bottom bar is tapped


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
    @override
    void dispose() {
      _tabController.dispose();
      super.dispose();
    }

    void onTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    } //setting state for background

    // ignore: missing_return
    Widget setbackground(selectedPos) {
      switch (selectedPos) {
        case 0:
          return Start();
        case 1:
          return Report();
        // case 1:
        //   return TfliteHome();
        // case 2:
        //   return Textclassification();
        // case 3:
        //   return HomePage();
      }
    } // used for changing background based on button tapped

    @override
    Widget build(BuildContext context) {
      // TODO: implement build
      return Scaffold(
//      backgroundColor: scaffoldcolor(_currentIndex),
        backgroundColor: Colors.white,
//      floatingActionButton: FloatingActionButton(
//        onPressed: () async{
//
//        },
//        child: Icon(Icons.navigation),
//        backgroundColor: Colors.green,
//      ),
//      key: myGlobals.scaffoldKey,
        body: Container(
          child: setbackground(_currentIndex),
        ),
        bottomNavigationBar: CircularBottomNavigation(
          tabItems,
          controller: _navigationController,
          selectedCallback: (int selectedPos) {
            // print("clicked on $selectedPos");
            onTapped(selectedPos);
          },
        ),
      );
    }
  }