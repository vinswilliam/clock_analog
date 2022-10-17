import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:untitled/clock_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:untitled/second_page.dart';

import 'local_notif_service.dart';

Future<void> main() async {
  LocalNotifService localNotifService = LocalNotifService();

  WidgetsFlutterBinding.ensureInitialized();
  localNotifService.setup();
  localNotifService.configureLocalTimeZone();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await localNotifService.flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
  String initialRoute = MyHomePage.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    // selectedNotificationPayload =
    //     notificationAppLaunchDetails!.notificationResponse?.payload;
    initialRoute = SecondPage.routeName;
  }

  runApp(MaterialApp(
    title: 'Test Bibit',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    // home: const MyHomePage(title: 'Alarm'),
    initialRoute: initialRoute,
    routes: <String, WidgetBuilder>{
      MyHomePage.routeName: (_) => const MyHomePage(title: 'Alarm'),
      SecondPage.routeName: (_) => SecondPage(
          payload:
              notificationAppLaunchDetails?.notificationResponse?.payload ??
                  '0')
    },
  ));
}

class MyHomePage extends StatefulWidget {
  static const String routeName = '/';

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocalNotifService localNotifService = LocalNotifService();

  @override
  void initState() {
    super.initState();
    listenToNotificationStream();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void listenToNotificationStream() =>
      localNotifService.behaviorSubject.listen((payload) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SecondPage(payload: payload)));
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[Clock()],
        ),
      ),
    );
  }
}
