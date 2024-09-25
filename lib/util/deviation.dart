import 'package:flutter/material.dart';
import 'package:punch_pal/schema/punch.dart';

/// A class that calculates deviation from a standard working duration.
///
/// The [DeviationCalculator] class is used to compute the deviation from a
/// specified standard working duration by considering rest times and an array
/// of punches. The standard working duration is 7 hours and 45 minutes.
///
/// Instances of this class involve calculations based on the provided rest times
/// and standard working hour requirements.
class DeviationCalculator {
  /// The standard working duration.
  ///
  /// This is the duration that the punch times are compared against to calculate
  /// the deviation.
  final standard = const Duration(hours: 7, minutes: 45);

  /// A constant list of rest periods.
  ///
  /// These times are subtracted from the total punch duration to calculate the
  /// effective working time.
  final rest = const [
    RestTime(TimeOfDay(hour: 12, minute: 20), TimeOfDay(hour: 13, minute: 35)),
    RestTime(TimeOfDay(hour: 18, minute: 30), TimeOfDay(hour: 19, minute: 00)),
  ];

  /// Calculates the deviation from the standard working duration for a given punch.
  ///
  /// Returns the difference in hours between the actual working time (excluding rest
  /// times) and the standard duration.
  ///
  /// If any of the relevant times (`date`, `startedAt`, or `endedAt`) are null,
  /// the function returns 0. If the punch occurs on a weekend (Saturday or Sunday),
  /// the standard duration is not subtracted from the total duration.
  ///
  /// [punch] - the punch object containing the date, start time, and end time.
  double calculate(Punch punch) {
    if (punch.date == null) return 0;
    if (punch.startedAt == null) return 0;
    if (punch.endedAt == null) return 0;
    final punchStartedAt = punch.startedAt!;
    final punchEndedAt = punch.endedAt!;
    var duration = punchEndedAt.difference(punchStartedAt);
    for (var time in rest) {
      final restStartedAt = DateTime(punch.date!.year, punch.date!.month,
          punch.date!.day, time.startedAt.hour, time.startedAt.minute);
      final restEndedAt = DateTime(punch.date!.year, punch.date!.month,
          punch.date!.day, time.endedAt.hour, time.endedAt.minute);
      if (restEndedAt.isBefore(punchStartedAt) ||
          restStartedAt.isAfter(punchEndedAt)) {
        continue;
      }
      final overlapStartedAt = restStartedAt.isBefore(punchStartedAt)
          ? punchStartedAt
          : restStartedAt;
      final overlapEndedAt =
          restEndedAt.isAfter(punchEndedAt) ? punchEndedAt : restEndedAt;
      if (overlapStartedAt.isBefore(overlapEndedAt)) {
        duration -= overlapEndedAt.difference(overlapStartedAt);
      }
    }
    if (![6, 7].contains(punch.date!.weekday)) {
      duration -= standard;
    }
    if (punch.rescheduled) duration -= standard;
    final fixed = (duration.inMinutes / 60).toStringAsFixed(1);
    return double.parse(fixed);
  }

  /// Sums the deviations for a list of punches.
  ///
  /// Iterates through each punch in the provided list, calculates the deviation from
  /// the standard working duration, and returns the cumulative result.
  ///
  /// [punches] - a list of punch objects to be summed.
  double sum(List<Punch> punches) {
    return punches.fold(0.0, (previous, punch) => previous + calculate(punch));
  }
}

/// A class representing a rest period.
///
/// Instances of this class contain the start and end times of rest periods, which
/// are used to subtract from the total punch duration in the [DeviationCalculator].
class RestTime {
  /// The start time of the rest period.
  final TimeOfDay startedAt;

  /// The end time of the rest period.
  final TimeOfDay endedAt;

  /// Constructs a [RestTime] with the specified start and end times.
  const RestTime(this.startedAt, this.endedAt);
}
