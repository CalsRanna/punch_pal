import 'package:isar/isar.dart';
import 'package:punch_pal/provider/calendar.dart';
import 'package:punch_pal/schema/isar.dart';
import 'package:punch_pal/schema/punch.dart';
import 'package:punch_pal/util/deviation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'punch.g.dart';

@riverpod
Future<double> overTime(OverTimeRef ref) async {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0);
  final queryBuilder = isar.punches.filter().dateBetween(start, end);
  final punches = await queryBuilder.sortByDateDesc().findAll();
  return DeviationCalculator().sum(punches);
}

@riverpod
class PunchesForIndicatorNotifier extends _$PunchesForIndicatorNotifier {
  @override
  Future<List<Punch>> build() async {
    final calendar = ref.watch(calendarNotifierProvider);
    final start = DateTime(calendar.year, calendar.month, 1);
    final end = DateTime(calendar.year, calendar.month + 1, 0);
    final queryBuilder = isar.punches.filter().dateBetween(start, end);
    return await queryBuilder.sortByDateDesc().findAll();
  }
}

@riverpod
class PunchesNotifier extends _$PunchesNotifier {
  @override
  Future<List<Punch>> build() async {
    final calendar = ref.watch(calendarNotifierProvider);
    if (calendar.day != null) return await _getPunch(calendar);
    return await _getPunches(calendar);
  }

  Future<void> destroy(Punch punch) async {
    await isar.writeTxn(() async {
      await isar.punches.delete(punch.id!);
    });
    ref.invalidateSelf();
  }

  Future<void> makeUpEndedAt(Punch punch, DateTime time) async {
    punch.endedAt = time;
    await isar.writeTxn(() async {
      await isar.punches.put(punch);
    });
    ref.invalidateSelf();
  }

  Future<void> makeUpStartedAt(Punch punch, DateTime time) async {
    punch.startedAt = time;
    await isar.writeTxn(() async {
      await isar.punches.put(punch);
    });
    ref.invalidateSelf();
  }

  Future<void> toggleRescheduled(Punch punch) async {
    punch.rescheduled = !punch.rescheduled;
    await isar.writeTxn(() async {
      await isar.punches.put(punch);
    });
    ref.invalidateSelf();
  }

  Future<List<Punch>> _getPunch(CalendarState calendar) async {
    final date = calendar.date;
    final punches = await isar.punches.filter().dateEqualTo(date).findAll();
    if (punches.isNotEmpty) return punches;
    return [Punch()..date = calendar.date];
  }

  Future<List<Punch>> _getPunches(CalendarState calendar) async {
    final start = calendar.date;
    final end = DateTime(calendar.year, calendar.month + 1, 0);
    final queryBuilder = isar.punches.filter().dateBetween(start, end);
    return await queryBuilder.sortByDateDesc().findAll();
  }
}

@riverpod
class PunchNotifier extends _$PunchNotifier {
  @override
  Future<Punch> build() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final punch = await isar.punches.filter().dateEqualTo(today).findFirst();
    return punch ?? Punch()
      ..date = today;
  }

  Future<void> punch() async {
    final state = await future;
    if (state.startedAt == null) {
      punchIn();
      return;
    }
    punchOut();
  }

  Future<void> punchIn() async {
    final punch = await future;
    punch.startedAt = DateTime.now();
    isar.writeTxn(() async {
      isar.punches.put(punch);
    });
    state = AsyncData(punch);
  }

  Future<void> punchOut() async {
    final punch = await future;
    punch.endedAt = DateTime.now();
    isar.writeTxn(() async {
      isar.punches.put(punch);
    });
    state = AsyncData(punch);
  }
}
