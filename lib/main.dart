import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'home_page.dart';

// Define the global variable for the notification plugin
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize alarm manager
  await AndroidAlarmManager.initialize();

  // Initialize the notification plugin. Ensure 'app_icon' is added as a drawable resource.
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Silent Mode Scheduler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ScheduleHomePage(),
    );
  }
}
