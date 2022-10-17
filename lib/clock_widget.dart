import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/clock_model.dart';
import 'package:untitled/local_notif_service.dart';

class Clock extends StatelessWidget {
  const Clock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double clockWidth = MediaQuery.of(context).size.width;
    final now = DateTime.now();
    int currentMinute = now.hour * 60 + now.minute;

    return ChangeNotifierProvider(
      create: (context) =>
          ClockModel(radius: clockWidth / 2, initMinute: currentMinute),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
          child: const TimeWidget(),
        ),
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            width: clockWidth,
            margin: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black12,
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: clockWidth,
                    height: clockWidth,
                    padding: const EdgeInsets.all(10),
                    child: CustomPaint(
                      painter: ClockPainter(),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                      width: clockWidth,
                      height: clockWidth,
                      padding: const EdgeInsets.all(10),
                      child: ClockHandWidget(clockWidth: clockWidth)),
                )
              ],
            ),
          ),
        ),
        const SwitchWidget(),
      ]),
    );
  }
}

class SwitchWidget extends StatefulWidget {
  const SwitchWidget({Key? key}) : super(key: key);

  @override
  _SwitchState createState() {
    return _SwitchState();
  }
}

class _SwitchState extends State<SwitchWidget> {
  bool active = false;
  LocalNotifService localNotifService = new LocalNotifService();

  Future<void> handlOnChangeSwitch(bool value) async {
    setState(() {
      active = value;
    });

    int minute = Provider.of<ClockModel>(context, listen: false).currentMinute;

    if (value) {
      localNotifService.scheduledNotification(minute);
    } else {
      localNotifService.cancelAlarm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 10),
          child: Text(
            active ? 'ON' : 'OFF',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: active ? Colors.green : Colors.black54),
          ),
        ),
        Switch(
            value: active,
            activeColor: Colors.blue,
            onChanged: handlOnChangeSwitch)
      ],
    );
  }
}

class TimeWidget extends StatelessWidget {
  const TimeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ClockModel>(
        builder: (context, clock, child) => Text(
              clock.timeString,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
            ));
  }
}

class ClockPainter extends CustomPainter {
  final Paint tickPaint;
  final TextPainter textPainter;
  final TextStyle textStyle;

  ClockPainter()
      : tickPaint = Paint(),
        textPainter = TextPainter(
            textAlign: TextAlign.center, textDirection: TextDirection.rtl),
        textStyle = const TextStyle(
          color: Colors.black,
          fontFamily: 'Times New Roman',
          fontSize: 24.0,
        ) {
    tickPaint.color = Colors.black;
  }

  bool isHour(int val) {
    return val % 5 == 0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawHourAndMinute(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void _drawHourAndMinute(Canvas canvas, Size size) {
    const minuteLen = 10;
    const hourLen = 15;
    const minuteWidth = 1.0;
    const hourWidth = 2.0;
    const radian = 2 * pi / 60;
    double radius = size.width / 2;

    canvas.translate(radius, radius);

    for (int i = 0; i < 60; i++) {
      int tickLength = isHour(i) ? hourLen : minuteLen;
      tickPaint.strokeWidth = isHour(i) ? hourWidth : minuteWidth;
      canvas.drawLine(
          Offset(0, -radius), Offset(0.0, -radius + tickLength), tickPaint);

      if (isHour(i)) {
        canvas.save();

        canvas.translate(0.0, -radius + 35);
        textPainter.text =
            TextSpan(text: i == 0 ? '12' : '${i ~/ 5}', style: textStyle);
        canvas.rotate(-radian * i);
        textPainter.layout();
        textPainter.paint(canvas,
            Offset(-(textPainter.width / 2), -(textPainter.height / 2)));

        canvas.restore();
      }

      canvas.rotate(radian);
    }
  }
}

class ClockHandWidget extends StatefulWidget {
  final double clockWidth;
  const ClockHandWidget({Key? key, required this.clockWidth}) : super(key: key);

  @override
  _ClockHandState createState() => _ClockHandState();
}

class _ClockHandState extends State<ClockHandWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
        aspectRatio: 1.0,
        child: Container(
            width: widget.clockWidth,
            padding: const EdgeInsets.all(20.0),
            child: Stack(fit: StackFit.expand, children: <Widget>[
              Consumer<ClockModel>(
                builder: (context, clock, children) => CustomPaint(
                  painter: HourHandPainter(
                    hourPos: clock.hourRad,
                  ),
                ),
              ),
              Consumer<ClockModel>(
                builder: (context, clock, childnre) => GestureDetector(
                  onPanUpdate: (details) => clock.onPanUpdate(details),
                  onPanEnd: (details) {},
                  child: CustomPaint(
                    painter: MinuteHandPainter(
                        minute: clock.minuteRad, clockWidth: widget.clockWidth),
                  ),
                ),
              ),
            ])));
  }
}

class HourHandPainter extends CustomPainter {
  final Paint handClockPaint;
  double hourPos;

  HourHandPainter({required this.hourPos}) : handClockPaint = Paint() {
    handClockPaint.color = Colors.black;
    handClockPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawClockHand(canvas, size);
  }

  @override
  bool shouldRepaint(covariant HourHandPainter oldDelegate) {
    return true;
  }

  void _drawClockHand(Canvas canvas, Size size) {
    final radius = size.width / 2;
    canvas.save();
    canvas.translate(radius, radius);

    canvas.rotate(hourPos);

    //draw hand
    Path path = Path();
    path.moveTo(-1.0, -radius + radius / 3);
    path.lineTo(-2.0, 0.0);
    path.lineTo(2.0, 0.0);
    path.lineTo(1.0, -radius + radius / 3);
    path.close();

    canvas.drawPath(path, handClockPaint);
    canvas.restore();
  }
}

class MinuteHandPainter extends CustomPainter {
  final Paint minuteClockPaint;
  double minute;
  double clockWidth;

  MinuteHandPainter({required this.minute, required this.clockWidth})
      : minuteClockPaint = Paint() {
    minuteClockPaint.color = Colors.black;
    minuteClockPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawHourHand(canvas, size);
  }

  void _drawHourHand(Canvas canvas, Size size) {
    final radius = size.width / 2;
    canvas.save();
    canvas.translate(radius, radius);

    double rotate = minute.toDouble();

    canvas.rotate(rotate);

    Path path = Path();
    path.moveTo(-1.0, -radius);
    path.lineTo(-2.0, 0.0);
    path.lineTo(2.0, 0.0);
    path.lineTo(1.0, -radius);
    path.close();

    canvas.drawPath(path, minuteClockPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant MinuteHandPainter oldDelegate) {
    return true;
  }
}
