import 'package:isar/isar.dart';
import 'package:punch_pal/schema/isar.dart';
import 'package:punch_pal/schema/punch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'punch.g.dart';

@riverpod
class PunchNotifier extends _$PunchNotifier {
  @override
  Future<Punch> build() async {
    var punch = await isar.punches.filter().endedAtIsNull().findFirst();
    if (punch != null) return punch;
    final today = DateTime.now().toString().substring(0, 10);
    punch = await isar.punches.filter().dateEqualTo(today).findFirst();
    return punch ?? Punch();
  }

  Future<void> punchIn() async {
    final punch = await future;
    punch.startedAt = DateTime.now().millisecondsSinceEpoch;
    isar.writeTxn(() async {
      isar.punches.put(punch);
    });
    state = AsyncData(punch);
  }

  Future<void> punchOut() async {
    final punch = await future;
    punch.endedAt = DateTime.now().millisecondsSinceEpoch;
    isar.writeTxn(() async {
      isar.punches.put(punch);
    });
    state = AsyncData(punch);
  }

  Future<void> punch() async {
    final state = await future;
    if (state.startedAt == null) {
      punchIn();
      return;
    }
    punchOut();
  }
}

@riverpod
class PunchesNotifier extends _$PunchesNotifier {
  @override
  Future<List<Punch>> build(int year, int month, [int? day]) async {
    if (day != null) {
      final date = DateTime(year, month, day).toString().substring(0, 10);
      return await isar.punches.filter().dateEqualTo(date).findAll();
    }
    final date = DateTime(year, month).toString().substring(0, 7);
    return await isar.punches.filter().dateStartsWith(date).findAll();
  }
}
