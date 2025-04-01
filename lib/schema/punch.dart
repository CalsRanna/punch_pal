import 'package:isar/isar.dart';

part 'punch.g.dart';

@Collection(accessor: 'punches')
@Name('punches')
class Punch {
  Id? id;
  DateTime? date;
  @Name('day_off_seconds')
  int dayOffSeconds = 0;
  @Name('started_at')
  DateTime? startedAt;
  @Name('ended_at')
  DateTime? endedAt;
  bool rescheduled = false;

  Punch copyWith({
    DateTime? startedAt,
    DateTime? endedAt,
    int? dayOffSeconds,
    bool? rescheduled,
  }) {
    return Punch()
      ..id = id
      ..date = date
      ..startedAt = startedAt ?? this.startedAt
      ..endedAt = endedAt ?? this.endedAt
      ..dayOffSeconds = dayOffSeconds ?? this.dayOffSeconds
      ..rescheduled = rescheduled ?? this.rescheduled;
  }
}
