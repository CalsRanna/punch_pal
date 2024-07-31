import 'package:flutter/material.dart';

class PPTopSpacer extends StatelessWidget {
  const PPTopSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return SizedBox(height: mediaQuery.padding.top);
  }
}

class PPBottomSpacer extends StatelessWidget {
  const PPBottomSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return SizedBox(height: mediaQuery.padding.bottom);
  }
}
