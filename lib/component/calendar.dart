import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:punch_pal/util/calendar.dart';

class PPCalendar extends StatefulWidget {
  final Widget Function(DateTime datetime) indicatorBuilder;
  final void Function(DateTime?)? onChanged;
  final void Function()? onNext;
  final void Function()? onPrevious;
  final void Function()? onReset;
  const PPCalendar({
    super.key,
    required this.indicatorBuilder,
    this.onChanged,
    this.onNext,
    this.onPrevious,
    this.onReset,
  });

  @override
  State<PPCalendar> createState() => _PPCalendarState();
}

class _PPCalendarState extends State<PPCalendar> {
  final controller = PPCalendarController();
  var current = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return _CalendarData(
      controller: controller,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _Previous(onTap: previousMonth)),
                Expanded(
                  flex: 5,
                  child: _Title(date: current, onTap: resetMonth),
                ),
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
        final available = date.month == current.month;
        return Expanded(
          child: _Day(
            available: available,
            date: date,
            indicator: widget.indicatorBuilder(date),
            onChanged: widget.onChanged,
          ),
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
    widget.onNext?.call();
  }

  void previousMonth() {
    setState(() {
      current = DateTime(current.year, current.month - 1, 1);
    });
    widget.onPrevious?.call();
  }

  void resetMonth() {
    setState(() {
      current = DateTime.now();
    });
    widget.onReset?.call();
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

class PPCalendarIndicator extends StatelessWidget {
  final Color color;
  const PPCalendarIndicator(this.color, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      height: 4,
      width: 4,
    );
  }
}

class _CalendarData extends InheritedWidget {
  final PPCalendarController controller;
  const _CalendarData({required super.child, required this.controller});

  @override
  bool updateShouldNotify(covariant _CalendarData oldWidget) {
    return controller != oldWidget.controller;
  }

  static _CalendarData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_CalendarData>()!;
  }
}

class _Day extends StatelessWidget {
  final bool available;
  final DateTime date;
  final Widget indicator;
  final void Function(DateTime?)? onChanged;
  const _Day({
    this.available = true,
    required this.date,
    required this.indicator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => handleTap(context),
      child: ListenableBuilder(
        listenable: _CalendarData.of(context).controller,
        builder: (context, child) => Column(
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: getBackgroundColor(context),
                shape: BoxShape.circle,
              ),
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.all(4),
              child: Text('${date.day}', style: getTextStyle(context)),
            ),
            indicator
          ],
        ),
      ),
    );
  }

  Color? getBackgroundColor(BuildContext context) {
    if (!available) return null;
    final colorScheme = Theme.of(context).colorScheme;
    final controller = _CalendarData.of(context).controller;
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
    final controller = _CalendarData.of(context).controller;
    controller.select(date);
    onChanged?.call(controller.active);
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

class _Next extends StatelessWidget {
  final void Function()? onTap;
  const _Next({this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowRightDouble,
          color: color,
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
    final color = Theme.of(context).colorScheme.onSurface;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowLeftDouble,
          color: color,
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
    final first = ['Jan', 'Feb', 'Mar', 'Apr'];
    final second = ['May', 'Jun', 'Jul', 'Aug'];
    final last = ['Sep', 'Oct', 'Nov', 'Dec'];
    final months = [...first, ...second, ...last];
    return '${months[date.month - 1]} ${date.year}';
  }
}
