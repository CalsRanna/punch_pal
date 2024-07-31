import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:punch_pal/component/calendar.dart';
import 'package:punch_pal/component/spacer.dart';
import 'package:punch_pal/provider/punch.dart';
import 'package:punch_pal/schema/punch.dart';
import 'package:punch_pal/util/duration.dart';

class StatisticPage extends StatelessWidget {
  const StatisticPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            PPTopSpacer(),
            SizedBox(height: 16),
            PPCalendar(),
            SizedBox(height: 16),
            Expanded(child: _List()),
            PPBottomSpacer(),
          ],
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(punchesNotifierProvider(now.year, now.month));
      return switch (state) {
        AsyncData(:final value) => ListView.builder(
            itemBuilder: (context, index) {
              return _Tile(punch: value[index]);
            },
            itemCount: value.length,
          ),
        _ => const SizedBox(),
      };
    });
  }
}

class _Date extends StatelessWidget {
  const _Date();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.primary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Text(
            '24',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Tue',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 32, child: VerticalDivider());
  }
}

class _Item extends StatelessWidget {
  final Duration? duration;
  final String label;
  final DateTime? time;
  const _Item({this.duration, required this.label, this.time});

  @override
  Widget build(BuildContext context) {
    String text = '--:--';
    if (time != null) text = time.toString().substring(11, 16);
    if (duration != null) text = duration!.toShortString();
    return Column(
      children: [
        Text(text),
        Text(label),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final Punch punch;
  const _Tile({required this.punch});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Theme.of(context).colorScheme.surfaceContainer,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const _Date(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _Item(label: 'Punch In', time: getStartedAt()),
                    ),
                    const _Divider(),
                    Expanded(
                      child: _Item(label: 'Punch Out', time: getEndedAt()),
                    ),
                    const _Divider(),
                    Expanded(
                      child: _Item(
                        duration: getDuration(),
                        label: 'Total Hours',
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Text(getText()),
              ],
            ),
          )
        ],
      ),
    );
  }

  String getText() {
    if (punch.startedAt == null) return 'Punch In';
    if (punch.endedAt == null) return 'Punch Out';
    final startedAt = DateTime.fromMillisecondsSinceEpoch(punch.startedAt!);
    final endedAt = DateTime.fromMillisecondsSinceEpoch(punch.endedAt!);
    final difference = endedAt.difference(startedAt);
    final minutes = difference.inMinutes;
    final hours = (minutes / 60).toStringAsFixed(1);
    if (minutes > 8 * 60) return 'Over $hours hours';
    return 'Total $hours hours';
  }

  DateTime? getStartedAt() {
    if (punch.startedAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(punch.startedAt!);
  }

  DateTime? getEndedAt() {
    if (punch.endedAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(punch.endedAt!);
  }

  Duration? getDuration() {
    if (punch.startedAt == null) return null;
    if (punch.endedAt == null) return null;
    final startedAt = DateTime.fromMillisecondsSinceEpoch(punch.startedAt!);
    final endedAt = DateTime.fromMillisecondsSinceEpoch(punch.endedAt!);
    return endedAt.difference(startedAt);
  }
}
