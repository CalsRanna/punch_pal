import 'package:flutter/material.dart';

class PPNavigationBar extends StatelessWidget {
  final PPNavigationBarController controller;
  const PPNavigationBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Material(
      borderRadius: BorderRadius.circular(80),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(80),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        padding: const EdgeInsets.all(16),
        height: 80,
        width: mediaQuery.size.width - 32,
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return Stack(
              children: [
                _Indicator(alignment: getAlignment(controller)),
                Row(
                  children: [
                    Expanded(
                      child: _Tile(
                        active: controller.index == 0,
                        icon: const Icon(Icons.home),
                        label: 'Home',
                        onTap: () => handleTap(0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _Tile(
                        active: controller.index == 1,
                        icon: const Icon(Icons.calendar_month),
                        label: 'Statistic',
                        onTap: () => handleTap(1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _Tile(
                        active: controller.index == 2,
                        icon: const Icon(Icons.settings),
                        label: 'Setting',
                        onTap: () => handleTap(2),
                      ),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  void handleTap(int value) {
    controller.select(value);
  }

  AlignmentGeometry getAlignment(PPNavigationBarController controller) {
    return switch (controller.index) {
      0 => Alignment.centerLeft,
      1 => Alignment.center,
      _ => Alignment.centerRight,
    };
  }
}

class _Indicator extends StatelessWidget {
  final AlignmentGeometry alignment;
  const _Indicator({required this.alignment});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = (mediaQuery.size.width - 32 - 32 - 32) / 3;
    return AnimatedAlign(
      alignment: alignment,
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(48),
        ),
        height: 80,
        width: width,
      ),
    );
  }
}

class _Tile extends StatefulWidget {
  final bool active;
  final Icon icon;
  final String? label;
  final void Function()? onTap;

  const _Tile({
    this.active = false,
    required this.icon,
    this.label,
    this.onTap,
  });

  @override
  _TileState createState() => _TileState();
}

class _TileState extends State<_Tile> with TickerProviderStateMixin {
  late AnimationController _containerController;
  late AnimationController _opacityController;
  late Animation<double> _containerAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    const duration = Duration(milliseconds: 300);
    _containerController = AnimationController(duration: duration, vsync: this);
    _opacityController = AnimationController(duration: duration, vsync: this);

    _containerAnimation =
        Tween<double>(begin: 1, end: 0).animate(_containerController);
    _opacityAnimation =
        Tween<double>(begin: 0, end: 1).animate(_opacityController);

    if (widget.active) {
      forward();
    }
  }

  Future<void> forward() async {
    await _containerController.forward();
    _opacityController.forward();
  }

  Future<void> reverse() async {
    await _opacityController.reverse();
    _containerController.reverse();
  }

  @override
  void didUpdateWidget(_Tile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      forward();
    } else {
      reverse();
    }
  }

  @override
  void dispose() {
    _containerController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxWidth = (mediaQuery.size.width - 32 - 32 - 32) / 3 - 32;
    final colorScheme = Theme.of(context).colorScheme;
    final onPrimary = colorScheme.onPrimary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Container(
        alignment: Alignment.center,
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _containerAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: 24 + (_containerAnimation.value * (maxWidth - 24)),
                  child: IconTheme(
                    data: IconThemeData(color: onPrimary),
                    child: widget.icon,
                  ),
                );
              },
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) {
                  return Text(
                    widget.label ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: onPrimary.withOpacity(_opacityAnimation.value),
                      decoration: TextDecoration.none,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PPNavigationBarController extends ChangeNotifier {
  int index = 0;

  void select(int value) {
    index = value;
    notifyListeners();
  }
}
