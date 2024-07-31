import 'package:isar/isar.dart';

part 'punch.g.dart';

@Collection(accessor: 'punches')
@Name('punches')
class Punch {
  Id? id;
  String date = DateTime.now().toString().substring(0, 10);
  @Name('started_at')
  int? startedAt;
  @Name('ended_at')
  int? endedAt;
}
