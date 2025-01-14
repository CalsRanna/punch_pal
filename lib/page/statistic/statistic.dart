import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
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

class _Calendar extends ConsumerWidget {
  const _Calendar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final punches = ref.watch(punchesForIndicatorNotifierProvider).value;
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
      return GestureDetector(
        onTap: () => handleTap(context, ref, punch),
        child: Stack(
          children: [
            Container(
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
                    style: style.copyWith(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    date.formattedWeekday(3),
                    style: style.copyWith(
                        fontSize: 12, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            if (punch.rescheduled)
              const Positioned(
                left: 4,
                top: 4,
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCircleArrowDataTransferDiagonal,
                  color: Colors.red,
                  size: 16,
                ),
              ),
          ],
        ),
      );
    });
  }

  void confirmReschedule(BuildContext context, WidgetRef ref, Punch punch) {
    Navigator.pop(context);
    final date = punch.date;
    if (date == null || ![6, 7].contains(date.weekday)) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      final primaryContainer = colorScheme.primaryContainer;
      final onPrimaryContainer = colorScheme.onPrimaryContainer;
      final textStyle = TextStyle(color: onPrimaryContainer);
      final text = Text('You can not reschedule a weekday', style: textStyle);
      final snackBar = SnackBar(
        backgroundColor: primaryContainer,
        behavior: SnackBarBehavior.floating,
        content: text,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 96),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    final notifier = ref.read(punchesNotifierProvider.notifier);
    notifier.toggleRescheduled(punch);
  }

  void handleTap(BuildContext context, WidgetRef ref, Punch punch) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reschedule'),
          content: const Text('Are you sure to reschedule this punch?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            Consumer(builder: (context, ref, child) {
              return TextButton(
                child: const Text('Reschedule'),
                onPressed: () => confirmReschedule(context, ref, punch),
              );
            })
          ],
        );
      },
    );
  }
}

class _Deviation extends StatelessWidget {
  final Punch punch;
  const _Deviation(this.punch);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
      fontSize: 10,
      fontWeight: FontWeight.w300,
    );
    return Text(getText(), style: textStyle);
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

class _List extends ConsumerWidget {
  const _List();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(punchesNotifierProvider);
    return switch (state) {
      AsyncData(:final value) => _buildAsyncData(value),
      _ => const SizedBox(),
    };
  }

  List<Widget> getChildren(List<Punch> punches) {
    List<Widget> children = [];
    // if (punches.length > 1) {
    final deviation = DeviationCalculator().sum(punches);
    final sign = deviation < 0 ? '-' : '+';
    final formatted = deviation.abs().toStringAsFixed(1);
    final text = Text(
      'Deviation: $sign$formatted hours'.toUpperCase(),
      style: const TextStyle(fontSize: 10),
    );
    children.add(text);
    children.add(const SizedBox(height: 8));
    // }
    for (var i = 0; i < punches.length; i++) {
      children.add(_Tile(punch: punches[i]));
      children.add(const SizedBox(height: 8));
    }
    children.add(const SizedBox(height: 80));
    children.add(const PPBottomSpacer());
    return children;
  }

  Widget _buildAsyncData(List<Punch> value) {
    if (value.isEmpty) return const Center(child: Text('No punches yet'));
    final children = getChildren(value);
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
    return SingleChildScrollView(child: column);
  }
}

class _Tile extends ConsumerWidget {
  final Punch punch;
  const _Tile({required this.punch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final punchIn = _Item(
      label: 'Punch In',
      onTap: (time) => updateStartedAt(ref, time),
      time: punch.startedAt,
    );
    final punchOut = _Item(
      label: 'Punch Out',
      onTap: (time) => updateEndedAt(ref, time),
      time: punch.endedAt,
    );
    final duration = _Item(duration: getDuration(), label: 'Total Hours');
    final items = [
      Expanded(child: punchIn),
      const _VerticalDivider(),
      Expanded(child: punchOut),
      const _VerticalDivider(),
      Expanded(child: duration),
    ];
    final columnChildren = [
      Row(children: items),
      const _HorizontalDivider(),
      _Deviation(punch)
    ];
    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnChildren,
    );
    final children = [
      _Date(date: punch.date!),
      const SizedBox(width: 16),
      Expanded(child: column)
    ];
    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      color: Theme.of(context).colorScheme.surfaceContainer,
    );
    final tile = Container(
      decoration: boxDecoration,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: children),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => handleLongPress(context),
      child: tile,
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
    HapticFeedback.mediumImpact();
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
