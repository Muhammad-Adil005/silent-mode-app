import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class ScheduleHomePage extends StatefulWidget {
  @override
  _ScheduleHomePageState createState() => _ScheduleHomePageState();
}

class _ScheduleHomePageState extends State<ScheduleHomePage> {
  static const platform = MethodChannel('silent_mode_channel');

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int notificationIdStart = 1;
  int notificationIdEnd = 2;

  Future<void> setSilentMode(bool silent) async {
    try {
      final int result =
          await platform.invokeMethod('setSilentMode', {"silent": silent});
      print("Silent mode set: $result");
    } on PlatformException catch (e) {
      print("Failed to set silent mode: '${e.message}'.");
    }
  }

  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(
      hour: (TimeOfDay.now().hour + 1) % 24, minute: TimeOfDay.now().minute);

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _scheduleSilentMode() async {
    await scheduleNotification(
        _startTime, notificationIdStart); // Schedule with unique ID for start
    await scheduleNotification(
        _endTime, notificationIdEnd); // Schedule with unique ID for end
  }

  /*Future<void> scheduleNotification(TimeOfDay time) async {
    var now = DateTime.now();
    var scheduledNotificationDateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'silent_mode_channel_id',
      'silent mode channel name',
      channelDescription: 'channel description',
      icon: 'app_icon',
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Silent Mode Change',
      'Silent mode will be toggled soon.',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
    );
  }*/
  Future<void> scheduleNotification(TimeOfDay time, int id) async {
    var now = DateTime.now();
    var scheduledNotificationDateTime = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);

    // Ensure the scheduled time is in the future
    if (scheduledNotificationDateTime.isBefore(now)) {
      scheduledNotificationDateTime =
          scheduledNotificationDateTime.add(Duration(days: 1));
    }

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'silent_mode_channel_id',
      'silent mode channel name',
      channelDescription: 'channel description',
      icon: 'app_icon',
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id, // Unique notification ID
      'Silent Mode Change',
      'Silent mode will be toggled soon.',
      scheduledNotificationDateTime,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Silent Mode Scheduler'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => _selectTime(context, true),
            child: Text('Select Start Time'),
          ),
          ElevatedButton(
            onPressed: () => _selectTime(context, false),
            child: Text('Select End Time'),
          ),
          ElevatedButton(
            onPressed: _scheduleSilentMode,
            child: Text('Save Settings'),
          ),
          Text('Start Time: ${_startTime.format(context)}'),
          Text('End Time: ${_endTime.format(context)}'),
        ],
      ),
    );
  }
}
