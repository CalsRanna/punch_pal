import 'package:flutter/material.dart';
import 'package:punch_pal/component/navigation_bar.dart';
import 'package:punch_pal/page/punch/punch.dart';
import 'package:punch_pal/page/setting/setting.dart';
import 'package:punch_pal/page/statistic/statistic.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int page = 0;
  final controller = PageController();
  final navigationController = PPNavigationBarController();

  @override
  void initState() {
    super.initState();
    navigationController.addListener(() {
      controller.animateToPage(
        navigationController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    var bottom = mediaQuery.padding.bottom;
    if (bottom == 0) bottom = 16;
    return Stack(
      children: [
        PageView(
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          children: const [PunchPage(), StatisticPage(), SettingPage()],
        ),
        Positioned(
          bottom: bottom,
          height: 80,
          left: 16,
          child: PPNavigationBar(controller: navigationController),
        )
      ],
    );
  }
}
