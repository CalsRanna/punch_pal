import 'package:isar/isar.dart';

part 'punch.g.dart';

@Collection(accessor: 'punches')
@Name('punches')
class Punch {
  Id? id;
  DateTime? date;
  @Name('started_at')
  DateTime? startedAt;
  @Name('ended_at')
  DateTime? endedAt;

  Punch copyWith({DateTime? startedAt, DateTime? endedAt}) {
    return Punch()
      ..startedAt = startedAt ?? this.startedAt
      ..endedAt = endedAt ?? this.endedAt;
  }
}
