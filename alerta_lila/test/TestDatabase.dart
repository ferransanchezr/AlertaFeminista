// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alerta_lila/Database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
SharedPreferences prefs;
  _getPreferences() async{
     prefs = await  SharedPreferences.getInstance();
  }
  _getPreferences();
test("test Incidence",(){

  //Test: getIncidence is Open or Closed
  prefs.setString("incidenceId","3b2fee90-8080-11e9-94c5-fb5113e29044");
  expect(Database.getIncidenceState(),"false");
   prefs.setString("incidenceId","3b2fee90-8080-11e9-94c5-fb5113e29044");
  expect(Database.getIncidenceState(),"true");
  //Test:
});
}
