import 'dart:math';

import 'package:flutter/material.dart';

class ClockModel extends ChangeNotifier {
  late double radius;
  late int initMinute;

  int minute = 0;
  double deltaRad = 0;
  int hour = 0;

  ClockModel({required this.radius, required this.initMinute}) {
    minute = initMinute;
    deltaRad = 2 * pi * minute / 60;
  }

  double get minuteRad => 2 * pi * minute / 60;

  double get hourRad => 2 * pi * ((hour % 12) / 12 + minute / 720);

  int get currentMinute => minute;
  int get currrentHour => hour;

  String get timeString {
    int h = minute.toInt() ~/ 60;
    int m = minute % 60;

    String hStr = h < 10 ? '0$h' : '$h';
    String mStr = m < 10 ? '0$m' : '$m';
    return hStr + ':' + mStr;
  }

  onPanUpdate(DragUpdateDetails details) {
    double MAX_HOUR_RAD = 2 * pi * 24;
    bool onTop = details.localPosition.dy <= radius;
    bool onLeft = details.localPosition.dx <= radius;
    bool onRight = !onLeft;
    bool onBottom = !onTop;

    bool panUp = details.delta.dy <= 0;
    bool panLeft = details.delta.dx <= 0;
    bool panDown = !panUp;
    bool panRight = !panLeft;

    double dx = details.delta.dx.abs();
    double dy = details.delta.dy.abs();

    double verticalRotation =
        (onRight && panDown) || (onLeft && panUp) ? dy : dy * -1;

    double horizontalRotation =
        (onTop && panRight) || (onBottom && panLeft) ? dx : dx * -1;

    //still not following the gesture movement
    deltaRad += ((verticalRotation + horizontalRotation) / radius);

    // minute > 24 hour, reset to 0
    if (deltaRad > MAX_HOUR_RAD) {
      deltaRad = 0;
    }

    if (deltaRad < 0) {
      deltaRad = MAX_HOUR_RAD - deltaRad;
    }
    //deltarRad to minute?
    //6.28rad = 60 menit
    //x rad = x menit
    minute = (deltaRad / (2 * pi) * 60).toInt();

    notifyListeners();
  }
}
