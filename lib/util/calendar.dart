class CalendarGenerator {
  final bool showAdjacentMonths;
  final bool startWithSunday;

  CalendarGenerator({
    this.showAdjacentMonths = true,
    this.startWithSunday = true,
  });

  List<DateTime> generate(int month, {int? year}) {
    year ??= DateTime.now().year;
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final duration = startWithSunday ? 0 : 1;
    final firstDayOfCalendar = firstDayOfMonth.subtract(
      Duration(days: (firstDayOfMonth.weekday - duration) % 7),
    );
    final lastDayOfCalendar = lastDayOfMonth.add(
      Duration(days: (6 - lastDayOfMonth.weekday + duration) % 7),
    );
    return List.generate(
      lastDayOfCalendar.difference(firstDayOfCalendar).inDays + 1,
      (index) {
        final day = firstDayOfCalendar.add(Duration(days: index));
        return showAdjacentMonths || day.month == month ? day : null;
      },
    ).whereType<DateTime>().toList();
  }

  List<List<DateTime>> generateWeeks(List<DateTime> calendar) {
    return List.generate(
      calendar.length ~/ 7,
      (index) => calendar.sublist(index * 7, (index + 1) * 7),
    );
  }

  List<String> generateWeekdays() {
    final weekdays = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    if (startWithSunday) {
      weekdays.insert(0, weekdays.removeLast());
    }
    return weekdays;
  }
}
