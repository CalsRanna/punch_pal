import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:punch_pal/provider/calendar.dart';
import 'package:punch_pal/schema/isar.dart';
import 'package:punch_pal/schema/punch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'punch.g.dart';

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
  Future<List<Punch>> build() async {
    final calendar = ref.watch(calendarNotifierProvider);
    if (calendar.day != null) {
      final date = calendar.date;
      final punches = await isar.punches.filter().dateEqualTo(date).findAll();
      if (punches.isNotEmpty) return punches;
      return [Punch()..date = calendar.date];
    }
    final start = calendar.date;
    final end = DateTime(calendar.year, calendar.month + 1, 0);
    return await isar.punches
        .filter()
        .dateBetween(start, end)
        .sortByDateDesc()
        .findAll();
  }

  Future<void> destroy(Punch punch) async {
    await isar.writeTxn(() async {
      await isar.punches.delete(punch.id!);
    });
    ref.invalidateSelf();
  }

  Future<void> makeUpStartedAt(Punch punch, TimeOfDay time) async {
    final year = punch.date!.year;
    final month = punch.date!.month;
    final day = punch.date!.day;
    final startedAt = DateTime(year, month, day, time.hour, time.minute);
    punch.startedAt = startedAt;
    isar.writeTxn(() async {
      isar.punches.put(punch);
    });
    ref.invalidateSelf();
  }

  Future<void> makeUpEndedAt(Punch punch, TimeOfDay time) async {
    final year = punch.date!.year;
    final month = punch.date!.month;
    final day = punch.date!.day;
    final endedAt = DateTime(year, month, day, time.hour, time.minute);
    punch.endedAt = endedAt;
    isar.writeTxn(() async {
      isar.punches.put(punch);
    });
    ref.invalidateSelf();
  }
}
