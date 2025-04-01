import 'package:flutter/material.dart';
import 'package:punch_pal/schema/punch.dart';
import 'package:punch_pal/util/deviation.dart';

class DayOffCalculator {
  final standard = const Duration(hours: 7, minutes: 45);

  final rest = const [
    RestTime(TimeOfDay(hour: 12, minute: 20), TimeOfDay(hour: 13, minute: 35)),
    RestTime(TimeOfDay(hour: 18, minute: 30), TimeOfDay(hour: 19, minute: 00)),
  ];

  int calculate(DateTime startedAt, DateTime endedAt) {
    var duration = endedAt.difference(startedAt);
    for (var time in rest) {
      final restStartedAt = DateTime(startedAt.year, startedAt.month,
          startedAt.day, time.startedAt.hour, time.startedAt.minute);
      final restEndedAt = DateTime(endedAt.year, endedAt.month, endedAt.day,
          time.endedAt.hour, time.endedAt.minute);
      if (restEndedAt.isBefore(startedAt) || restStartedAt.isAfter(endedAt)) {
        continue;
      }
      final overlapStartedAt =
          restStartedAt.isBefore(startedAt) ? startedAt : restStartedAt;
      final overlapEndedAt =
          restEndedAt.isAfter(endedAt) ? endedAt : restEndedAt;
      if (overlapStartedAt.isBefore(overlapEndedAt)) {
        duration -= overlapEndedAt.difference(overlapStartedAt);
      }
    }
    return duration.inSeconds;
  }

  int sum(List<Punch> punches) {
    var dayOff = 0;
    for (var punch in punches) {
      if (punch.dayOffSeconds.isNegative) continue;
      dayOff += punch.dayOffSeconds;
    }
    return dayOff;
  }
}
