import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:punch_pal/component/date_time_picker.dart';
import 'package:punch_pal/provider/punch.dart';
import 'package:punch_pal/schema/punch.dart';
import 'package:punch_pal/util/day_off_calculator.dart';

class PunchBottomSheet extends ConsumerWidget {
  final Punch punch;
  const PunchBottomSheet({super.key, required this.punch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var rescheduleListTile = _ListTile(
      iconData: HugeIcons.strokeRoundedCircleArrowDataTransferDiagonal,
      onTap: () => reschedulePunch(context, ref),
      title: 'Reschedule',
    );
    var dayOffListTile = _ListTile(
      iconData: HugeIcons.strokeRoundedCalendarRemove02,
      onTap: () => dayOffPunch(context, ref),
      title: 'Day off',
    );
    var deleteListTile = _ListTile(
      iconData: HugeIcons.strokeRoundedDelete02,
      onTap: () => destroyPunch(context, ref),
      title: 'Delete',
    );
    var children = [rescheduleListTile, dayOffListTile, deleteListTile];
    var boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      color: Theme.of(context).colorScheme.surfaceContainer,
    );
    var column = Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
    var container = Container(
      decoration: boxDecoration,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: column,
    );
    return SafeArea(child: container);
  }

  void destroyPunch(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(punchesNotifierProvider.notifier);
    notifier.destroy(punch);
    Navigator.pop(context);
  }

  Future<void> dayOffPunch(BuildContext context, WidgetRef ref) async {
    var startedAt = await showDateTimePicker(context, text: 'next');
    if (startedAt == null) return;
    if (!context.mounted) return;
    var endedAt = await showDateTimePicker(context);
    if (endedAt == null) return;
    var seconds = DayOffCalculator().calculate(startedAt, endedAt);
    var copiedPunch = punch.copyWith(dayOffSeconds: seconds);
    final notifier = ref.read(punchesNotifierProvider.notifier);
    notifier.updateDayOff(copiedPunch);
    if (!context.mounted) return;
    Navigator.pop(context);
  }

  void reschedulePunch(BuildContext context, WidgetRef ref) {
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
}

class _ListTile extends StatelessWidget {
  final IconData iconData;
  final void Function()? onTap;
  final String title;
  const _ListTile({required this.iconData, this.onTap, required this.title});

  @override
  Widget build(BuildContext context) {
    var children = [Icon(iconData), const SizedBox(width: 8), Text(title)];
    var child = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: children),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}
