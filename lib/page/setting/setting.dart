import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:punch_pal/component/avatar.dart';
import 'package:punch_pal/component/spacer.dart';
import 'package:punch_pal/provider/setting.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const PPTopSpacer(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 64.0),
              child: Avatar(),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedSmile,
                color: color,
              ),
              title: const Text('Weekend'),
              trailing: const Text('Sat, Sun'),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedWorkHistory,
                color: color,
              ),
              title: const Text('Standard Work Time'),
              trailing: const Text('7 Hours 45 Minutes'),
            ),
            ListTile(
              leading: HugeIcon(
                icon: HugeIcons.strokeRoundedRestaurant02,
                color: color,
              ),
              title: const Text('Rest Time'),
              trailing: const Text('12:20 - 13:35, 18:30 - 19:00'),
            ),
            Consumer(builder: (context, ref, child) {
              final state = ref.watch(settingNotifierProvider);
              return ListTile(
                leading: HugeIcon(
                  icon: state
                      ? HugeIcons.strokeRoundedSun01
                      : HugeIcons.strokeRoundedMoon02,
                  color: color,
                ),
                title: Text(state ? 'Light Mode' : 'Dark Mode'),
                onTap: () => handleTap(ref),
              );
            }),
          ],
        ),
      ),
    );
  }

  void handleTap(WidgetRef ref) {
    final notifier = ref.read(settingNotifierProvider.notifier);
    notifier.toggle();
  }
}
