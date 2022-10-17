import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class LocalNotifService {
  static final LocalNotifService _singleton = LocalNotifService._internal();

  factory LocalNotifService() {
    return _singleton;
  }

  LocalNotifService._internal();

  final BehaviorSubject<String> behaviorSubject = BehaviorSubject();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
      final now = DateTime.now();
      if (payload != null && payload.isNotEmpty) {
        behaviorSubject.add('$payload:${now.toString()}');
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

    final nextSchedule = tz.TZDateTime.now(tz.local).add(Duration(minutes: nextAlarm));

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Alarm',
        'Kring kring kring... Time\'s up!!!',
        nextSchedule,
        const NotificationDetails(
            android: AndroidNotificationDetails('Alarm', 'Alarm Analog',
                channelDescription: 'Alarm create form Analog Clock')),
        payload: nextSchedule.toString(),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> cancelAlarm() async {
    flutterLocalNotificationsPlugin.cancel(0);
  }
}
