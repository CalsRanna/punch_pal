import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:punch_pal/page/home/home.dart';
import 'package:punch_pal/provider/setting.dart';
import 'package:punch_pal/schema/isar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarInitializer.ensureInitialized();
  runApp(const ProviderScope(child: PunchPalApp()));
}

class PunchPalApp extends ConsumerWidget {
  const PunchPalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(settingNotifierProvider);
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: darkMode ? Brightness.dark : Brightness.light,
          seedColor: const Color(0xFFFCC307),
        ),
        useMaterial3: true,
      ),
    );
  }
}
