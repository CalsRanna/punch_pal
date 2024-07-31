import 'package:flutter/material.dart';
import 'package:punch_pal/util/calendar.dart';

class PPCalendar extends StatefulWidget {
  const PPCalendar({super.key});

  @override
  State<PPCalendar> createState() => _PPCalendarState();
}

class _PPCalendarState extends State<PPCalendar> {
  final controller = PPCalendarController();
  var current = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return PPCalendarData(
      controller: controller,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _Previous(onTap: previousMonth)),
                Expanded(child: _Title(date: current, onTap: resetMonth)),
                Expanded(child: _Next(onTap: nextMonth)),
              ],
            ),
            const _Header(),
            ...buildWeeks(),
          ],
        ),
      ),
    );
  }

  List<Widget> buildWeeks() {
    final generator = CalendarGenerator();
    final calendar = generator.generate(current.month, year: current.year);
    final weeks = generator.generateWeeks(calendar);
    Widget buildWeek(List<DateTime> week) {
      final children = week.map((date) {
        return Expanded(
          child: _Day(available: date.month == current.month, date: date),
        );
      }).toList();
      return Row(children: children);
    }

    final children = weeks.map((week) {
      return buildWeek(week);
    }).toList();
    return children;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void nextMonth() {
    setState(() {
      current = DateTime(current.year, current.month + 1, 1);
    });
  }

  void previousMonth() {
    setState(() {
      current = DateTime(current.year, current.month - 1, 1);
    });
  }

  void resetMonth() {
    setState(() {
      current = DateTime.now();
    });
  }
}

class PPCalendarController extends ChangeNotifier {
  DateTime? active;

  void select(DateTime date) {
    if (active == date) {
      active = null;
    } else {
      active = date;
    }
    notifyListeners();
  }
}

class PPCalendarData extends InheritedWidget {
  final PPCalendarController controller;
  const PPCalendarData({
    super.key,
    required super.child,
    required this.controller,
  });

  @override
  bool updateShouldNotify(covariant PPCalendarData oldWidget) {
    return controller != oldWidget.controller;
  }

  static PPCalendarData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PPCalendarData>()!;
  }
}

class _Day extends StatelessWidget {
  final bool available;

  final DateTime date;
  const _Day({this.available = true, required this.date});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => handleTap(context),
      child: ListenableBuilder(
        listenable: PPCalendarData.of(context).controller,
        builder: (context, child) => Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: getBackgroundColor(context),
            shape: BoxShape.circle,
          ),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Text('${date.day}', style: getTextStyle(context)),
              _Indicator(date: date)
            ],
          ),
        ),
      ),
    );
  }

  Color? getBackgroundColor(BuildContext context) {
    if (!available) return null;
    final colorScheme = Theme.of(context).colorScheme;
    final controller = PPCalendarData.of(context).controller;
    if (controller.active == date) return colorScheme.primaryContainer;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (date == today) return colorScheme.surface;
    return null;
  }

  TextStyle? getTextStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (!available) return TextStyle(color: colorScheme.outline);
    final workday = [1, 2, 3, 4, 5].contains(date.weekday);
    if (!workday) return TextStyle(color: colorScheme.outline);
    return null;
  }

  void handleTap(BuildContext context) {
    if (!available) return;
    final controller = PPCalendarData.of(context).controller;
    controller.select(date);
  }

  bool isWorkday(DateTime date) {
    return [1, 2, 3, 4, 5].contains(date.weekday);
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final weekdays = CalendarGenerator().generateWeekdays();
    final children = weekdays.map((weekday) {
      return Expanded(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: Text(weekday),
        ),
      );
    }).toList();
    return Row(children: children);
  }
}

class _Indicator extends StatelessWidget {
  final DateTime date;
  const _Indicator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(shape: BoxShape.circle),
      height: 4,
      width: 4,
    );
  }
}

class _Next extends StatelessWidget {
  final void Function()? onTap;
  const _Next({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Next'),
            Icon(Icons.keyboard_double_arrow_right),
          ],
        ),
      ),
    );
  }
}

class _Previous extends StatelessWidget {
  final void Function()? onTap;
  const _Previous({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.keyboard_double_arrow_left),
            Text('Previous'),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final DateTime date;
  final void Function()? onTap;
  const _Title({required this.date, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(format()),
      ),
    );
  }

  String format() {
    final first = ['Janary', 'February', 'March', 'April'];
    final second = ['May', 'June', 'July', 'August'];
    final last = ['September', 'October', 'November', 'December'];
    final months = [...first, ...second, ...last];
    return '${months[date.month - 1]} ${date.year}';
  }
}
