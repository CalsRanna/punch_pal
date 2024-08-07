import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final double size;
  const Avatar({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        backgroundImage: const AssetImage('asset/image/avatar.png'),
        radius: size / 2,
      ),
    );
  }
}
