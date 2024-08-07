import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'calendar.g.dart';

class CalendarState {
  int year = DateTime.now().year;
  int month = DateTime.now().month;
  int? day;

  CalendarState();

  CalendarState.fromDateTime(DateTime dateTime) {
    year = dateTime.year;
    month = dateTime.month;
    day = dateTime.day;
  }

  DateTime get date => DateTime(year, month, day ?? 1);

  @override
  String toString() {
    return 'CalendarState(year: $year, month: $month, day: $day)';
  }
}

@riverpod
class CalendarNotifier extends _$CalendarNotifier {
  @override
  CalendarState build() {
    return CalendarState();
  }

  void select(DateTime? date) {
    if (date == null) {
      final previousState = state;
      state = CalendarState()
        ..year = previousState.year
        ..month = previousState.month;
    } else {
      state = CalendarState.fromDateTime(date);
    }
  }

  void previousMonth() {
    state = CalendarState()
      ..year = state.year
      ..month = state.month - 1;
  }

  void nextMonth() {
    state = CalendarState()
      ..year = state.year
      ..month = state.month + 1;
  }

  void resetMonth() {
    ref.invalidateSelf();
  }
}
