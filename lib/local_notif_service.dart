import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class LocalNotifService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  Future<void> setup() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  }

  Future<void> configureLocalTimeZone() async {
    tz.initializeTimeZones();
    // final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
      if (payload != null && payload.isNotEmpty) {
        behaviorSubject.add(payload);
      }
    }
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    debugPrint('Receive Local Notification');
  }

  Future<void> scheduledNotification(int duration) async {
    final now = DateTime.now();
    int currentMinute = now.hour * 60 + now.minute;

    int nextAlarm = duration;
    if (duration > currentMinute) {
      nextAlarm = duration - currentMinute;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Alarm',
        'Kring kring kring... Time\'s up!!!',
        tz.TZDateTime.now(tz.local).add(Duration(minutes: nextAlarm)),
        const NotificationDetails(
            android: AndroidNotificationDetails('Alarm', 'Alarm Analog',
                channelDescription: 'Alarm create form Analog Clock')),
        payload: nextAlarm.toString(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> cancelAlarm() async {
    flutterLocalNotificationsPlugin.cancel(0);
  }
}
