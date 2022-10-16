import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:untitled/clock_widget.dart';

import 'local_notif_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotifService().setup();
  LocalNotifService().configureLocalTimeZone();

  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await LocalNotifService()
          .flutterLocalNotificationsPlugin
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
          payload: notificationAppLaunchDetails!.notificationResponse?.payload)
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
  // late final LocalNotifService localNotifService;
  @override
  void initState() {
    super.initState();
    // localNotifService = LocalNotifService();
    listenToNotificationStream();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void listenToNotificationStream() =>
       LocalNotifService().behaviorSubject.listen((payload) {
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

class SecondPage extends StatefulWidget {
  static const String routeName = '/secondPage';

  const SecondPage({Key? key, required this.payload}) : super(key: key);

  final String? payload;

  @override
  _SecondPageState createState() {
    return _SecondPageState();
  }
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    debugPrint('payload ${widget.payload}');

    return Container();
  }
}
