extension DurationExtension on Duration {
  String toShortString() {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = (inMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
