import 'package:flutter/material.dart';
import 'package:punch_pal/schema/punch.dart';

/// Class that calculates deviation from standard work time.
///
/// The standard work time is 9 hours per day, including midday rest time. The
/// rest time is from 18:30 to 19:00.
///
/// Each deviation is calculated as a difference between the actual work time
/// and the standard work time minus the rest time.
///
/// The deviation is calculated in hours.
class DeviationCalculator {
  final standard = 9;
  final rest = const RestTime();

  double calculate(Punch punch) {
    if (punch.startedAt == null) return 0;
    if (punch.endedAt == null) return 0;
    final endedAt = punch.endedAt!;
    final difference = endedAt.difference(punch.startedAt!);
    final hours = difference.inMinutes / 60;
    final rest = _rest(endedAt);
    return hours - standard - rest;
  }

  double sum(List<Punch> punches) {
    return punches.fold(0.0, (previous, punch) => previous + calculate(punch));
  }

  double _rest(DateTime endedAt) {
    final year = endedAt.year;
    final month = endedAt.month;
    final day = endedAt.day;
    final start =
        DateTime(year, month, day, rest.start.hour, rest.start.minute);
    final end = DateTime(year, month, day, rest.end.hour, rest.end.minute);
    if (endedAt.isAfter(end)) return 0.5;
    if (endedAt.isBefore(start)) return 0;
    return endedAt.difference(start).inMinutes / 60;
  }
}

class RestTime {
  final start = const TimeOfDay(hour: 18, minute: 30);
  final end = const TimeOfDay(hour: 19, minute: 0);

  const RestTime();
}
