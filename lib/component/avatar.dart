import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(2),
      child: const CircleAvatar(
        backgroundImage: AssetImage('asset/image/avatar.png'),
        radius: 32,
      ),
    );
  }
}
