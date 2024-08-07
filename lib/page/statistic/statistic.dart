import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:punch_pal/component/calendar.dart';
import 'package:punch_pal/component/date_time_picker.dart';
import 'package:punch_pal/component/spacer.dart';
import 'package:punch_pal/provider/calendar.dart';
import 'package:punch_pal/provider/punch.dart';
import 'package:punch_pal/schema/punch.dart';
import 'package:punch_pal/util/datetime.dart';
import 'package:punch_pal/util/deviation.dart';
import 'package:punch_pal/util/duration.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PPTopSpacer(),
            SizedBox(height: 16),
            _Calendar(),
            SizedBox(height: 8),
            Expanded(child: _List()),
          ],
        ),
      ),
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer(builder: (context, ref, child) {
      final punches = ref.watch(punchesNotifierProvider).value;
      return PPCalendar(
        indicatorBuilder: (datetime) {
          var color = Colors.transparent;
          if (punches != null) {
            final punch = punches.where((p) => p.date == datetime).firstOrNull;
            if (punch != null) {
              final deviation = DeviationCalculator().calculate(punch);
              if (deviation < 0) {
                color = colorScheme.errorContainer;
              } else {
                color = colorScheme.primary;
              }
            }
          }
          return PPCalendarIndicator(color);
        },
        onChanged: (value) => handleChanged(ref, value),
        onNext: () => handleNext(ref),
        onPrevious: () => handlePrevious(ref),
        onReset: () => handleReset(ref),
      );
    });
  }

  void handleChanged(WidgetRef ref, DateTime? date) {
    final notifier = ref.read(calendarNotifierProvider.notifier);
    notifier.select(date);
  }

  void handleNext(WidgetRef ref) {
    final notifier = ref.read(calendarNotifierProvider.notifier);
    notifier.nextMonth();
  }

  void handlePrevious(WidgetRef ref) {
    final notifier = ref.read(calendarNotifierProvider.notifier);
    notifier.previousMonth();
  }

  void handleReset(WidgetRef ref) {
    final notifier = ref.read(calendarNotifierProvider.notifier);
    notifier.resetMonth();
  }
}

class _Date extends StatelessWidget {
  final DateTime date;
  const _Date({required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primary = colorScheme.primaryContainer;
    final onPrimary = colorScheme.onPrimaryContainer;
    final error = colorScheme.errorContainer;
    final onError = colorScheme.onErrorContainer;
    return Consumer(builder: (context, ref, child) {
      final punches = ref.watch(punchesNotifierProvider).value;
      if (punches == null) return const SizedBox();
      final punch = punches.where((p) => p.date == date).first;
      var backgroundColor = primary;
      var textColor = onPrimary;
      if (DeviationCalculator().calculate(punch) < 0) {
        backgroundColor = error;
        textColor = onError;
      }
      final style = TextStyle(color: textColor);
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: backgroundColor,
        ),
        height: 64,
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: style.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            Text(
              date.formattedWeekday(3),
              style: style.copyWith(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      );
    });
  }
}

class _HorizontalDivider extends StatelessWidget {
  const _HorizontalDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 16, thickness: 0.25);
  }
}

class _Item extends StatelessWidget {
  final Duration? duration;
  final String label;
  final void Function(DateTime?)? onTap;
  final DateTime? time;
  const _Item({this.duration, required this.label, this.onTap, this.time});

  @override
  Widget build(BuildContext context) {
    String text = '--:--';
    if (time != null) text = time.toString().substring(11, 16);
    if (duration != null) text = duration!.toShortString();
    return Consumer(builder: (context, ref, child) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => handleTap(context, ref),
        child: Column(
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      );
    });
  }

  void handleTap(BuildContext context, WidgetRef ref) async {
    if (onTap == null) return;
    final initialDateTime = _calculateInitialDateTime(ref);
    final dateTime = await showDateTimePicker(
      context,
      initialDateTime: initialDateTime,
    );
    if (dateTime == null) return;
    onTap?.call(dateTime);
  }

  DateTime? _calculateInitialDateTime(WidgetRef ref) {
    if (time != null) return time;
    final now = DateTime.now();
    final calendar = ref.read(calendarNotifierProvider);
    if (calendar.day == null) return now;
    return calendar.date.add(Duration(hours: now.hour, minutes: now.minute));
  }
}

class _List extends StatelessWidget {
  const _List();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(punchesNotifierProvider);
      return switch (state) {
        AsyncData(:final value) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getChildren(value),
            ),
          ),
        _ => const SizedBox(),
      };
    });
  }

  List<Widget> getChildren(List<Punch> punches) {
    List<Widget> children = [];
    if (punches.length > 1) {
      final deviation = DeviationCalculator().sum(punches);
      final sign = deviation < 0 ? '-' : '+';
      final formatted = deviation.abs().toStringAsFixed(1);
      children.add(
        Text(
          'Deviation: $sign$formatted hours'.toUpperCase(),
          style: const TextStyle(fontSize: 10),
        ),
      );
      children.add(const SizedBox(height: 8));
    }
    for (var i = 0; i < punches.length; i++) {
      children.add(_Tile(punch: punches[i]));
      children.add(const SizedBox(height: 8));
      if (i == punches.length - 1) {
        children.add(const SizedBox(height: 80));
        children.add(const PPBottomSpacer());
      }
    }
    return children;
  }
}

class _Tile extends StatelessWidget {
  final Punch punch;
  const _Tile({required this.punch});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => handleLongPress(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _Date(date: punch.date!),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Consumer(builder: (context, ref, child) {
                          return _Item(
                            label: 'Punch In',
                            onTap: (time) => updateStartedAt(ref, time),
                            time: punch.startedAt,
                          );
                        }),
                      ),
                      const _VerticalDivider(),
                      Expanded(
                        child: Consumer(builder: (context, ref, child) {
                          return _Item(
                            label: 'Punch Out',
                            onTap: (time) => updateEndedAt(ref, time),
                            time: punch.endedAt,
                          );
                        }),
                      ),
                      const _VerticalDivider(),
                      Expanded(
                        child: _Item(
                          duration: getDuration(),
                          label: 'Total Hours',
                        ),
                      ),
                    ],
                  ),
                  const _HorizontalDivider(),
                  Text(
                    getText(),
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.3),
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Duration? getDuration() {
    if (punch.startedAt == null) return null;
    if (punch.endedAt == null) return null;
    return punch.endedAt!.difference(punch.startedAt!);
  }

  String getText() {
    if (punch.startedAt == null) return '';
    if (punch.endedAt == null) return 'Still working';

    final endedAt = punch.endedAt!;
    final difference = endedAt.difference(punch.startedAt!);
    final hours = difference.inMinutes / 60;
    final totalHoursText = 'Total ${hours.toStringAsFixed(1)} hours';
    final deviation = DeviationCalculator().calculate(punch);
    final sign = deviation < 0 ? '-' : '+';
    final formatted = deviation.abs().toStringAsFixed(1);
    return '$totalHoursText, deviate $sign $formatted hours.';
  }

  void handleLongPress(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete'),
          content: const Text('Are you sure to delete this punch?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            Consumer(builder: (context, ref, child) {
              return TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  final notifier = ref.read(punchesNotifierProvider.notifier);
                  notifier.destroy(punch);
                  Navigator.pop(context);
                },
              );
            })
          ],
        );
      },
    );
  }

  void updateEndedAt(WidgetRef ref, DateTime? time) {
    if (time == null) return;
    final notifier = ref.read(punchesNotifierProvider.notifier);
    notifier.makeUpEndedAt(punch, time);
  }

  void updateStartedAt(WidgetRef ref, DateTime? time) {
    if (time == null) return;
    final notifier = ref.read(punchesNotifierProvider.notifier);
    notifier.makeUpStartedAt(punch, time);
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 16, child: VerticalDivider(thickness: 0.5));
  }
}
