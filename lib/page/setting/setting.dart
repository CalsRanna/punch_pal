import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:punch_pal/component/spacer.dart';
import 'package:punch_pal/provider/setting.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const PPTopSpacer(),
            Consumer(builder: (context, ref, child) {
              final state = ref.watch(settingNotifierProvider);
              return ListTile(
                leading: Icon(state ? Icons.light_mode : Icons.dark_mode),
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
