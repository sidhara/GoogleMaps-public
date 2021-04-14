import 'package:flutter/material.dart';
import 'package:googlemapsflutter/screens/MapsDemo.dart';

/*import para ejecutar en segundo plano */
import 'package:workmanager/workmanager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager.initialize(callbackDispatcher);
  await Workmanager.registerPeriodicTask("test_workertask", "test_workertask",
      inputData: {"data1": "value1", "data2": "value2"},
      frequency: Duration(minutes: 10));
  runApp(MapsDemo());
}