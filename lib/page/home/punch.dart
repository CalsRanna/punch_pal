import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:punch_pal/component/spacer.dart';
import 'package:punch_pal/provider/punch.dart';
import 'package:punch_pal/schema/punch.dart';
import 'package:punch_pal/util/duration.dart';

class PunchPage extends StatefulWidget {
  const PunchPage({super.key});

  @override
  State<PunchPage> createState() => _PunchPageState();
}

class _PunchPageState extends State<PunchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            const PPTopSpacer(),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_Hey(), _Welcome()],
                  ),
                ),
                _Avatar(),
              ],
            ),
            const SizedBox(height: 64),
            const _Time(),
            const Spacer(),
            const _Punch(),
            const Spacer(),
            Consumer(builder: (context, ref, child) {
              final punch = ref.watch(punchNotifierProvider).value;
              return _Tip(punch: punch);
            }),
            const SizedBox(height: 32),
            const SizedBox(height: 80),
            const PPBottomSpacer(),
          ],
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final Punch? punch;
  const _Tip({super.key, this.punch});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Icon(Icons.update),
            Text(getStartedAt()),
            Text('Punch In')
          ],
        ),
        Column(
          children: [
            Icon(Icons.history),
            Text(getEndedAt()),
            Text('Punch Out')
          ],
        ),
        Column(
          children: [
            Icon(Icons.schedule),
            Text(getDuration()),
            Text('Total Hours')
          ],
        ),
      ],
    );
  }

  String getStartedAt() {
    if (punch?.startedAt == null) return '--:--';
    final date = DateTime.fromMillisecondsSinceEpoch(punch!.startedAt!);
    return date.toString().substring(11, 16);
  }

  String getEndedAt() {
    if (punch?.endedAt == null) return '--:--';
    final date = DateTime.fromMillisecondsSinceEpoch(punch!.endedAt!);
    return date.toString().substring(11, 16);
  }

  String getDuration() {
    if (punch?.startedAt == null) return '--:--';
    final startedAt = DateTime.fromMillisecondsSinceEpoch(punch!.startedAt!);
    if (punch?.endedAt == null) {
      final now = DateTime.now();
      return now.difference(startedAt).toShortString();
    }
    final endedAt = DateTime.fromMillisecondsSinceEpoch(punch!.endedAt!);
    return endedAt.difference(startedAt).toShortString();
  }
}

class _Hey extends StatelessWidget {
  const _Hey();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Hey Cals!',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        height: 64,
        width: 64,
      ),
    );
  }
}

class _Punch extends StatelessWidget {
  const _Punch();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => handleTap(ref),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          height: 240,
          padding: const EdgeInsets.all(24),
          width: 240,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.outline,
                  offset: const Offset(1, 6),
                  blurRadius: 10,
                )
              ],
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                colors: [
                  Color(0xFFF1F1F1),
                  Color(0xFFE4E7EF),
                ],
                end: Alignment.bottomRight,
                stops: [0.48, 1],
              ),
              shape: BoxShape.circle,
            ),
            height: 192,
            padding: const EdgeInsets.all(12),
            width: 192,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  colors: [
                    const Color(0xFFE4E7EF),
                    Theme.of(context).colorScheme.onPrimary,
                  ],
                  end: Alignment.bottomRight,
                  stops: const [0, 0.92],
                ),
                shape: BoxShape.circle,
              ),
              height: 168,
              width: 168,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const _Text()
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void handleTap(WidgetRef ref) {
    final notifier = ref.read(punchNotifierProvider.notifier);
    notifier.punch();
  }
}

class _Text extends StatelessWidget {
  const _Text();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final punch = ref.watch(punchNotifierProvider).value;
      String text = 'PUNCH OUT';
      if (punch?.startedAt == null) text = 'PUNCH IN';
      return Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      );
    });
  }
}

class _Welcome extends StatelessWidget {
  const _Welcome();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final part = switch (now.hour) {
      < 12 => 'morning',
      < 18 => 'afternoon',
      _ => 'evening'
    };
    return Text('Good $part! Mark you attendance.');
  }
}

class _Time extends StatefulWidget {
  const _Time();

  @override
  State<_Time> createState() => _TimeState();
}

class _TimeState extends State<_Time> {
  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Column(
      children: [
        Text(
          now.toString().substring(11, 19),
          style: GoogleFonts.b612Mono(
            fontSize: 64,
            fontWeight: FontWeight.w300,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            )
          ],
        )
      ],
    );
  }

  String date() {
    return '${month()} - ${weekday()}';
  }

  String month() {
    final today = DateTime.now();
    final month = today.month;
    final first = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    final last = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final months = [...first, ...last];
    return '${months[month - 1]} ${today.day}, ${today.year}';
  }

  String weekday() {
    final day = DateTime.now().weekday;
    final week = ['Sun', 'Mon', 'Tues', 'Wednes', 'Thurs', 'Fri', 'Satur'];
    return '${week[day]}day';
  }
}
